import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGCircle: AGGraph {
    
    var lineWidth: CGFloat?
    
    public init() { }
    
    @MainActor
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        .one.place(in: proposedResolution, placement: .fit)
    }
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        if let lineWidth {
            var radius: CGFloat = min(resolution.width, resolution.height) / 2
            radius -= lineWidth / 2
            return try await .strokedCircle(radius: radius,
                                            lineWidth: lineWidth,
                                            color: details.color,
                                            backgroundColor: .clear,
                                            resolution: resolution)
        } else {
            return try await .circle(color: details.color,
                                     backgroundColor: .clear,
                                     resolution: resolution)
        }
    }
}

extension AGCircle {
    
    @MainActor
    public func strokeBorder(lineWidth: CGFloat = 1.0) -> AGCircle {
        var circle: AGCircle = self
        circle.lineWidth = lineWidth * .pixelsPerPoint
        return circle
    }
}
