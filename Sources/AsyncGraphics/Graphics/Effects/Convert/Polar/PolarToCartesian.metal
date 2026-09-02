//
//  PolarToCartesian.metal
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

fragment float4 polarToCartesian(VertexOut out [[stage_in]],
                                 texture2d<float> texture [[ texture(0) ]],
                                 const device Uniforms& uniforms [[ buffer(0) ]],
                                 sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    
    uint width = texture.get_width();
    uint height = texture.get_height();
    float aspectRatio = float(width) / float(height);
    
    float x = (u - 0.5) * aspectRatio;
    float y = v - 0.5;
    
    // The radius is one at half the height.
    float radius = length(float2(x, y)) / 0.5;
    if (radius > 1.0) {
        return 0.0;
    }
    
    // The angle is a fraction of a full turn, offset by the start angle.
    float angle = atan2(y, x) / (pi * 2) - uniforms.startAngle;
    angle -= floor(angle);
    
    return texture.sample(sampler, float2(angle, radius));
}
