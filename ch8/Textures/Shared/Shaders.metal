#include <metal_stdlib>
using namespace metal;
#import "Common.h"

struct VertexIn {
  float4 position [[attribute(Position)]];
  float3 normal [[attribute(Normal)]];
  float2 uv [[attribute(UV)]];
};

struct VertexOut {
  float4 position [[position]];
  float3 normal;
  float2 uv;
};

vertex VertexOut vertex_main(
  const VertexIn in [[stage_in]],
  constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
  float4 position =
    uniforms.projectionMatrix * uniforms.viewMatrix
    * uniforms.modelMatrix * in.position;
  float3 normal = in.normal;
  VertexOut out {
    .position = position,
    .normal = normal,
    .uv = in.uv
  };
  return out;
}

fragment float4 fragment_main(
  constant Params &params [[buffer(ParamsBuffer)]],
  texture2d<float> baseColorTexture [[texture(BaseColor)]],
  VertexOut in [[stage_in]])
{
//  float4 sky = float4(0.34, 0.9, 1.0, 1.0);
//  float4 earth = float4(0.29, 0.58, 0.2, 1.0);
//  float intensity = in.normal.y * 0.5 + 0.5;
//  return mix(earth, sky, intensity);

//    constexpr sampler textureSampler;

//    constexpr sampler textureSampler(filter::linear);
//    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb;

    constexpr sampler textureSampler(filter::linear, address::repeat, mip_filter::linear, max_anisotropy(16));
    float3 baseColor = baseColorTexture.sample(textureSampler,in.uv * params.tiling).rgb;
    return float4(baseColor, 1);
}
