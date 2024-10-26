//
//  Shaders.metal
//  Pipeline
//
//  Created by Nikolai Baklanov on 26.10.2024.
//

#include <metal_stdlib>
using namespace metal;

// 1
struct VertexIn {
    float4 position [[attribute(0)]];
};

// 2
vertex float4 vertex_main(const VertexIn vertexIn [[stage_in]])
{
    float4 pos = vertexIn.position;
    pos.y -= 1.0;
    return pos;
}

fragment float4 fragment_main() {
    return float4(0, 0, 1, 1);
}
