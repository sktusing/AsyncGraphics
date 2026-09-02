//
//  PolarToCartesian.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-02.
//

import SwiftUI

extension Graphic {

    private struct PolarToCartesianUniforms: Uniforms {
        let startAngle: Float
    }

    /// Polar to Cartesian
    ///
    /// Wraps a graphic in polar coordinates back into a circle at the center,
    /// keeping the resolution.
    ///
    /// The horizontal axis of the source is a full turn, starting at the start angle
    /// and going clockwise. The vertical axis is the radius, the top is the center
    /// of the result and the bottom is half the height out from the center.
    ///
    /// The area outside of the circle is transparent.
    ///
    /// Use ``cartesianToPolar(startAngle:options:)`` with the same start angle to convert back.
    ///
    /// - Parameters:
    ///   - startAngle: The angle the leading edge of the source is placed at. Zero points right.
    public func polarToCartesian(
        startAngle: Angle = .zero,
        options: EffectOptions = []
    ) async throws -> Graphic {

        try await Renderer.render(
            name: "Polar to Cartesian",
            shader: .name("polarToCartesian"),
            graphics: [self],
            uniforms: PolarToCartesianUniforms(
                startAngle: startAngle.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: Renderer.Options(
                // The turn wraps around the leading and trailing edges of the source.
                addressMode: .clampToEdge,
                filter: options.filter
            )
        )
    }
}
