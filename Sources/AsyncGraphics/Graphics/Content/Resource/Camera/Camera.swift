//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import AVKit

extension Graphic {
    
#if !os(visionOS)
    /// Async live stream from the camera
    public static func camera(device: AVCaptureDevice,
                              quality: AVCaptureSession.Preset = .high) throws -> AsyncStream<Graphic> {
        
        let camera = try Camera(device: device, quality: quality)
        
        return self.camera(with: camera)
    }

    /// Async live stream from the camera with preview-sized output buffers.
    public static func camera(device: AVCaptureDevice,
                              quality: AVCaptureSession.Preset = .high,
                              previewSized: Bool) throws -> AsyncStream<Graphic> {

        let camera = try Camera(
            device: device,
            quality: quality,
            previewSized: previewSized
        )

        return self.camera(with: camera)
    }
    
    /// Async live stream from the camera
    public static func camera(at position: CameraPosition = .front,
                              lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                              quality: AVCaptureSession.Preset = .high) throws -> AsyncStream<Graphic> {
        
        let camera = try Camera(position.av, with: lens, quality: quality, external: position == .external)
        
        return self.camera(with: camera)
    }

    /// Async live stream from the camera with preview-sized output buffers.
    public static func camera(at position: CameraPosition = .front,
                              lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                              quality: AVCaptureSession.Preset = .high,
                              previewSized: Bool) throws -> AsyncStream<Graphic> {

        let camera = try Camera(
            position.av,
            with: lens,
            quality: quality,
            external: position == .external,
            previewSized: previewSized
        )

        return self.camera(with: camera)
    }
#endif
    
    /// Async live stream from the camera
    public static func camera(with camera: Camera) -> AsyncStream<Graphic> {
        camera.start()
        return AsyncStream<Graphic> {
            guard !Task.isCancelled,
                  var graphic = await camera.nextGraphic()
            else { return nil }
            do {
                graphic = try await rotated(
                    graphic: graphic,
                    at: camera.position
                )
                guard !Task.isCancelled else { return nil }
                graphic = try await mirrored(
                    graphic: graphic,
                    at: camera.position
                )
            } catch {
                print("AsyncGraphics - Failed to orient camera graphic: \(error)")
            }
            guard !Task.isCancelled else { return nil }
            return graphic
        } onCancel: {
            camera.stopWithoutWaiting()
        }
    }
}

private extension Graphic {
    
    static func mirrored(graphic: Graphic, at position: AVCaptureDevice.Position) async throws -> Graphic {
#if os(macOS)
        return try await graphic.mirroredHorizontally()
#else
        if position == .front {
            return try await graphic.mirroredHorizontally()
        }
        return graphic
#endif
    }
    
    static func rotated(graphic: Graphic, at position: AVCaptureDevice.Position) async throws -> Graphic {
#if os(iOS)
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return graphic }
        switch await windowScene.interfaceOrientation {
        case .portrait:
            return try await graphic.rotatedRight()
        case .portraitUpsideDown:
            return try await graphic.rotatedLeft()
        case .landscapeLeft:
            switch position {
            case .back:
                return try await graphic.rotated(.degrees(180))
            default:
                return graphic
            }
        case .landscapeRight:
            switch position {
            case .front:
                return try await graphic.rotated(.degrees(180))
            default:
                return graphic
            }
        default:
            return graphic
        }
#else
        return graphic
#endif
    }
}
