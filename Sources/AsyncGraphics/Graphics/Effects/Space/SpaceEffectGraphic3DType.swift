import SwiftUI

@GraphicTypeMacro
public enum SpaceEffectGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case blur
    case edge
    case transform
}

extension SpaceEffectGraphic3DType {
    
    public var symbolName: String {
        switch self {
        case .blur:
            "aqi.medium"
        case .edge:
            "square"
        case .transform:
            "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        }
    }
}

extension SpaceEffectGraphic3DType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .blur:
                .basic
        case .edge:
                .basic
        case .transform:
                .basic
        }
    }
}
