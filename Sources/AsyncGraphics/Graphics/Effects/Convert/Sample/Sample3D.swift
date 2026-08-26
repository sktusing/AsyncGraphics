//
//  Created by Anton Heestand on 2022-04-11.
//

import Foundation
import Spatial
import SpatialExtensions
import TextureMap
import PixelColor

extension Graphic3D {
    
    enum SubVoxelError: LocalizedError {
        case voxelLocationOutOfBounds
        var errorDescription: String? {
            switch self {
            case .voxelLocationOutOfBounds:
                "Sub voxel location is out of bounds."
            }
        }
    }
    
        /// Sample at a `location` coordinate, if the coordinate is fractional nearest voxels will be interpolated.
        ///
        /// Origin is at far top left.
    public func subVoxel(at location: Point3D) async throws -> PixelColor {
        try await subVoxel(x: location.x, y: location.y, z: location.z)
    }
    
        /// Sample at an `x`, `y` and `z` coordinate, if the coordinate is fractional nearest voxels will be interpolated.
        ///
        /// Origin is at far top left.
    public func subVoxel(x: CGFloat, y: CGFloat, z: CGFloat) async throws -> PixelColor {
        try await subVoxel(u: x / (resolution.width - 1.0),
                           v: y / (resolution.height - 1.0),
                           w: z / (resolution.depth - 1.0))
    }
    
        /// Sample at relative `uvw` coordinates
        ///
        /// `u` is horizontal, `v` is vertical, `w` is depth, between `0.0` and `1.0`.
        ///
        /// Origin is at top left.
    public func subVoxel(u: CGFloat, v: CGFloat, w: CGFloat) async throws -> PixelColor {
        guard u >= 0.0, u <= 1.0, v >= 0.0, v <= 1.0, w >= 0.0, w <= 1.0 else {
            throw SubVoxelError.voxelLocationOutOfBounds
        }
        let uvw = Point3D(x: u, y: v, z: w)
        let location: Point3D = uvw * (resolution - 1.0) + 0.5
        let x = Int(location.x)
        let y = Int(location.y)
        let z = Int(location.z)
        if CGFloat(x) == location.x - 0.5,
           CGFloat(y) == location.y - 0.5,
           CGFloat(z) == location.z - 0.5 {
            return try await voxel(x: x, y: y, z: z)
        }
        let width = Int(resolution.width)
        let height = Int(resolution.height)
        let depth = Int(resolution.depth)
        let subVoxelOffset: Point3D = location - Point3D(
            x: CGFloat(x),
            y: CGFloat(y),
            z: CGFloat(z)
        )
        let farTopLeftVoxelColor: PixelColor = try await voxel(
            x: x,
            y: y,
            z: z
        )
        let farTopRightVoxelColor: PixelColor = try await voxel(
            x: min(x + 1, width - 1),
            y: y,
            z: z
        )
        let farBottomLeftVoxelColor: PixelColor = try await voxel(
            x: x,
            y: min(y + 1, height - 1),
            z: z
        )
        let farBottomRightVoxelColor: PixelColor = try await voxel(
            x: min(x + 1, width - 1),
            y: min(y + 1, height - 1),
            z: z
        )
        let farTopVoxelColor: PixelColor = farTopLeftVoxelColor * (1.0 - subVoxelOffset.x) + farTopRightVoxelColor * subVoxelOffset.x
        let farBottomVoxelColor: PixelColor = farBottomLeftVoxelColor * (1.0 - subVoxelOffset.x) + farBottomRightVoxelColor * subVoxelOffset.x
        let farVoxelColor: PixelColor = farTopVoxelColor * (1.0 - subVoxelOffset.y) + farBottomVoxelColor * subVoxelOffset.y
        let nearTopLeftVoxelColor: PixelColor = try await voxel(
            x: x,
            y: y,
            z: min(z + 1, depth - 1)
        )
        let nearTopRightVoxelColor: PixelColor = try await voxel(
            x: min(x + 1, width - 1),
            y: y,
            z: min(z + 1, depth - 1)
        )
        let nearBottomLeftVoxelColor: PixelColor = try await voxel(
            x: x,
            y: min(y + 1, height - 1),
            z: min(z + 1, depth - 1)
        )
        let nearBottomRightVoxelColor: PixelColor = try await voxel(
            x: min(x + 1, width - 1),
            y: min(y + 1, height - 1),
            z: min(z + 1, depth - 1)
        )
        let nearTopVoxelColor: PixelColor = nearTopLeftVoxelColor * (1.0 - subVoxelOffset.x) + nearTopRightVoxelColor * subVoxelOffset.x
        let nearBottomVoxelColor: PixelColor = nearBottomLeftVoxelColor * (1.0 - subVoxelOffset.x) + nearBottomRightVoxelColor * subVoxelOffset.x
        let nearVoxelColor: PixelColor = nearTopVoxelColor * (1.0 - subVoxelOffset.y) + nearBottomVoxelColor * subVoxelOffset.y
        return farVoxelColor * (1.0 - subVoxelOffset.z) + nearVoxelColor * subVoxelOffset.z
    }
}

extension Graphic3D {
    
    /// Sample
    ///
    /// Fraction 0.0 is the first plane
    ///
    /// Fraction 1.0 is the last plane
    public func sample(fraction: Double/*, axis: Axis = .z*/) async throws -> Graphic {
        
        let axis: Axis = .z
        
        let index: Int = {
            switch axis {
            case .x:
                return Int(round(fraction * resolution.width - 1.0))
            case .y:
                return Int(round(fraction * resolution.height - 1.0))
            case .z:
                return Int(round(fraction * resolution.depth - 1.0))
            }
        }()
        
        return try await sample(index: index/*, axis: axis*/)
    }
    
    public func sample(index: Int/*, axis: Axis = .z*/) async throws -> Graphic {
        
        let axis: Axis = .z
        
        let texture = try await texture.sample3d(index: index, axis: axis.tmAxis, bits: bits)
        
        return Graphic(name: "Sample", texture: texture, bits: bits, colorSpace: colorSpace)
    }
    
    public struct SampleProgress: Sendable {
        public let index: Int
        public let count: Int
        public var fraction: CGFloat {
            CGFloat(index) / CGFloat(count - 1)
        }
        actor Manager: Sendable {
            private let count: Int
            private var index: Int = 0
            private let progress: @Sendable (SampleProgress) async -> ()
            init(count: Int, progress: @escaping @Sendable (SampleProgress) async -> ()) {
                self.count = count
                self.progress = progress
            }
            func increment() async {
                await progress(SampleProgress(index: index, count: count))
                index += 1
            }
        }
    }
    
    public func samples(/*axis: Axis = .z*/progress: (@Sendable (SampleProgress) async -> ())? = nil) async throws -> [Graphic] {
        
        let axis: Axis = .z
        
        let count: Int = {
            switch axis {
            case .x:
                return Int(resolution.width)
            case .y:
                return Int(resolution.height)
            case .z:
                return Int(resolution.depth)
            }
        }()
        
        let progressManager: SampleProgress.Manager? = if let progress {
            SampleProgress.Manager(count: count, progress: progress)
        } else { nil }
        
        let graphics: [Graphic] = try await withThrowingTaskGroup(of: (Int, Graphic).self) { group in
            
            for index in 0..<count {
                group.addTask {
                    let graphic: Graphic = try await self.sample(index: index/*, axis: axis*/)
                    await progressManager?.increment()
                    return (index, graphic)
                }
            }
            
            var graphics: [(Int, Graphic)] = []
            
            for try await (index, graphic) in group {
                graphics.append((index, graphic))
            }
            
            return graphics
                .sorted(by: { leadingPack, trailingPack in
                    leadingPack.0 < trailingPack.0
                })
                .map(\.1)
        }
        
        return graphics
    }
}
