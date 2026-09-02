//
//  EquirectToCubeMap.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-02.
//

import CoreGraphics

extension Graphic {

    private struct EquirectToCubeMapUniforms: Uniforms {
        let inside: Bool
    }

    /// Equirectangular to Cube Map
    ///
    /// Projects an equirectangular graphic onto the six faces of a cube map,
    /// laid out as a horizontal cross in a 4x3 atlas.
    ///
    /// Columns are left, front, right and back. Rows are top, sides and bottom.
    /// The four empty cells of the top and bottom rows are transparent.
    ///
    /// The equirectangular graphic is expected to have a 2:1 aspect ratio.
    /// The top of the graphic is the north pole, the bottom is the south pole,
    /// the center is the front and the left and right edges meet at the back.
    ///
    /// - Parameters:
    ///   - faceResolution: The resolution of one cube map face. Defaults to a square quarter of the width.
    ///   - inside: Mirrors the mapping, for an environment map seen from inside the cube.
    public func equirectToCubeMap(
        faceResolution: CGSize? = nil,
        inside: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic {

        let columns: CGFloat = 4.0
        let rows: CGFloat = 3.0

        let faceResolution: CGSize = faceResolution ?? CGSize(
            width: width / columns,
            height: width / columns
        )

        let resolution = CGSize(
            width: faceResolution.width * columns,
            height: faceResolution.height * rows
        )

        return try await Renderer.render(
            name: "Equirect to Cube Map",
            shader: .name("equirectToCubeMap"),
            graphics: [self],
            uniforms: EquirectToCubeMapUniforms(inside: inside),
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
