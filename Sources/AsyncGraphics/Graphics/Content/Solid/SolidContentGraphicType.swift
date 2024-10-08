import SwiftUI

@GraphicTypeMacro
public enum SolidContentGraphicType: String, CodableGraphicTypeProtocol {
    
    case color
    case gradient
    case noise
}

extension SolidContentGraphicType {
    
    public var symbolName: String {
        switch self {
        case .color:
            "paintpalette"
        case .gradient:
            "circle.and.line.horizontal"
        case .noise:
            "water.waves"
        }
    }
}

extension SolidContentGraphicType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .color:
                .basic
        case .gradient:
                .basic
        case .noise:
                .basic
        }
    }
}
