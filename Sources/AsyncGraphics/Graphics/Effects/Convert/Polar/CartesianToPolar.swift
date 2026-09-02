//
//  CartesianToPolar.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-02.
//

import SwiftUI

extension Graphic {

    private struct CartesianToPolarUniforms: Uniforms {
        let startAngle: Float
    }

    /// Cartesian to Polar
    ///
    /// Unwraps the circle at the center of the graphic into polar coordinates,
    /// keeping the resolution.
    ///
    /// The horizontal axis of the result is a full turn, starting at the start angle
    /// and going clockwise. The vertical axis is the radius, the top is the center
    /// of the source and the bottom is half the height out from the center.
    ///
    /// Use ``polarToCartesian(startAngle:options:)`` with the same start angle to convert back.
    ///
    /// - Parameters:
    ///   - startAngle: The angle at the leading edge of the result. Zero points right.
    public func cartesianToPolar(
        startAngle: Angle = .zero,
        options: EffectOptions = []
    ) async throws -> Graphic {

        try await Renderer.render(
            name: "Cartesian to Polar",
            shader: .name("cartesianToPolar"),
            graphics: [self],
            uniforms: CartesianToPolarUniforms(
                startAngle: startAngle.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: Renderer.Options(
                // The circle reaches the top and bottom edges of the source.
                addressMode: .clampToEdge,
                filter: options.filter
            )
        )
    }
}
