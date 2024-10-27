#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float4 position [[attribute(0)]];
};

struct VertexOut {
  float4 position [[position]];
};

vertex VertexOut vertex_main(
  VertexIn in [[stage_in]],
  //constant float3 &position [[buffer(11)]])
  constant float4x4 &matrix [[buffer(11)]])
{
  //float3 translation = in.position.xyz + position;

//  float3 translation = in.position.xyz + matrix.columns[3].xyz;
//  VertexOut out {
//    .position = float4(translation, 1)
//  };

  float4 translation = matrix * in.position;
  VertexOut out {
      .position = translation
  };
  return out;
}

fragment float4 fragment_main(
  constant float4 &color [[buffer(0)]])
{
  return color;
}
