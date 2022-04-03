//
//  Created by Anton Heestand on 2022-03-29.
//

import Foundation
import CoreGraphics
import Metal
import TextureMap
import PixelColor

public struct Graphic {
    
    public let metalTexture: MTLTexture
    
    public let bits: TMBits
    public let colorSpace: TMColorSpace
}

// MARK: - Resolution

extension Graphic {
    
    public var resolution: CGSize {
        metalTexture.size
    }
}

// MARK: - Image

extension Graphic {
    
    public var image: TMImage {
        get async throws {
            try await metalTexture.image(colorSpace: colorSpace, bits: bits)
        }
    }
}

// MARK: - Pixels

extension Graphic {
    
    enum GraphicPixelError: LocalizedError {
        
        case noChannelsFound
        case badChannelCount

        var errorDescription: String? {
            switch self {
            case .noChannelsFound:
                return "Async Graphics - Texture - Pixels - No Channels Found"
            case .badChannelCount:
                return "Async Graphics - Texture - Pixels - Bad Channel Count"
            }
        }
    }
    
    public var firstPixelColor: PixelColor {

        get async throws {
            
            let channels: [CGFloat] = try await channels
            
            guard !channels.isEmpty, channels.count >= 4 else {
                throw GraphicPixelError.noChannelsFound
            }
            
            return PixelColor(red: channels[0],
                              green: channels[1],
                              blue: channels[2],
                              alpha: channels[3])
        }
    }
    
    public var averagePixelColor: PixelColor {
        
        get async throws {
            
            let pixels: [PixelColor] = try await pixels.flatMap { $0 }
            
            let color: PixelColor = pixels.reduce(.clear, +) / CGFloat(pixels.count)
            
            return color
        }
    }
    
    /// Pixels
    ///
    /// An array of rows of colors.
    public var pixels: [[PixelColor]] {
        
        get async throws {
            
            let channels: [CGFloat] = try await channels
            
            guard !channels.isEmpty else {
                throw GraphicPixelError.noChannelsFound
            }
            
            let count = Int(resolution.width) * Int(resolution.height) * 4
            guard channels.count == count else {
                throw GraphicPixelError.badChannelCount
            }
            
            var pixels: [[PixelColor]] = []
            
            for y in 0..<Int(resolution.height) {
            
                var rows: [PixelColor] = []
                
                for x in 0..<Int(resolution.width) {
            
                    let index = y * Int(resolution.height) * 4 + x * 4
                    
                    let red = channels[index]
                    let green = channels[index + 1]
                    let blue = channels[index + 2]
                    let alpha = channels[index + 3]
                    
                    let color = PixelColor(red: red,
                                           green: green,
                                           blue: blue,
                                           alpha: alpha)
                    
                    rows.append(color)
                }
                
                pixels.append(rows)
            }
            
            return pixels
        }
    }
    
    public var channels: [CGFloat] {
        
        get async throws {
            
            try await TextureMap.rawNormalized(texture: metalTexture, bits: bits)
        }
    }
}

// MARK: - Equal

@available(iOS 14.0, tvOS 14, macOS 11, *)
extension Graphic {
    
    /// Compares all pixels, if just one pixel is not the same, the functions returns false
    public func isEqual(to graphic: Graphic) async throws -> Bool {
        
        guard resolution == graphic.resolution else {
            return false
        }
        
        let difference = try await blended(graphic: graphic, with: .difference, at: .fit)
        
        let color = try await difference.averagePixelColor
        
        return color.brightness == 0.0
    }
}

// MARK: - Greater

//extension Graphic {
//
//}
