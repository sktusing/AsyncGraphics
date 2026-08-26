import CoreGraphics
import PixelColor
import Testing
@testable import AsyncGraphics

@Suite("Sample")
struct SampleTests {

    @Test("Graphic: Interpolate a subpixel on the GPU")
    func subPixelUsesBilinearInterpolation() async throws {
        let graphic: Graphic = try .pixels(
            [
                [
                    PixelColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0),
                    PixelColor(red: 0.0, green: 1.0, blue: 0.0, opacity: 0.0),
                ],
                [
                    PixelColor(red: 0.0, green: 0.0, blue: 1.0, opacity: 0.0),
                    PixelColor(red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0),
                ],
            ]
        )

        let color: PixelColor = try await graphic.subPixel(x: 0.25, y: 0.75)

        #expect(abs(color.red - 0.1875) < 0.001)
        #expect(abs(color.green - 0.0625) < 0.001)
        #expect(abs(color.blue - 0.5625) < 0.001)
        #expect(abs(color.opacity - 0.1875) < 0.001)
    }

    @Test("Graphic3D: Interpolate a subvoxel on the GPU")
    func subVoxelUsesTrilinearInterpolation() async throws {
        let graphic: Graphic3D = try .voxels(
            [
                [
                    [
                        PixelColor(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.0),
                        PixelColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0),
                    ],
                    [
                        PixelColor(red: 0.0, green: 1.0, blue: 0.0, opacity: 0.0),
                        PixelColor(red: 1.0, green: 1.0, blue: 0.0, opacity: 0.0),
                    ],
                ],
                [
                    [
                        PixelColor(red: 0.0, green: 0.0, blue: 1.0, opacity: 0.0),
                        PixelColor(red: 1.0, green: 0.0, blue: 1.0, opacity: 0.0),
                    ],
                    [
                        PixelColor(red: 0.0, green: 1.0, blue: 1.0, opacity: 0.0),
                        PixelColor(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0),
                    ],
                ],
            ],
            options: .bit32
        )

        let sampledColor: PixelColor = try await graphic.subVoxel(x: 0.25, y: 0.5, z: 0.75)

        #expect(abs(sampledColor.red - 0.25) < 0.001)
        #expect(abs(sampledColor.green - 0.5) < 0.001)
        #expect(abs(sampledColor.blue - 0.75) < 0.001)
        #expect(abs(sampledColor.opacity - 0.09375) < 0.001)
    }
}
