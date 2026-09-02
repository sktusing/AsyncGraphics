//
//  EquirectOrientation.metal
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
    bool mirrorHorizontal;
    bool mirrorVertical;
    packed_float4 rotation;
};

// Rotates a direction by a quaternion, the imaginary part in xyz and the real part in w.
static float3 rotated(float3 direction, float4 quaternion) {
    float3 imaginary = quaternion.xyz;
    float real = quaternion.w;
    return 2.0 * dot(imaginary, direction) * imaginary
        + (real * real - dot(imaginary, imaginary)) * direction
        + 2.0 * real * cross(imaginary, direction);
}

fragment float4 equirectOrientation(VertexOut out [[stage_in]],
                                    texture2d<float> texture [[ texture(0) ]],
                                    const device Uniforms& uniforms [[ buffer(0) ]],
                                    sampler sampler [[ sampler(0) ]]) {

    float pi = M_PI_F;

    float u = out.texCoord[0];
    float v = out.texCoord[1];

    float latitude = v * pi;
    float longitude = (u - 0.5) * pi * 2.0;

    float3 direction = float3(sin(latitude) * sin(longitude),
                              cos(latitude),
                              sin(latitude) * cos(longitude));

    // The inverse rotation, to look up where the content is coming from.
    float4 quaternion = float4(uniforms.rotation);
    float4 inverseQuaternion = float4(-quaternion.xyz, quaternion.w);
    direction = rotated(direction, inverseQuaternion);

    if (uniforms.mirrorHorizontal) {
        direction.x = -direction.x;
    }
    if (uniforms.mirrorVertical) {
        direction.y = -direction.y;
    }

    direction = normalize(direction);

    float sourceLatitude = acos(clamp(direction.y, -1.0, 1.0)) / pi;
    float sourceLongitude = atan2(direction.x, direction.z) / (pi * 2.0);

    float2 sourceUV = float2(fract(0.5 + sourceLongitude), sourceLatitude);

    // The poles have no pixels above and below to blend with.
    float halfTexel = 0.5 / float(texture.get_height());
    sourceUV.y = clamp(sourceUV.y, halfTexel, 1.0 - halfTexel);

    return texture.sample(sampler, sourceUV);
}
