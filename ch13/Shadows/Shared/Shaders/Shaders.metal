#include <metal_stdlib>
using namespace metal;
#import "Common.h"
#import "Lighting.h"
#import "Vertex.h"

vertex VertexOut vertex_main(
  const VertexIn in [[stage_in]],
  constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
  float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
  VertexOut out {
    .position = position,
    .uv = in.uv,
    .color = in.color,
    .worldPosition = (uniforms.modelMatrix * in.position).xyz,
    .worldNormal = uniforms.normalMatrix * in.normal,
    .worldTangent = uniforms.normalMatrix * in.tangent,
    .worldBitangent = uniforms.normalMatrix * in.bitangent,
    .shadowPosition = uniforms.shadowProjectionMatrix * uniforms.shadowViewMatrix * uniforms.modelMatrix * in.position,
  };
  return out;
}

fragment float4 fragment_main(
  constant Params &params [[buffer(ParamsBuffer)]],
  constant Light *lights [[buffer(LightBuffer)]],
  VertexOut in [[stage_in]],
  constant Material &_material [[buffer(MaterialBuffer)]],
  texture2d<float> baseColorTexture [[texture(BaseColor)]],
  texture2d<float> normalTexture [[texture(NormalTexture)]])
{
  constexpr sampler textureSampler(
    filter::linear,
    address::repeat,
    mip_filter::linear,
    max_anisotropy(8));

  Material material = _material;
  if (!is_null_texture(baseColorTexture)) {
    material.baseColor = baseColorTexture.sample(
    textureSampler,
    in.uv * params.tiling).rgb;
  }
  float3 normal;
  if (is_null_texture(normalTexture)) {
    normal = in.worldNormal;
  } else {
    normal = normalTexture.sample(
    textureSampler,
    in.uv * params.tiling).rgb;
    normal = normal * 2 - 1;
    normal = float3x3(
      in.worldTangent,
      in.worldBitangent,
      in.worldNormal) * normal;
  }
  normal = normalize(normal);

  float3 color = phongLighting(
    normal,
    in.worldPosition,
    params,
    lights,
    material
  );
  return float4(color, 1);
}
