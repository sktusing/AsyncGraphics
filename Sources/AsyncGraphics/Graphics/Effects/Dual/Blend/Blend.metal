//
//  Created by Anton Heestand on 2017-11-10.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "../../../../Metal/Effects/blend_header.metal"
#import "../../../../Metal/Effects/place_header.metal"

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms {
    int blendingMode;
    int placement;
};

fragment float4 blend(VertexOut out [[stage_in]],
                      texture2d<float>  leadingTexture [[ texture(0) ]],
                      texture2d<float>  trailingTexture [[ texture(1) ]],
                      const device Uniforms& uniforms [[ buffer(0) ]],
                      sampler sampler [[ sampler(0) ]]) {
    
    float pi = M_PI_F;
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
        
    float4 leadingColor = leadingTexture.sample(sampler, uv);
    
    uint leadingWidth = leadingTexture.get_width();
    uint leadingHeight = leadingTexture.get_height();
    uint trailingWidth = trailingTexture.get_width();
    uint trailingHeight = trailingTexture.get_height();
    float2 uvPlacement = place(uniforms.placement, uv, leadingWidth, leadingHeight, trailingWidth, trailingHeight);
    
    float4 trailingColor = trailingTexture.sample(sampler, uvPlacement);
    
    float4 color = blend(uniforms.blendingMode, leadingColor, trailingColor);
    
    return color;
}