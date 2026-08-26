//
//  Sample.metal
//  AsyncGraphics
//
//  Created on 2026-08-26.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    packed_float2 location;
};

fragment float4 samplePixel(VertexOut out [[stage_in]],
                            texture2d<float> texture [[texture(0)]],
                            const device Uniforms& uniforms [[buffer(0)]],
                            sampler sampler [[sampler(0)]]) {
    float2 resolution = float2(texture.get_width(), texture.get_height());
    float2 uv = (uniforms.location + 0.5) / resolution;
    return texture.sample(sampler, uv);
}
