//
//  EquirectToCubeMap.metal
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
    bool inside;
};

fragment float4 equirectToCubeMap(VertexOut out [[stage_in]],
                                  texture2d<float> texture [[ texture(0) ]],
                                  const device Uniforms& uniforms [[ buffer(0) ]],
                                  sampler sampler [[ sampler(0) ]]) {

    float pi = M_PI_F;

    float columns = 4.0;
    float rows = 3.0;

    float u = out.texCoord[0];
    float v = out.texCoord[1];

    float column = floor(u * columns);
    float row = floor(v * rows);

    float2 local = float2(u * columns - column, v * rows - row);

    // Spans -1 to 1 across the face.
    float a = local.x * 2.0 - 1.0;
    float b = local.y * 2.0 - 1.0;

    // Columns are left, front, right and back. Rows are top, sides and bottom.
    float3 direction;
    if (row == 1.0) {
        if (column == 0.0) {
            direction = float3(-1.0, -b, a); // Left, -X
        } else if (column == 1.0) {
            direction = float3(a, -b, 1.0); // Front, +Z
        } else if (column == 2.0) {
            direction = float3(1.0, -b, -a); // Right, +X
        } else {
            direction = float3(-a, -b, -1.0); // Back, -Z
        }
    } else if (column == 1.0) {
        if (row == 0.0) {
            direction = float3(a, 1.0, b); // Top, +Y
        } else {
            direction = float3(a, -1.0, -b); // Bottom, -Y
        }
    } else {
        // The four empty cells of the cross.
        return 0.0;
    }

    direction = normalize(direction);

    float latitude = acos(clamp(direction.y, -1.0, 1.0)) / pi;
    float longitude = atan2(direction.x, direction.z) / (pi * 2.0);
    if (uniforms.inside) {
        longitude = -longitude;
    }

    float2 equirectUV = float2(fract(0.5 + longitude), latitude);

    // The poles have no pixels above and below to blend with.
    float halfTexel = 0.5 / float(texture.get_height());
    equirectUV.y = clamp(equirectUV.y, halfTexel, 1.0 - halfTexel);

    return texture.sample(sampler, equirectUV);
}
