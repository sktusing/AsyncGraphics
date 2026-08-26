//
//  Sample3D.metal
//  AsyncGraphics
//
//  Created on 2026-08-26.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    packed_float3 location;
};

kernel void sampleVoxel(const device Uniforms& uniforms [[buffer(0)]],
                        texture3d<float, access::write> targetTexture [[texture(0)]],
                        texture3d<float, access::sample> texture [[texture(1)]],
                        uint3 pos [[thread_position_in_grid]],
                        sampler sampler [[sampler(0)]]) {
    uint width = targetTexture.get_width();
    uint height = targetTexture.get_height();
    uint depth = targetTexture.get_depth();

    if (pos.x >= width || pos.y >= height || pos.z >= depth) {
        return;
    }

    float3 resolution = float3(texture.get_width(), texture.get_height(), texture.get_depth());
    float3 uvw = (uniforms.location + 0.5) / resolution;
    float4 color = texture.sample(sampler, uvw);
    targetTexture.write(color, pos);
}
