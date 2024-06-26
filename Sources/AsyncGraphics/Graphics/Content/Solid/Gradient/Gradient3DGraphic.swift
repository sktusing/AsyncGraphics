import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Content.Solid {
    
    @GraphicMacro
    public final class Gradient: SolidContentGraphic3DProtocol {
        
        public var direction: GraphicEnumMetadata<Graphic3D.Gradient3DDirection> = .init(value: .y)
        
        public var colorStops: GraphicMetadata<[Graphic.GradientStop]> = .init(value: .fixed([
            Graphic.GradientStop(at: 0.0, color: .black),
            Graphic.GradientStop(at: 1.0, color: .white),
        ]))
        
        public var position: GraphicMetadata<Point3D> = .init(options: .spatial)
        
        public var scale: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           maximum: .fixed(2.0))
        
        public var offset: GraphicMetadata<CGFloat> = .init(value: .fixed(0.0),
                                                            minimum: .fixed(-1.0))
        
        public var gamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           maximum: .fixed(2.0),
                                                           docs: "Adjustment of light.")
        
        public var extend: GraphicEnumMetadata<Graphic.GradientExtend> = .init(value: .zero,
                                                                               docs: "Property for what to do with values extending above 1.0 and below 0.0. This property has no effect until position, scale or offset are modified.")
        
        public func render(
            at resolution: Size3D,
            options: Graphic3D.ContentOptions
        ) async throws -> Graphic3D {

            try await .gradient(
                direction: direction.value,
                stops: colorStops.value.eval(at: resolution),
                position: position.value.eval(at: resolution),
                scale: scale.value.eval(at: resolution),
                offset: offset.value.eval(at: resolution),
                extend: extend.value,
                gamma: gamma.value.eval(at: resolution),
                resolution: resolution,
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case x
            case y
            case z
            case radial
        }

        public func edit(variant: Variant) {
            switch variant {
            case .x:
                direction.value = .x
            case .y:
                direction.value = .y
            case .z:
                direction.value = .z
            case .radial:
                direction.value = .radial
            }
        }
    }
}
