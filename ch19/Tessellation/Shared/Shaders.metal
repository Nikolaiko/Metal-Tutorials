#include <metal_stdlib>
#include "Common.h"

using namespace metal;

struct VertexOut {
  float4 position [[position]];
  float4 color;
  float height;
  float2 uv;
  float slope;
};

struct ControlPoint {
  float4 position [[attribute(0)]];
};

//vertex VertexOut vertex_main(VertexIn in [[stage_in]],
//                             constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]])
//{
//  VertexOut out;
//  float4 position = uniforms.mvp * in.position;
//  out.position = position;
//  out.color = float4(0, 0, 1, 1);
//  return out;
//}

[[patch(quad, 4)]]
vertex VertexOut
  vertex_main(
    patch_control_point<ControlPoint>
      control_points [[stage_in]],
    constant Uniforms &uniforms [[buffer(BufferIndexUniforms)]],
    texture2d<float> heightMap [[texture(0)]],
    texture2d<float> terrainSlope [[ texture (4) ]],
    constant Terrain &terrain [[buffer(6)]],
    float2 patch_coord [[position_in_patch]],
    uint patchID [[patch_id]])
{
  float u = patch_coord.x;
  float v = patch_coord.y;
  float2 top = mix(
    control_points[0].position.xz,
    control_points[1].position.xz,
    u);
  float2 bottom = mix(
    control_points[3].position.xz,
    control_points[2].position.xz,
    u);

  VertexOut out;
  float2 interpolated = mix(top, bottom, v);
  float4 position = float4(
    interpolated.x, 0.0,
    interpolated.y, 1.0);
  float2 xy = (position.xz + terrain.size / 2.0) / terrain.size;
  constexpr sampler sample;
  float4 color = heightMap.sample(sample, xy);
  out.color = float4(color.r);
  out.slope = terrainSlope.sample(sample, xy).r;

  float height = (color.r * 2 - 1) * terrain.height;
  position.y = height;
  out.position = uniforms.mvp * position;
  out.uv = xy;
  out.height = height;
  return out;
}


fragment float4 fragment_main(
  VertexOut in [[stage_in]],
  texture2d<float> cliffTexture [[texture(1)]],
  texture2d<float> snowTexture  [[texture(2)]],
  texture2d<float> grassTexture [[texture(3)]])
{
  constexpr sampler sample(filter::linear, address::repeat);
  float tiling = 16.0;
  float4 grass = grassTexture.sample(sample, in.uv * tiling);
  float4 cliff = cliffTexture.sample(sample, in.uv * tiling);
  float4 snow = snowTexture.sample(sample, in.uv * tiling);
  float4 color;
  if (in.height < -0.6) {
    color = grass;
  } else if (in.height < -0.4) {
    float value = 1 - ((in.height + 0.4) / -0.2);
    value = (in.height + 0.6) / 0.2;
    color = mix(grass, cliff, value);
  } else if (in.height < -0.2) {
    color = cliff;
  } else {
    if (in.slope < 0.1) {
      color = snow;
    } else {
      color = cliff;
    }
  }
  return color;
}
