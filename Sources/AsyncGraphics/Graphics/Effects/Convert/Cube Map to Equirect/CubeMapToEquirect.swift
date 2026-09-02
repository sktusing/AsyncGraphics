//
//  CubeMapToEquirect.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-02.
//

import CoreGraphics

extension Graphic {

    private struct CubeMapToEquirectUniforms: Uniforms {
        let inside: Bool
    }

    /// Cube Map to Equirectangular
    ///
    /// Unwraps a cube map, laid out as a horizontal cross in a 4x3 atlas,
    /// into an equirectangular graphic with a 2:1 aspect ratio.
    ///
    /// Columns are left, front, right and back. Rows are top, sides and bottom.
    /// The four empty cells of the top and bottom rows are never sampled.
    ///
    /// The top of the result is the north pole, the bottom is the south pole,
    /// the center is the front and the left and right edges meet at the back.
    ///
    /// - Parameters:
    ///   - resolution: The resolution of the result. Defaults to the width of the cube map, at a 2:1 aspect ratio.
    ///   - inside: Mirrors the mapping, for an environment map seen from inside the cube.
    public func cubeMapToEquirect(
        resolution: CGSize? = nil,
        inside: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic {

        let columns: CGFloat = 4.0

        let faceWidth: CGFloat = width / columns

        let resolution: CGSize = resolution ?? CGSize(
            width: faceWidth * 4.0,
            height: faceWidth * 2.0
        )

        return try await Renderer.render(
            name: "Cube Map to Equirect",
            shader: .name("cubeMapToEquirect"),
            graphics: [self],
            uniforms: CubeMapToEquirectUniforms(inside: inside),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: Renderer.Options(
                addressMode: .clampToEdge,
                filter: options.filter
            )
        )
    }
}
