import SwiftUI

@GraphicTypeMacro
public enum ColorEffectGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case channelMix
    case range
    case clamp
    case colorMap
    case colorShift
    case gradientLookup
    case levels
    case quantize
    case slope
    case threshold
}

extension ColorEffectGraphic3DType {
    
    public var symbolName: String {
        switch self {
        case .channelMix:
            "square.stack.3d.forward.dottedline"
        case .range:
            "rectangle.compress.vertical"
        case .clamp:
            "rectangle.compress.vertical"
        case .colorMap:
            "circle.lefthalf.filled.righthalf.striped.horizontal.inverse"
        case .colorShift:
            "arrow.triangle.2.circlepath.circle"
        case .gradientLookup:
            "circle.and.line.horizontal"
        case .levels:
            "slider.horizontal.3"
        case .quantize:
            "righttriangle.split.diagonal"
        case .slope:
            "righttriangle"
        case .threshold:
            "circle.lefthalf.filled"
        }
    }
}

extension ColorEffectGraphic3DType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .channelMix:
                .advanced
        case .range:
                .advanced
        case .clamp:
                .advanced
        case .colorMap:
                .basic
        case .colorShift:
                .basic
        case .gradientLookup:
                .basic
        case .levels:
                .basic
        case .quantize:
                .basic
        case .slope:
                .advanced
        case .threshold:
                .basic
        }
    }
}
