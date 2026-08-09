import Foundation
import SwiftUI
import Testing
@testable import AsyncGraphics

@Suite("Angle Codable")
struct AngleCodableTests {

    @Test
    func encodingUsesRadians() throws {
        let angle: Angle = .degrees(60.0)

        let data = try JSONEncoder().encode(angle)
        let encodedValue = try JSONDecoder().decode(Double.self, from: data)

        #expect(abs(encodedValue - .pi / 3.0) < 0.000_000_000_001)
    }

    @Test
    func decodingUsesRadians() throws {
        let encodedValue = -2.75
        let data = try JSONEncoder().encode(encodedValue)

        let angle = try JSONDecoder().decode(Angle.self, from: data)

        #expect(abs(angle.radians - encodedValue) < 0.000_000_000_001)
    }

    @Test(arguments: [-7.125, -Double.pi / 3.0, 0.0, Double.pi / 7.0, 11.5])
    func roundTripPreservesRadians(_ radians: Double) throws {
        let angle: Angle = .radians(radians)

        let data = try JSONEncoder().encode(angle)
        let decodedAngle = try JSONDecoder().decode(Angle.self, from: data)

        #expect(abs(decodedAngle.radians - radians) < 0.000_000_000_001)
    }
}
