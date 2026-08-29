import Foundation
import PixelColor
import TextureMap
import Testing
@testable import AsyncGraphics

@Suite("Image File Round Trip", .serialized)
struct ImageFileRoundTripTests {

    // MARK: Bits

    @Test("PNG: 8 bit graphics stay 8 bit")
    func pngKeepsEightBits() async throws {
        let graphic: Graphic = try Self.testGraphic(options: [])
        let loaded: Graphic = try await Graphic.image(data: try await graphic.pngData)
        #expect(loaded.bits == TMBits._8)
    }

    @Test("PNG: 32 bit graphics fall back to 16 bit")
    func pngFallsBackToSixteenBits() async throws {
        let graphic: Graphic = try Self.testGraphic(options: .bit32)
        let loaded: Graphic = try await Graphic.image(data: try await graphic.pngData)
        #expect(loaded.bits == TMBits._16, "PNG stores at most 16 bits per component")
    }

    @Test("TIFF: 32 bit graphics stay 32 bit")
    func tiffKeepsThirtyTwoBits() async throws {
        let graphic: Graphic = try Self.testGraphic(options: .bit32)
        let loaded: Graphic = try await Graphic.image(data: try await graphic.tiffData)
        #expect(loaded.bits == TMBits._32)
    }

    @Test("EXR: 32 bit graphics stay 32 bit")
    func exrKeepsThirtyTwoBits() async throws {
        let graphic: Graphic = try Self.testGraphic(options: .bit32)
        let loaded: Graphic = try await Graphic.image(data: try await graphic.exrData)
        #expect(loaded.bits == TMBits._32)
    }

    @Test("EXR: 8 bit graphics are promoted to 16 bit half float")
    func exrPromotesEightBits() async throws {
        let graphic: Graphic = try Self.testGraphic(options: [])
        let loaded: Graphic = try await Graphic.image(data: try await graphic.exrData)
        #expect(loaded.bits == TMBits._16, "OpenEXR has no 8 bit encoding")
    }

    @Test("JPEG: every graphic is stored as 8 bit")
    func jpegIsAlwaysEightBits() async throws {
        let graphic: Graphic = try Self.testGraphic(options: .bit32)
        let loaded: Graphic = try await Graphic.image(
            data: try await graphic.jpegData(compressionQuality: 1.0)
        )
        #expect(loaded.bits == TMBits._8)
    }

    // MARK: Color Space

    @Test("EXR: loads back in a linear color space")
    func exrLoadsLinear() async throws {
        let graphic: Graphic = try Self.testGraphic(options: .bit32)
        #expect(graphic.colorSpace == .nonLinearSRGB)
        let loaded: Graphic = try await Graphic.image(data: try await graphic.exrData)
        #expect(loaded.colorSpace == .linearSRGB, "OpenEXR is a scene referred linear container")
    }

    // MARK: Round Trip Difference

    @Test("TIFF: a 32 bit graphic round trips without a visible difference")
    func tiffRoundTripsThirtyTwoBitGraphics() async throws {
        let graphic: Graphic = try Self.testGraphic(options: .bit32)
        let loaded: Graphic = try await Graphic.image(data: try await graphic.tiffData)
        let difference: Float = try await Self.maximumDifference(graphic, loaded)
        #expect(difference < 0.001, "difference was \(difference)")
    }

    @Test("EXR: a linear 32 bit graphic round trips without a visible difference")
    func exrRoundTripsLinearGraphics() async throws {
        let graphic: Graphic = try Self.testGraphic(options: .bit32)
            .assignColorSpace(.linearSRGB)
        let loaded: Graphic = try await Graphic.image(data: try await graphic.exrData)
        let difference: Float = try await Self.maximumDifference(graphic, loaded)
        #expect(difference < 0.001, "difference was \(difference)")
    }

    @Test("EXR: a non linear graphic round trips as its linear equivalent")
    func exrRoundTripsNonLinearGraphicsAsLinear() async throws {
        let graphic: Graphic = try Self.testGraphic(options: .bit32)
        let loaded: Graphic = try await Graphic.image(data: try await graphic.exrData)
        let linear: Graphic = try await graphic.convertColorSpace(
            from: .nonLinearSRGB,
            to: .linearSRGB
        )
        let difference: Float = try await Self.maximumDifference(linear, loaded)
        #expect(difference < 0.001, "difference was \(difference)")
    }

    // MARK: Premultiplied Alpha

    @Test("TIFF: translucent pixels keep their premultiplied alpha")
    func tiffKeepsPremultipliedAlpha() async throws {
        let graphic: Graphic = try Self.translucentGraphic()
        let loaded: Graphic = try await Graphic.image(data: try await graphic.tiffData)
        let difference: Float = try await Self.maximumDifference(graphic, loaded)
        #expect(difference < 0.001, "difference was \(difference)")
    }

    @Test("EXR: translucent pixels lose their premultiplied alpha")
    func exrLosesPremultipliedAlpha() async throws {
        let graphic: Graphic = try Self.translucentGraphic()
        let loaded: Graphic = try await Graphic.image(data: try await graphic.exrData)
        let linear: Graphic = try await graphic.convertColorSpace(
            from: .nonLinearSRGB,
            to: .linearSRGB
        )

        /// `OpenEXR` stores straight alpha, colors are divided by their alpha when written
        /// and are not multiplied back in when read, so translucent pixels come back brighter.
        let difference: Float = try await Self.maximumDifference(linear, loaded)
        withKnownIssue("Straight alpha is not premultiplied when an image is loaded") {
            #expect(difference < 0.001, "difference was \(difference)")
        }
    }

    @Test("PNG: translucent pixels lose their premultiplied alpha")
    func pngLosesPremultipliedAlpha() async throws {
        let graphic: Graphic = try Self.translucentGraphic()
        let loaded: Graphic = try await Graphic.image(data: try await graphic.pngData)

        /// `PNG` stores straight alpha, with the same loss as `OpenEXR`.
        let difference: Float = try await Self.maximumDifference(graphic, loaded)
        withKnownIssue("Straight alpha is not premultiplied when an image is loaded") {
            #expect(difference < 0.001, "difference was \(difference)")
        }
    }

    // MARK: High Dynamic Range

    @Test("EXR: values above 1.0 survive")
    func exrKeepsHighDynamicRange() async throws {
        let graphic: Graphic = try Self.highDynamicRangeGraphic()
        let loaded: Graphic = try await Graphic.image(data: try await graphic.exrData)
        let maximum: Float = try loaded.channels32.max() ?? 0.0
        #expect(maximum > 4.0, "maximum was \(maximum)")
    }

    @Test("TIFF: values above 1.0 survive")
    func tiffKeepsHighDynamicRange() async throws {
        let graphic: Graphic = try Self.highDynamicRangeGraphic()
        let loaded: Graphic = try await Graphic.image(data: try await graphic.tiffData)
        let maximum: Float = try loaded.channels32.max() ?? 0.0
        #expect(maximum > 4.0, "maximum was \(maximum)")
    }

    @Test("PNG: values above 1.0 are clamped")
    func pngClampsHighDynamicRange() async throws {
        let graphic: Graphic = try Self.highDynamicRangeGraphic()
        let loaded: Graphic = try await Graphic.image(data: try await graphic.pngData)
        let maximum: Float = try await loaded.withBits(.bit32).channels32.max() ?? 0.0
        #expect(maximum <= 1.001, "maximum was \(maximum)")
    }
}

// MARK: - Fixtures

extension ImageFileRoundTripTests {

    /// An opaque graphic covering the low, mid and high end of the range.
    private static func testGraphic(options: Graphic.ContentOptions) throws -> Graphic {
        try .pixels(
            [
                [
                    PixelColor(red: 0.0, green: 0.25, blue: 0.5, opacity: 1.0),
                    PixelColor(red: 0.75, green: 1.0, blue: 0.03, opacity: 1.0),
                ],
                [
                    PixelColor(red: 0.125, green: 0.5, blue: 0.875, opacity: 1.0),
                    PixelColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 1.0),
                ],
            ],
            options: options
        )
    }

    /// A 32 bit graphic with premultiplied translucent pixels, colors stay at or below their alpha.
    private static func translucentGraphic() throws -> Graphic {
        try .pixels(
            [[
                PixelColor(red: 0.375, green: 0.5, blue: 0.03, opacity: 0.5),
                PixelColor(red: 0.125, green: 0.2, blue: 0.25, opacity: 0.25),
            ]],
            options: .bit32
        )
    }

    /// A 32 bit graphic with values above 1.0.
    private static func highDynamicRangeGraphic() throws -> Graphic {
        try .pixels(
            [[
                PixelColor(red: 8.0, green: 0.5, blue: 0.125, opacity: 1.0),
                PixelColor(red: 0.25, green: 4.5, blue: 2.0, opacity: 1.0),
            ]],
            options: .bit32
        )
    }

    /// The largest difference between two graphics, channel by channel.
    private static func maximumDifference(
        _ leadingGraphic: Graphic,
        _ trailingGraphic: Graphic
    ) async throws -> Float {
        let leadingChannels: [Float] = try await leadingGraphic.withBits(.bit32).channels32
        let trailingChannels: [Float] = try await trailingGraphic.withBits(.bit32).channels32
        #expect(leadingChannels.count == trailingChannels.count)
        return zip(leadingChannels, trailingChannels)
            .map { abs($0 - $1) }
            .max() ?? 0.0
    }
}
