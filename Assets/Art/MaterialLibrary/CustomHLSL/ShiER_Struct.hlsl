// ShiER_Struct.hlsl
#ifndef ShiER_STRUCT_INCLUDED
#define ShiER_STRUCT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// Must match Universal ShaderGraph master node
struct ShiER_SurfaceData
{
    half3 albedo;
    half3 specular;
    half  metallic;
    half  smoothness;
    half3 normalTS;
    half3 emission;
    half  occlusion;
    half  alpha;
    half  clearCoatMask;
    half  clearCoatSmoothness;
};

struct ShiER_InputData
{
    float3  positionWS;
    float4  positionCS;
    float3  normalWS;
    half3   viewDirectionWS;
    float4  shadowCoord;
    half    fogCoord;
    half3   vertexLighting;
    half3   bakedGI;
    float2  normalizedScreenSpaceUV;
    half4   shadowMask;
    half3x3 tangentToWorld;

#if defined(DEBUG_DISPLAY)
half2   dynamicLightmapUV;
half2   staticLightmapUV;
float3  vertexSH;

half3 brdfDiffuse;
half3 brdfSpecular;

// Mipmap Streaming Debug
float2 uv;
uint mipCount;

// texelSize :
// x = 1 / width
// y = 1 / height
// z = width
// w = height
float4 texelSize;

// mipInfo :
// x = quality settings minStreamingMipLevel
// y = original mip count for texture
// z = desired on screen mip level
// w = loaded mip level
float4 mipInfo;

// streamInfo :
// x = streaming priority
// y = time stamp of the latest texture upload
// z = streaming status
// w = 0
float4 streamInfo;

float3 originalColor;

float4 probeOcclusion;
#endif
};

#endif