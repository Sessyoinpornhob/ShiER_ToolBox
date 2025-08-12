// ShiERFunctions.hlsl
#ifndef ShiER_FUNCTIONS_INCLUDED
#define ShiER_FUNCTIONS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


// 彩虹色生成函数
half3 RainbowColor(float t) {
    t = frac(t); // 确保在0-1范围内
    half3 c = saturate(3.0 * abs(1.0 - 2.0 * t) - 1.0);
    return lerp(c.xyz, c.zxy, step(0.66, t));
}

float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

// 噪声计算函数 2D
float snoise( float2 v )
{
    const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
    float2 i = floor( v + dot( v, C.yy ) );
    float2 x0 = v - i + dot( i, C.xx );
    float2 i1;
    i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod2D289( i );
    float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
    float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
    m = m * m;
    m = m * m;
    float3 x = 2.0 * frac( p * C.www ) - 1.0;
    float3 h = abs( x ) - 0.5;
    float3 ox = floor( x + 0.5 );
    float3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot( m, g );
}

// 噪声计算函数 3D
float snoise( float3 v )
{
    const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
    float3 i = floor( v + dot( v, C.yyy ) );
    float3 x0 = v - i + dot( i, C.xxx );
    float3 g = step( x0.yzx, x0.xyz );
    float3 l = 1.0 - g;
    float3 i1 = min( g.xyz, l.zxy );
    float3 i2 = max( g.xyz, l.zxy );
    float3 x1 = x0 - i1 + C.xxx;
    float3 x2 = x0 - i2 + C.yyy;
    float3 x3 = x0 - 0.5;
    i = mod3D289( i);
    float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
    float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
    float4 x_ = floor( j / 7.0 );
    float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
    float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
    float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
    float4 h = 1.0 - abs( x ) - abs( y );
    float4 b0 = float4( x.xy, y.xy );
    float4 b1 = float4( x.zw, y.zw );
    float4 s0 = floor( b0 ) * 2.0 + 1.0;
    float4 s1 = floor( b1 ) * 2.0 + 1.0;
    float4 sh = -step( h, 0.0 );
    float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
    float3 g0 = float3( a0.xy, h.x );
    float3 g1 = float3( a0.zw, h.y );
    float3 g2 = float3( a1.xy, h.z );
    float3 g3 = float3( a1.zw, h.w );
    float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
    g0 *= norm.x;
    g1 *= norm.y;
    g2 *= norm.z;
    g3 *= norm.w;
    float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
    m = m* m;
    m = m* m;
    float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
    return 42.0 * dot( m, px);
}



#ifdef _SPECULAR_SETUP
#define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_SpecGlossMap, sampler_SpecGlossMap, uv)
#else
#define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MetallicGlossMap, uv)
#endif

half4 SampleMetallicSpecGloss_ShiER(float2 uv, half albedoAlpha, half _Metallic, half _Smoothness)
{
    half4 specGloss;

#ifdef _METALLICSPECGLOSSMAP
    // specGloss = half4(SAMPLE_METALLICSPECULAR(uv));
    specGloss = half4(1,1,1,1); // 就是这 没有处理这个宏导致找不到这个只
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        specGloss.a = albedoAlpha * _Smoothness;
    #else
        specGloss.a *= _Smoothness;
    #endif
#else // _METALLICSPECGLOSSMAP
    #if _SPECULAR_SETUP
        specGloss.rgb = _SpecColor.rgb; 
    #else
        specGloss.rgb = _Metallic.rrr;
    #endif

    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        specGloss.a = albedoAlpha * _Smoothness;
    #else
        specGloss.a = _Smoothness;
    #endif
#endif

    return specGloss;
}

half SampleOcclusion_ShiER(float2 uv)
{
    #ifdef _OCCLUSIONMAP
        half occ = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
        return LerpWhiteTo(occ, _OcclusionStrength);
    #else
        return half(1.0);
    #endif
}

// half3 SampleNormal_ShiER(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = half(1.0))
// {
//     #ifdef _NORMALMAP
//     half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
//     #if BUMP_SCALE_NOT_SUPPORTED
//     return UnpackNormal(n);
//     #else
//     return UnpackNormalScale(n, scale);
//     #endif
//     #else
//     return half3(0.0h, 0.0h, 1.0h);
//     #endif
// }

half3 SampleEmission_ShiER(float2 uv, half3 emissionColor, TEXTURE2D_PARAM(emissionMap, sampler_emissionMap))
{
    #ifndef _EMISSION
    return 0;
    #else
    return SAMPLE_TEXTURE2D(emissionMap, sampler_emissionMap, uv).rgb * emissionColor;
    #endif
}


#endif