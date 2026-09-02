//
//  CartesianToPolar.metal
//  AsyncGraphics
//
//  Created by Anton Heestand on 2026-09-02.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    float startAngle;
};

fragment float4 cartesianToPolar(VertexOut out [[stage_in]],
                                 texture2d<float> texture [[ texture(0) ]],
                                 const device Uniforms& uniforms [[ buffer(0) ]],
                                 sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    uint width = texture.get_width();
    uint height = texture.get_height();
    float aspectRatio = float(width) / float(height);
    
    // The horizontal axis is a full turn, starting at the start angle.
    float angle = (u + uniforms.startAngle) * pi * 2;
    
    // The vertical axis is the radius, one is half the height.
    float radius = v * 0.5;
    
    float2 uv = float2(cos(angle) * radius / aspectRatio,
                       sin(angle) * radius) + 0.5;
    
    return texture.sample(sampler, uv);
}
