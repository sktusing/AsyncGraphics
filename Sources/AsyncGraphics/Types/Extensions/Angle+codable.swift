import SwiftUI

@available(iOS, introduced: 17.0, obsoleted: 26.0)
@available(macOS, introduced: 14.0, obsoleted: 26.0)
@available(tvOS, introduced: 17.0, obsoleted: 26.0)
@available(watchOS, introduced: 10.0, obsoleted: 26.0)
@available(visionOS, introduced: 1.0, obsoleted: 26.0)
extension Angle: @retroactive Decodable, @retroactive Encodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = .radians(try container.decode(Double.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(radians)
    }
}
