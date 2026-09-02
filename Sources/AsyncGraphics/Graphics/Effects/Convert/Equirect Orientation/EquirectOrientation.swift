//
//  EquirectOrientation.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-02.
//

import simd

extension Graphic {

    private struct EquirectOrientationUniforms: Uniforms {
        /// The booleans come first, so the quaternion stays four byte aligned in both Swift and Metal.
        let mirrorHorizontal: Bool
        let mirrorVertical: Bool
        let rotation: QuaternionUniform
    }

    /// Equirectangular Orientation
    ///
    /// Rotates and mirrors the content of an equirectangular graphic, keeping the resolution.
    ///
    /// The equirectangular graphic is expected to have a 2:1 aspect ratio.
    /// The top of the graphic is the north pole, the bottom is the south pole,
    /// the center is the front and the left and right edges meet at the back.
    ///
    /// The source is mirrored first and rotated second.
    ///
    /// - Parameters:
    ///   - rotation: Rotates the content of the graphic.
    ///   - mirrorHorizontal: Mirrors the longitude, swapping east and west.
    ///   - mirrorVertical: Mirrors the latitude, swapping the north and south poles.
    public func equirectOriented(
        rotation: simd_quatf = simd_quatf(ix: 0.0, iy: 0.0, iz: 0.0, r: 1.0),
        mirrorHorizontal: Bool = false,
        mirrorVertical: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic {

        try await Renderer.render(
            name: "Equirect Orientation",
            shader: .name("equirectOrientation"),
            graphics: [self],
            uniforms: EquirectOrientationUniforms(
                mirrorHorizontal: mirrorHorizontal,
                mirrorVertical: mirrorVertical,
                rotation: rotation.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: Renderer.Options(
                // The longitude wraps around the equirectangular graphic.
                addressMode: .repeat,
                filter: options.filter
            )
        )
    }
}
