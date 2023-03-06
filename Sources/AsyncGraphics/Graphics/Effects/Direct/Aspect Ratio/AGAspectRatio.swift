import CoreGraphics

extension AGGraph {
    
    public func aspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: AGContentMode) -> any AGGraph {
        AGAspectRatio(graph: self, aspectRatio: aspectRatio, contentMode: contentMode)
    }
    
    public func aspectRatio(_ aspectRatio: CGSize, contentMode: AGContentMode) -> any AGGraph {
        AGAspectRatio(graph: self, aspectRatio: aspectRatio.width / aspectRatio.height, contentMode: contentMode)
    }
}

public struct AGAspectRatio: AGParentGraph {
   
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    
    let aspectRatio: CGFloat?
    let contentMode: AGContentMode
    
    private var placement: Placement {
        switch contentMode {
        case .fit:
            return .fit
        case .fill:
            return .fill
        }
    }
    
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        if let aspectRatio {
            return CGSize(width: aspectRatio, height: 1.0)
                .place(in: proposedResolution, placement: placement)
        }
        return graph.resolution(at: proposedResolution, for: specification)
            .place(in: proposedResolution, placement: placement)
    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let graphic: Graphic = try await graph.render(at: resolution, details: details)
        let backgroundGraphic: Graphic = try await .color(.clear, resolution: resolution)
        return try await backgroundGraphic.blended(with: graphic,
                                                   blendingMode: .over,
                                                   placement: placement)
    }
}

extension AGAspectRatio: Equatable {

    public static func == (lhs: AGAspectRatio, rhs: AGAspectRatio) -> Bool {
        guard lhs.aspectRatio == rhs.aspectRatio else { return false }
        guard lhs.contentMode == rhs.contentMode else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGAspectRatio: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(aspectRatio)
        hasher.combine(contentMode)
        hasher.combine(graph)
    }
}
