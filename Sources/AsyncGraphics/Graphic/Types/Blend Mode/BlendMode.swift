//
//  Created by Anton Heestand on 2022-04-03.
//

@available(*, deprecated, renamed: "Graphic.BlendMode")
typealias BlendingMode = Graphic.BlendMode

@available(*, deprecated, renamed: "Graphic.BlendMode")
typealias AGBlendMode = Graphic.BlendMode

extension Graphic {
    
    @EnumMacro
    public enum BlendMode: String, GraphicEnum {
        
        case over
        case overWithAlpha
        case under
        case screen
        case lighten
        case darken
        case darkenWithoutAlpha
        case add
        case addWithAlpha
        case multiply
        case multiplyWithoutAlpha
        case difference
        case differenceWithAlpha
        case subtract
        case subtractWithAlpha
        case maximum
        case minimum
        case gamma
        case power
        case divide
        case average
        case cosine
        case inside
        case outside
        case exclusiveOr
        
        var rawIndex: UInt32 {
            switch self {
            case .over: return 0
            case .overWithAlpha: return 25
            case .under: return 1
            case .screen: return 18
            case .lighten: return 19
            case .darken: return 20
            case .darkenWithoutAlpha: return 21
            case .add: return 2
            case .addWithAlpha: return 3
            case .multiply: return 4
            case .multiplyWithoutAlpha: return 23
            case .difference: return 5
            case .differenceWithAlpha: return 24
            case .subtract: return 6
            case .subtractWithAlpha: return 7
            case .maximum: return 8
            case .minimum: return 9
            case .gamma: return 10
            case .power: return 11
            case .divide: return 12
            case .average: return 13
            case .cosine: return 14
            case .inside: return 15
            case .outside: return 16
            case .exclusiveOr: return 17
            }
        }
    }
}
