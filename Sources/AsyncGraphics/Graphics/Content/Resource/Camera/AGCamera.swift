import CoreGraphics
import CoreGraphicsExtensions
import AVKit

public struct AGCamera: AGGraph {
    
    let position: Graphic.CameraPosition
    
    var placement: Placement = .center
    
    public init(_ position: Graphic.CameraPosition) {
        self.position = position
    }
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        guard let cameraResolution: CGSize = specification.resourceResolutions.camera[position]
        else { return .auto }
        switch placement {
        case .fit:
            return AGResolution(cameraResolution.place(in: specification.resolution, placement: .fit))
        case .fill:
            return AGResolution(cameraResolution.place(in: specification.resolution, placement: .fill))
        case .center:
            return AGResolution(cameraResolution)
        case .stretch:
            return .auto
        }
    }
    
//    func resolution() -> CGSize {
//        
//    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        guard let cameraGraphic: Graphic = details.resources.cameraGraphics[position] else {
            return try await .color(.black, resolution: details.specification.resolution)
        }
        let resolution: CGSize = contentResolution(with: details.specification)
            .fallback(to: details.specification.resolution)
        return try await cameraGraphic.resized(to: resolution, placement: .stretch, method: .lanczos)
    }
}

extension AGCamera {
    
    public func resizable() -> AGCamera {
        var image: AGCamera = self
        image.placement = .stretch
        return image
    }
}

extension AGCamera {
    
    public func aspectRatio(contentMode: AGContentMode) -> AGCamera {
        var image: AGCamera = self
        switch contentMode {
        case .fit:
            image.placement = .fit
        case .fill:
            image.placement = .fill
        }
        return image
    }
}

extension AGCamera: Equatable {

    public static func == (lhs: AGCamera, rhs: AGCamera) -> Bool {
        guard lhs.position == rhs.position else { return false }
        guard lhs.placement == rhs.placement else { return false }
        return true
    }
}

extension AGCamera: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(placement)
    }
}
