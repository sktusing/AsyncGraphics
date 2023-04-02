//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import AVKit

extension Graphic {
    
    public enum CameraPosition: Hashable {
        case front
        case back
        public mutating func flip() {
            self = flipped()
        }
        public func flipped() -> CameraPosition {
            self == .front ? .back : .front
        }
        var av: AVCaptureDevice.Position {
            switch self {
            case .front:
                return .front
            case .back:
                return .back
            }
        }
    }
    
    /// Async live stream from the camera
    public static func camera(_ position: CameraPosition,
                              device: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                              preset: AVCaptureSession.Preset = .high) throws -> AsyncStream<Graphic> {
        
        let cameraController = try CameraController(deviceType: device, position: position.av, preset: preset)
        
        return AsyncStream<Graphic>(unfolding: {
            
            await withCheckedContinuation { continuation in
                
                cameraController.graphicsHandler = { graphic in
                    
                    cameraController.graphicsHandler = nil
                    
                    Task {
                        func mirrored(graphic: Graphic) async -> Graphic {
                            if position == .front {
                                return (try? await graphic.mirroredHorizontally()) ?? graphic
                            }
                            return graphic
                        }
                        func rotated(graphic: Graphic) async -> Graphic {
                            #if os(iOS)
                            var keyWindow: UIWindow?
                            for window in await UIApplication.shared.windows {
                                if await window.isKeyWindow {
                                    keyWindow = window
                                }
                            }
                            guard let windowScene = await keyWindow?.windowScene
                            else { return graphic }
                            return await {
                                switch await windowScene.interfaceOrientation {
                                case .portrait:
                                    return try? await graphic.rotatedRight()
                                case .portraitUpsideDown:
                                    return try? await graphic.rotatedLeft()
                                case .landscapeLeft:
                                    switch position {
                                    case .back:
                                        return try? await graphic.rotated(.degrees(180))
                                    case .front:
                                        return nil
                                    }
                                case .landscapeRight:
                                    switch position {
                                    case .back:
                                        return nil
                                    case .front:
                                        return try? await graphic.rotated(.degrees(180))
                                    }
                                default:
                                    return nil
                                }
                            }() ?? graphic
                            #else
                            return graphic
                            #endif
                        }
                        let graphic: Graphic = await mirrored(graphic: rotated(graphic: graphic))
                        continuation.resume(returning: graphic)
                    }
                }
            }
        }, onCancel: {
            cameraController.cancel()
        })
    }
}
