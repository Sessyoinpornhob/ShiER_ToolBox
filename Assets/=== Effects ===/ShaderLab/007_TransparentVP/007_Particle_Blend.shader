// --------------------------------
// 一个基础的 Unlit Shader 模板，支持XR项目，主要支持的功能如下
// --------------------------------

Shader "ShiERTest/ShaderLab/007_Particle_Blend"
{
    Properties
    {
        _BaseMap    ("Base Map", 2D)   = "white" {}
        _BaseColor  ("Base Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        
        Tags
        {
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
        }
        LOD 0
        
        
        HLSLINCLUDE
        #pragma target 5.0
        #pragma prefer_hlslcc gles
        #pragma only_renderers d3d11 metal

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        
        // ---------- Per-Material 常量（SRP Batcher） ----------
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor;
            float4 _BaseMap_ST;
        CBUFFER_END

        TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);

        ENDHLSL

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Cull Off
            ZWrite Off
            ZTest LEqual
            // for Particle Additive
            Blend One One, SrcAlpha OneMinusSrcAlpha

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
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ _FORWARD_PLUS
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

                return col;
            }

            ENDHLSL
        }
    }

    FallBack Off
}
