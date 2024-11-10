#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef unsigned int uint;

typedef struct {
  vector_float2 size;
  float height;
  uint maxTessellation;
} Terrain;

typedef struct {
  matrix_float4x4 modelMatrix;
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
  matrix_float4x4 mvp;
} Uniforms;

typedef struct {
  uint width;
  uint height;
  uint tiling;
} Params;

typedef enum {
  Position = 0,
  Normal = 1,
  UV = 2
} Attributes;

typedef enum {
  BufferIndexVertices = 0,
  BufferIndexUVs = 1,
  BufferIndexUniforms = 11,
  BufferIndexParams = 12,
  
  // Texture Indices
  BaseColorTexture = 0
} BufferIndices;

#endif /* Common_h */
