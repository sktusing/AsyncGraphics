//
//  CubeMapToEquirect.metal
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

fragment float4 cubeMapToEquirect(VertexOut out [[stage_in]],
                                  texture2d<float> texture [[ texture(0) ]],
                                  const device Uniforms& uniforms [[ buffer(0) ]],
                                  sampler sampler [[ sampler(0) ]]) {

    float pi = M_PI_F;

    float columns = 4.0;
    float rows = 3.0;

    float u = out.texCoord[0];
    float v = out.texCoord[1];

    float latitude = v * pi;
    float longitude = (u - 0.5) * pi * 2.0;
    if (uniforms.inside) {
        longitude = -longitude;
    }

    float3 direction = float3(sin(latitude) * sin(longitude),
                              cos(latitude),
                              sin(latitude) * cos(longitude));

    float3 magnitude = abs(direction);

    // Columns are left, front, right and back. Rows are top, sides and bottom.
    float column;
    float row;
    float2 local;

    if (magnitude.x >= magnitude.y && magnitude.x >= magnitude.z) {
        float major = magnitude.x;
        row = 1.0;
        if (direction.x >= 0.0) {
            column = 2.0; // Right, +X
            local = float2(0.5 - 0.5 * (direction.z / major),
                           0.5 - 0.5 * (direction.y / major));
        } else {
            column = 0.0; // Left, -X
            local = float2(0.5 + 0.5 * (direction.z / major),
                           0.5 - 0.5 * (direction.y / major));
        }
    } else if (magnitude.y >= magnitude.z) {
        float major = magnitude.y;
        column = 1.0;
        if (direction.y >= 0.0) {
            row = 0.0; // Top, +Y
            local = float2(0.5 + 0.5 * (direction.x / major),
                           0.5 + 0.5 * (direction.z / major));
        } else {
            row = 2.0; // Bottom, -Y
            local = float2(0.5 + 0.5 * (direction.x / major),
                           0.5 - 0.5 * (direction.z / major));
        }
    } else {
        float major = magnitude.z;
        row = 1.0;
        if (direction.z >= 0.0) {
            column = 1.0; // Front, +Z
            local = float2(0.5 + 0.5 * (direction.x / major),
                           0.5 - 0.5 * (direction.y / major));
        } else {
            column = 3.0; // Back, -Z
            local = float2(0.5 - 0.5 * (direction.x / major),
                           0.5 - 0.5 * (direction.y / major));
        }
    }

    // Neighbouring cells in the cross are not continuous, keep the blend inside the face.
    float2 halfTexel = float2(0.5 * columns / float(texture.get_width()),
                              0.5 * rows / float(texture.get_height()));
    local = clamp(local, halfTexel, 1.0 - halfTexel);

    float2 atlasUV = float2((column + local.x) / columns,
                            (row + local.y) / rows);

    return texture.sample(sampler, atlasUV);
}
