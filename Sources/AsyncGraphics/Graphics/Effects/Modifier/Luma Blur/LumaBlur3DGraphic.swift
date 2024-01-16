import SwiftUI
import Spatial
import CoreGraphics

extension CodableGraphic3D.Effect.Modifier {
    
    @GraphicMacro
    public final class LumaBlur: ModifierEffectGraphic3DProtocol {
        
        public var style: GraphicEnumMetadata<Graphic3D.LumaBlur3DType> = .init(value: .box)
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            maximum: .resolutionMinimum(fraction: 0.5),
                                                            options: .spatial)
        
        public var position: GraphicMetadata<Point3D> = .init(options: .spatial)
        
        public var lumaGamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(2.0))
        
        public var sampleCount: GraphicMetadata<Int> = .init(value: .fixed(100),
                                                             minimum: .fixed(1),
                                                             maximum: .fixed(100))
        
        public func render(
            with graphic: Graphic3D,
            modifier modifierGraphic: Graphic3D,
            options: Graphic3D.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic3D {
           
            switch style.value {
            case .box:
                
                try await graphic.lumaBlurredBox(
                    with: modifierGraphic,
                    radius: radius.value.eval(at: graphic.resolution),
                    lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                    sampleCount: sampleCount.value.eval(at: graphic.resolution),
                    options: options)
                
            case .zoom:
                
                try await graphic.lumaBlurredZoom(
                    with: modifierGraphic,
                    radius: radius.value.eval(at: graphic.resolution),
                    position: position.value.eval(at: graphic.resolution),
                    lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                    sampleCount: sampleCount.value.eval(at: graphic.resolution),
                    options: options)
                
            case .random:
                
                try await graphic.lumaBlurredRandom(
                    with: modifierGraphic,
                    radius: radius.value.eval(at: graphic.resolution),
                    lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                    options: options)
            }
        }
        
        public func isVisible(property: Property, at resolution: CGSize) -> Bool {
            switch property {
            case .style:
                true
            case .radius:
                true
            case .position:
                style.value == .zoom
            case .sampleCount:
                style.value != .random
            case .lumaGamma:
                true
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case light
            case medium
            case heavy
            case zoom
            case random
        }

        public func edit(variant: Variant) {
            switch variant {
            case .light, .medium, .heavy:
                style.value = .box
            case .zoom:
                style.value = .zoom
            case .random:
                style.value = .random
            }
            switch variant {
            case .light:
                radius.value = .resolutionMinimum(fraction: 1.0 / 32)
            case .medium:
                radius.value = .resolutionMinimum(fraction: 1.0 / 16)
            case .heavy:
                radius.value = .resolutionMinimum(fraction: 1.0 / 8)
            case .zoom:
                radius.value = .resolutionMinimum(fraction: 1.0 / 8)
            case .random:
                break
            }
        }
    }
}