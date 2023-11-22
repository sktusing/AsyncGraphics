import CoreGraphics
import PixelColor

extension CodableGraphic3D {
    
    @GraphicMacro
    public class Color: SolidGraphic3DProtocol {
        
        public var type: CodableGraphic3DType {
            .content(.solid(.color))
        }
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public func render(
            at resolution: SIMD3<Int>,
            options: AsyncGraphics.Graphic3D.ContentOptions = []
        ) async throws -> Graphic3D {
            try await .color(
                color.value.at(resolution: resolution),
                resolution: resolution,
                options: options)
        }
    }
}