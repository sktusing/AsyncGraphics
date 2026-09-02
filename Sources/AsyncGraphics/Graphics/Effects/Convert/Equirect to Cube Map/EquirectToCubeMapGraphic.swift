//
//  EquirectToCubeMapGraphic.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-02.
//

import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Convert {

    @GraphicMacro
    public final class EquirectToCubeMap: ConvertEffectGraphicProtocol {

        public var docs: String {
            "Project an equirectangular graphic onto the six faces of a cube map, laid out as a horizontal cross in a 4x3 atlas. Columns are left, front, right and back, rows are top, sides and bottom. Each face is a square quarter of the width, keeping the width of the graphic. The graphic is expected to have a 2:1 aspect ratio, with the north pole at the top and the front at the center."
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

            try await graphic.equirectToCubeMap(
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
