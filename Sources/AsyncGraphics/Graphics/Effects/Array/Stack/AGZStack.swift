import CoreGraphics

public struct AGZStack: AGGraph {
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.ZStackAlignment
    
    public init(alignment: Graphic.ZStackAlignment = .center,
                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.graphs = graphs()
    }
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        let width: CGFloat? = {
            var totalWidth: CGFloat = 0.0
            for graph in graphs.all {
                if let width = graph.contentResolution(in: containerResolution).width {
                    totalWidth = max(totalWidth, width)
                } else {
                    return nil
                }
            }
            return totalWidth
        }()
        let height: CGFloat? = {
            var totalHeight: CGFloat = 0.0
            for graph in graphs.all {
                if let height = graph.contentResolution(in: containerResolution).height {
                    totalHeight = max(totalHeight, height)
                } else {
                    return nil
                }
            }
            return totalHeight
        }()
        return AGResolution(width: width, height: height)
    }
    
    public func render(in containerResolution: CGSize) async throws -> Graphic {
        guard !graphs.isEmpty else {
            return try await .color(.clear, resolution: containerResolution)
        }
        var graphics: [Graphic] = []
        for graph in graphs.all {
            let graphic: Graphic = try await graph.render(in: containerResolution)
            graphics.append(graphic)
        }
        return try await Graphic.zStacked(with: graphics, alignment: alignment)
    }
}

extension AGZStack: Equatable {

    public static func == (lhs: AGZStack, rhs: AGZStack) -> Bool {
        guard lhs.graphs.count == rhs.graphs.count else { return false }
        for (lhsAGGraphic, rhsAGGraphic) in zip(lhs.graphs, rhs.graphs) {
            guard lhsAGGraphic.isEqual(to: rhsAGGraphic) else { return false }
        }
        return true
    }
}

extension AGZStack: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        for graph in graphs {
            hasher.combine(graph)
        }
    }
}
