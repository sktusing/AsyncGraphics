//
//  Sample.swift
//  AsyncGraphics
//
//  Created by a-heestand on 2025/01/03.
//

import Foundation
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    private struct SampleUniforms: Uniforms {
        let location: PointUniform
    }

    enum SubPixelError: LocalizedError {
        case pixelLocationOutOfBounds
        var errorDescription: String? {
            switch self {
            case .pixelLocationOutOfBounds:
                "Sub pixel location is out of bounds."
            }
        }
    }

    /// Sample at a `location` coordinate, if the coordinate is fractional nearest pixels will be interpolated.
    ///
    /// Origin is at top left.
    public func subPixel(at location: CGPoint) async throws -> PixelColor {
        try await subPixel(x: location.x, y: location.y)
    }
    
    /// Sample at an `x` and `y` coordinate, if the coordinate is fractional nearest pixels will be interpolated.
    ///
    /// Origin is at top left.
    public func subPixel(x: CGFloat, y: CGFloat) async throws -> PixelColor {
        try await subPixel(u: x / (resolution.width - 1.0),
                           v: y / (resolution.height - 1.0))
    }

    /// Sample at relative `uv` coordinates
    ///
    /// `u` is horizontal, `v` is vertical, between `0.0` and `1.0`.
    ///
    /// Origin is at top left.
    public func subPixel(u: CGFloat, v: CGFloat) async throws -> PixelColor {
        guard u >= 0.0, u <= 1.0, v >= 0.0, v <= 1.0 else {
            throw SubPixelError.pixelLocationOutOfBounds
        }
        let uv = CGPoint(x: u, y: v)
        let location: CGPoint = uv * (resolution - 1.0)
        let graphic: Graphic = try await Renderer.render(
            name: "Sample",
            shader: .name("samplePixel"),
            graphics: [self],
            uniforms: SampleUniforms(
                location: location.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: CGSize(width: 1, height: 1),
                colorSpace: colorSpace,
                bits: ._32
            ),
            options: EffectOptions.edgeStretch.spatialRenderOptions
        )
        return try await graphic.firstPixelColor
    }
}
