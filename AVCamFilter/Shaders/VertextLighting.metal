//
//  VertextLighting.metal
//  AVCamFilter
//
//  Created by Xiaowen Yuan on 3/15/25.
//  Copyright © 2025 Apple. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn
{
    float2 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 textureCoord [[attribute(2)]];
};

struct VertexOut
{
    float4 position [[position]];
    float3 normal;
    float2 textureCoord [[user(texturecoord)]];
};

struct DiffuseLight {
    float3 position;
    float diffuseLightIntensity;
    float4 diffuseColor;
    
};

vertex VertexOut vertexShader(VertexIn in [[stage_in]])
{
    VertexOut out;
    out.position = float4(in.position, 0.0, 1.0);
    out.normal = in.normal;
    out.textureCoord = in.textureCoord;
    return out;
}
             
             
fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> imageTexture [[texture(0)]],
                               sampler imageSampler [[sampler(0)]],
                               constant DiffuseLight& light [[buffer(0)]])
{
    float3 normal = normalize(in.normal);
    float3 lightDir = normalize(light.position - in.position.xyz);
    float4 color = imageTexture.sample(imageSampler, in.textureCoord);
    float diff = max(dot(normal, lightDir), 0.0);
    
    float3 finalColor = color.rgb * diff * light.diffuseLightIntensity * light.diffuseColor.rgb;
    return float4(finalColor, 1);
}
