//
//  Created by Anton Heestand on 2023-04-28.
//

import Foundation
import TextureMap
import PixelColor
import MetalKit

extension Graphic {
    
    enum PixelsError: LocalizedError {
        case noPixels
        case unevenPixels
        var errorDescription: String? {
            switch self {
            case .noPixels:
                return "AsyncGraphics - Pixels - No Pixels"
            case .unevenPixels:
                return "AsyncGraphics - Pixels - Uneven Pixels"
            }
        }
    }
    
    public static func pixels(_ pixels: [[PixelColor]], options: ContentOptions = []) async throws -> Graphic {
        
        let height: Int = pixels.count
        guard height > 0 else {
            throw PixelsError.noPixels
        }
        let width: Int = pixels.first!.count
        guard pixels.dropFirst().allSatisfy({ row in
            row.count == width
        }) else {
            throw PixelsError.unevenPixels
        }
        
        let resolution = CGSize(width: width, height: height)
        
        let texture: MTLTexture = try await withCheckedThrowingContinuation { continuation in
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                    
                    let texture: MTLTexture
                    switch options.bits {
                    case ._8:
                        let channels: [UInt8] = pixels.flatMap { row in
                            row.flatMap { color in
                                color.components.map { channel in
                                    UInt8(min(max(channel, 0.0), 1.0) * 255)
                                }
                            }
                        }
                        texture = try TextureMap.texture(channels: channels, resolution: resolution, on: Renderer.metalDevice)
                    case ._16:
                        let channels: [Float16] = pixels.flatMap { row in
                            row.flatMap { color in
                                color.components.map { channel in
                                    Float16(channel)
                                }
                            }
                        }
                        texture = try TextureMap.texture(channels: channels, resolution: resolution, on: Renderer.metalDevice)
                    case ._32:
                        let channels: [Float] = pixels.flatMap { row in
                            row.flatMap { color in
                                color.components.map { channel in
                                    Float(channel)
                                }
                            }
                        }
                        texture = try TextureMap.texture(channels: channels, resolution: resolution, on: Renderer.metalDevice)
                    }
                    
                    DispatchQueue.main.async {
                        continuation.resume(returning: texture)
                    }
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        
        return try .texture(texture)
    }
}
