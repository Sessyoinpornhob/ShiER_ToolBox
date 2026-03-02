// --------------------------------
// 一个基础的 Unlit Shader 模板，支持XR项目，主要支持的功能如下
// - XR平台的渲染：URP VisionPro Metal only
// - 不透明物体 
// - alphaClip
// - 彩透现象
// - - 在不透明渲染的队列中，由于alpha值<1，导致和天空盒(彩透现实世界)混合，出现彩透现象
// --------------------------------

Shader "ShiERTest/ShaderLab/006_XR_Hair_Dither"
{
    Properties
    {
        _BaseMap        ("Base Map", 2D)   = "white" {}
        _BaseColor      ("Base Color", Color) = (1,1,1,1)
        _HairAlphaLOD   ("HairAlphaLOD", int) = 0
        _DitherWidth    ("DitherWidth", Range(0.01, 0.1)) = 0.5
        _EdgeBias       ("EdgeBias", Range(0.01, 2)) = 0.5
        _EdgeScale      ("EdgeScale", Range(0.01, 2)) = 0.5

        [Toggle(_ALPHATEST_ON)] _AlphaClip ("Alpha Clip", Float) = 0
        _Cutoff     ("Alpha Cutoff", Range(0.001, 1)) = 0.5
    }

    SubShader
    {
        
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
            "Queue" = "Geometry"
        }
        LOD 0
        
        HLSLINCLUDE
        #pragma target 5.0
        #pragma prefer_hlslcc gles
        #pragma only_renderers d3d11 metal

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        //------------ SurfaceInput.hlsl ----------------
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
        #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_Lighting.hlsl"
        #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_BRDF.hlsl"

        // ---------- Per-Material 常量（SRP Batcher） ----------
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor;
            float4 _BaseMap_ST;
            float  _Cutoff;
            float _DitherWidth;
            int _HairAlphaLOD;
            float _EdgeBias;
            float _EdgeScale;
        CBUFFER_END

        TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);

        ENDHLSL

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Cull Off
            ZWrite On
            ZTest LEqual
            // Blend SrcAlpha OneMinusSrcAlpha
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            // Blend One Zero     // 不做传统透明混合
            // AlphaToMask On     // ★ 开启 Alpha-to-coverage

            HLSLPROGRAM
            #pragma target 4.0

            // --- 编译选项 ---
            #pragma vertex   vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #define _NORMALMAP 1
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _EYE_EMISSION_MASK_ON
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile _ LIGHTMAP_ON // 没有间接光？
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            // —— 关键：混合光 Shadowmask 路线 —— //
            #pragma multi_compile_fragment  _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fragment  _ SHADOWS_SHADOWMASK

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv         : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings vert (Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 positionWS       = TransformObjectToWorld(input.positionOS);
                output.positionCS       = TransformWorldToHClip(positionWS);
                output.uv               = TRANSFORM_TEX(input.uv, _BaseMap);

                return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
                half alpha = col.a;

                float rawA = alpha;  // 原贴图
                // 先把它变成一个更“厚、有过渡”的 mask
                float coverage = saturate((rawA - _EdgeBias) * _EdgeScale);
                // 或者 coverage = pow(rawA, _EdgePow);  // <1 拉宽亮部

                // return coverage;

            #if defined(_ALPHATEST_ON)
                // 解释：_Cutoff 是“中心”，_DitherWidth 是羽化宽度
                float cutoff  = _Cutoff;
                float feather = _DitherWidth;          // 建议 0.02~0.1

                float low  = cutoff - feather;
                float high = cutoff + feather;

                // 完全透明区域：直接砍掉
                if (coverage <= low)
                {
                    clip(-1);
                }

                // 完全不透明区域：不做抖动，避免整片都有颗粒
                if (coverage >= high)
                {
                    // 直接通过
                }
                else
                {
                    // 只在 [low, high] 薄薄一圈里做抖动

                    // ---- 屏幕空间 hash 噪声 ----
                    float2 ndc = input.positionCS.xy / input.positionCS.w;    // -1~1
                    float2 pixel = (ndc * 0.5 + 0.5) * _ScreenParams.xy;      // 0~screen

                    float noise = frac(sin(dot(pixel, float2(12.9898, 78.233))) * 43758.5453);

                    // alpha 在羽化带中的相对位置 [0,1]
                    float t = saturate((coverage - low) / (high - low));

                    // t 越大，保留概率越高
                    if (t <= noise)
                        clip(-1);
                }
            #endif

                
                // 最终 alpha 必须是 1，防止彩透
                col.a = 1;
                return col;
            }


            ENDHLSL
        }
    }

    FallBack Off
}
