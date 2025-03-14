import SwiftUI
import Spatial
import SpatialExtensions
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Space {
    
    @GraphicMacro
    public final class Transform: SpaceEffectGraphic3DProtocol {
        
        public var tags: [String] {
            ["Translation", "Offset", "Position", "Size", "Scale", "Rotation"]
        }
        
        public var translation: GraphicMetadata<Point3D> = .init(value: .zero,
                                                                 minimum: .resolutionMaximum(fraction: -0.5),
                                                                 maximum: .resolutionMaximum(fraction: 0.5),
                                                               options: .spatial)
        
        public var rotation: GraphicMetadata<Angle3D> = .init(value: .zero)
                
        public var scale: GraphicMetadata<CGFloat> = .init(value: .one,
                                                           maximum: .fixed(2.0))
        
        public var isTransparent: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public var extendMode: GraphicEnumMetadata<Graphic.ExtendMode> = .init(
            value: .stretch,
            docs: "Voxels outside the main bounds will use the extend mode when sampled. This will mainly affect voxels on the edges."
        )
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
            
            try await graphic.transformed(
                translation: translation.value.eval(at: graphic.resolution),
                rotation: rotation.value.eval(at: graphic.resolution),
                scale: scale.value.eval(at: graphic.resolution),
                options: options.union(extendMode.value.options3D)
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
            case scaledDown
            case scaledUp
        }
        
        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                break
            case .scaledDown:
                scale.value = .fixed(0.5)
            case .scaledUp:
                scale.value = .fixed(2.0)
            }
        }
    }
}
