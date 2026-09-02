import SwiftUI

@GraphicTypeMacro
public enum ConvertEffectGraphicType: String, CodableGraphicTypeProtocol {
    
    case resolution
    case bits
    case cornerPin
    case crop
    case frameCrop
    case equirectToCubeMap
    case cubeMapToEquirect
}

extension ConvertEffectGraphicType {
    
    public var symbolName: String {
        switch self {
        case .resolution:
            "square.resize"
        case .bits:
            "drop.keypad.rectangle"
        case .cornerPin:
            "skew"
        case .crop:
            "crop"
        case .frameCrop:
            "crop"
        case .equirectToCubeMap:
            "cube.transparent"
        case .cubeMapToEquirect:
            "globe"
        }
    }
}

extension ConvertEffectGraphicType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .resolution:
                .basic
        case .bits:
                .advanced
        case .cornerPin:
                .basic
        case .crop:
                .basic
        case .frameCrop:
                .advanced
        case .equirectToCubeMap:
                .advanced
        case .cubeMapToEquirect:
                .advanced
        }
    }
}
