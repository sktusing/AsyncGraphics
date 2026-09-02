//
//  CubeMapToEquirectGraphic.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-02.
//

import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Convert {

    @GraphicMacro
    public final class CubeMapToEquirect: ConvertEffectGraphicProtocol {

        public var docs: String {
            "Unwrap a cube map, laid out as a horizontal cross in a 4x3 atlas, into an equirectangular graphic. Columns are left, front, right and back, rows are top, sides and bottom. The result is twice as wide as it is tall, with the north pole at the top and the front at the center."
        }

        public var tags: [String] {
            ["Cube Map", "Equirectangular", "Panorama", "Cross", "Skybox", "360"]
        }

        public var inside: GraphicMetadata<Bool> = .init(
            value: .fixed(false),
            docs: "Mirrors the mapping, for an environment map seen from inside the cube.")

        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {

            try await graphic.cubeMapToEquirect(
                inside: inside.value.eval(at: graphic.resolution),
                options: options
            )
        }

        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
    }
}
