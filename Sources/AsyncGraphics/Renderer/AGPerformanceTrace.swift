#if DEBUG
import Foundation
import Metal
import os

/// Opt-in diagnostics. All durations are elapsed time, including suspension and waits.
/// Keep metric names static so aggregation stays bounded regardless of graph size.
public final class AGPerformanceTrace: Sendable {
    public static let rendering = AGPerformanceTrace(category: "AsyncGraphics")
    public static let presentation = AGPerformanceTrace(category: "Presentation")

    public struct Interval: Sendable {
        fileprivate let name: StaticString
        fileprivate let start: UInt64
        fileprivate let signpost: OSSignpostIntervalState
    }

    private struct Metric {
        var count = 0
        var milliseconds = 0.0
        var maximum = 0.0
    }

    private struct State {
        var enabled = false
        var counts: [String: Int] = [:]
        var metrics: [String: Metric] = [:]
        var active: [String: Int] = [:]
        var lastReport = DispatchTime.now().uptimeNanoseconds
    }

    private let state = OSAllocatedUnfairLock(initialState: State())
    private let signposter: OSSignposter
    private let logger: Logger
    public let category: String

    public init(category: String) {
        self.category = category
        signposter = OSSignposter(subsystem: "FlowNodes.Performance", category: category)
        logger = Logger(subsystem: "FlowNodes.Performance", category: category)
    }

    public var isEnabled: Bool {
        get { state.withLock { $0.enabled } }
        set { state.withLock { $0.enabled = newValue } }
    }

    public func count(_ name: String, by amount: Int = 1) {
        state.withLock { state in
            guard state.enabled else { return }
            state.counts[name, default: 0] += amount
        }
    }

    public func begin(_ name: StaticString, detail: @autoclosure () -> String = "") -> Interval? {
        let enabled = state.withLock { state in
            guard state.enabled else { return false }
            state.active[name.description, default: 0] += 1
            return true
        }
        guard enabled else { return nil }
        let start = DispatchTime.now().uptimeNanoseconds
        let message = detail()
        let interval = signposter.beginInterval(name, id: signposter.makeSignpostID(), "\(message, privacy: .public)")
        return Interval(name: name, start: start, signpost: interval)
    }

    /// End every non-nil interval exactly once, including error and cancellation paths.
    public func end(_ interval: Interval?) {
        guard let interval else { return }
        let milliseconds = Double(DispatchTime.now().uptimeNanoseconds - interval.start) / 1_000_000
        signposter.endInterval(interval.name, interval.signpost)
        state.withLock { state in
            let name = interval.name.description
            state.active[name, default: 0] -= 1
            state.metrics[name, default: Metric()].count += 1
            state.metrics[name, default: Metric()].milliseconds += milliseconds
            state.metrics[name, default: Metric()].maximum = max(state.metrics[name, default: Metric()].maximum, milliseconds)
        }
    }

    /// Call once per owned command buffer, immediately before commit. This interval is
    /// submission-to-callback latency; gpu_ms is measured separately after completion.
    public func trackGPU(_ commandBuffer: MTLCommandBuffer, detail: @autoclosure () -> String = "") {
        guard let interval = begin("GPU submission to completion", detail: detail()) else { return }
        commandBuffer.addCompletedHandler { [self] buffer in
            end(interval)
            if buffer.status == .error { count("gpu.errors") }
            let start = buffer.gpuStartTime
            let end = buffer.gpuEndTime
            guard start > 0, end >= start else {
                count("gpu.timingUnavailable")
                return
            }
            let milliseconds = (end - start) * 1_000
            state.withLock { state in
                state.metrics["GPU execution", default: Metric()].count += 1
                state.metrics["GPU execution", default: Metric()].milliseconds += milliseconds
                state.metrics["GPU execution", default: Metric()].maximum = max(state.metrics["GPU execution", default: Metric()].maximum, milliseconds)
            }
            signposter.emitEvent("GPU completed", "gpu_ms=\(milliseconds)")
        }
    }

    /// The host calls this periodically. No timer, task, or per-event console output.
    public func report() {
        let snapshot: State? = state.withLock { state in
            guard state.enabled else { return nil }
            let snapshot = state
            state.counts.removeAll(keepingCapacity: true)
            state.metrics.removeAll(keepingCapacity: true)
            state.lastReport = DispatchTime.now().uptimeNanoseconds
            return snapshot
        }
        guard let snapshot else { return }
        let seconds = Double(DispatchTime.now().uptimeNanoseconds - snapshot.lastReport) / 1_000_000_000
        let counts = snapshot.counts.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }
        let metrics = snapshot.metrics.sorted { $0.key < $1.key }.map { name, metric in
            "\(name){n=\(metric.count),sum_ms=\(String(format: "%.2f", metric.milliseconds)),max_ms=\(String(format: "%.2f", metric.maximum))}"
        }
        let active = snapshot.active.filter { $0.value > 0 }.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }
        let message = "[Perf][\(category)] window_s=\(String(format: "%.2f", seconds)) \((counts + metrics).joined(separator: " ")) active=[\(active.joined(separator: ", "))]"
        logger.notice("\(message, privacy: .public)")
    }
}
#endif
