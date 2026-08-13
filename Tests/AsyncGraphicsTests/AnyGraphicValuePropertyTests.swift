import CoreGraphics
import Testing
@testable import AsyncGraphics

struct AnyGraphicValuePropertyTests {

    @Test
    func testErasePropagatesEncodingFailure() {
        let property = GraphicValueProperty<CGFloat>(
            wrappedValue: GraphicMetadata<CGFloat>(value: .fixed(.nan)),
            key: "value",
            name: "Value"
        )

        do {
            _ = try property.erase()
            Issue.record("Expected property erasure to throw an encoding error.")
        } catch {
            assertInvalidValueEncodingError(error)
        }
    }

    private func assertInvalidValueEncodingError(_ error: any Error) {
        guard let encodingError = error as? EncodingError else {
            Issue.record("Expected EncodingError, received \(error).")
            return
        }
        guard case .invalidValue = encodingError else {
            Issue.record("Expected EncodingError.invalidValue, received \(encodingError).")
            return
        }
    }
}
