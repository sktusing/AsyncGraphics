import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Shape {
    
    @GraphicMacro
    public final class Circle: ShapeContentGraphicProtocol {
        
        public var position: GraphicMetadata<CGPoint> = .init(options: .spatial)
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.5),
                                                            maximum: .resolutionMaximum(fraction: 0.5),
                                                            options: .spatial)
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        public var isStroked: GraphicMetadata<Bool> = .init(value: .fixed(false))
        public var lineWidth: GraphicMetadata<CGFloat> = .init(value: .fixed(10.0),
                                                               maximum: .fixed(20.0),
                                                               options: .spatial)
        
        public var premultiply: GraphicMetadata<Bool> = .init(value: .fixed(true))
        
        private func premultiplyOptions(
            at resolution: CGSize,
            options: Graphic.ContentOptions
        ) -> Graphic.ContentOptions {
            var options = options
            if premultiply.value.eval(at: resolution) {
                options.remove(.pureAlpha)
            } else {
                options.insert(.pureAlpha)
            }
            return options
        }
        
        public func render(
            at resolution: CGSize,
            options: Graphic.ContentOptions = []
        ) async throws -> Graphic {
            
            if isStroked.value.eval(at: resolution) {
                
                try await .strokedCircle(
                    radius: radius.value.eval(at: resolution),
                    position: position.value.eval(at: resolution),
                    lineWidth: lineWidth.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: premultiplyOptions(at: resolution, options: options))
                
            } else {
                
                try await .circle(
                    radius: radius.value.eval(at: resolution),
                    position: position.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: premultiplyOptions(at: resolution, options: options))
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }

        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                radius.value = .resolutionMinimum(fraction: 0.25)
            }
        }
    }
}
