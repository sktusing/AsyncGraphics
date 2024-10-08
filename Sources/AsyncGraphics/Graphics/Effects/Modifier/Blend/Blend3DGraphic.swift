import SwiftUI
import Spatial
import CoreGraphics

extension CodableGraphic3D.Effect.Modifier {
    
    @GraphicMacro
    public final class Blend: ModifierEffectGraphic3DProtocol {
        
        public var docs: String {
            "Blend two graphics together."
        }
        
        public var tags: [String] {
            Graphic.BlendMode.allCases.map(\.name)
        }
        
        public var blendingMode: GraphicEnumMetadata<Graphic.BlendMode> = .init(value: .add)
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)

        public func render(
            with graphic: Graphic3D,
            modifier modifierGraphic: Graphic3D,
            options: Graphic3D.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic3D {
                       
            try await graphic.blended(
                with: modifierGraphic,
                blendingMode: blendingMode.value,
                placement: placement.value,
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }

        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                break
            }
        }
    }
}
