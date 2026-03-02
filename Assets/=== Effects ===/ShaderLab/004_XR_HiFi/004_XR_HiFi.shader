// --------------------------------
// 一个基础的 Unlit Shader 模板，支持XR项目，主要支持的功能如下
// - XR平台的渲染：URP VisionPro Metal only
// - 不透明物体 + alphaClip
// - hifi 科幻效果
// --------------------------------

Shader "ShiERTest/ShaderLab/004_XR_HiFi"
{
    Properties
    {
        _BaseMap                ("Base Map", 2D)   = "white" {}
        _BaseColor              ("Base Color", Color) = (1,1,1,1)

        [Toggle(_ALPHATEST_ON)] _AlphaClip ("Alpha Clip", Float) = 0
        _Cutoff                 ("Alpha Cutoff", Range(0,1)) = 0.5
        _PowVal                 ("PowVal", Range(1,5)) = 0.5
        _StepVal                ("StepVal", Range(0,1)) = 0.5
        _UsingBarycentricEdge   ("绘制网格布线", Range(0,1)) = 0.5
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
        
        Cull Off
        ZWrite On
        ZTest LEqual
        Blend One Zero     // 纯不透明
        
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
            half _PowVal;
            half _StepVal;
            half _UsingBarycentricEdge;
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
            Blend One Zero // SrcAlpha OneMinusSrcAlpha     // 纯不透明

            HLSLPROGRAM
            #pragma target 4.0

            // --- 编译选项 ---
            #pragma vertex   vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #define _NORMALMAP 1
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

            
            struct Attributes
            {
                float3 positionOS               : POSITION;
                float3 normalOS                 : NORMAL;
                float4 tangentOS                : TANGENT;
                float2 uv                       : TEXCOORD0;
                float3 barycentricChannel       : COLOR;      // 若 barycentricChannel = Color
                // 或者 float3 bary : TEXCOORD1; // 若写入到 UV2
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS               : SV_POSITION;
                float2 uv                       : TEXCOORD0;
                float3 positionWS               : TEXCOORD1;
                float3 normalWS                 : TEXCOORD2;
                float4 tangentWS                : TEXCOORD3;
                float3 ViewDirWS                : TEXCOORD4;
                float3 bitangentWS              : TEXCOORD5;
                float3 barycentricChannel       : TEXCOORD6;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings vert (Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.normalWS = normalize(normalInput.normalWS);
                
                real sign = input.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
                output.tangentWS = tangentWS;
                output.bitangentWS = normalInput.bitangentWS;
                
                float3 ViewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
                output.ViewDirWS = ViewDirWS;

                output.positionWS = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                
                output.uv                   = TRANSFORM_TEX(input.uv, _BaseMap);
                output.barycentricChannel   = input.barycentricChannel;

                return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
                

                // ----------------- 4. 直接光（主光 + 额外灯光） -----------------
                Light mainLight = GetMainLight();
                float3 L = mainLight.direction;
                
                half NdotL = max(dot(input.normalWS, L), 0.0f);
                NdotL = Remap(0,1,0.1,0.9,NdotL);
                half4 halfLambert = NdotL * col * _BaseColor;
                

                half3 bary = input.barycentricChannel;

                half edge = min(bary.x, min(bary.y, bary.z));    // 纯三角边
                // half edge = min(bary.y, bary.z);    // 纯三角边
                half edge1 = step(_StepVal, pow(1 - edge, _PowVal));
                half edge2 = lerp(1, edge1, _UsingBarycentricEdge);

                #if defined(_ALPHATEST_ON)
                    clip(edge2 - 0.01);
                    // 将 col.a = 1 注释掉就能观察到透出现象
                    col.a = 1;
                #endif

                // return half4(color, 1);
                return edge2 * halfLambert;
            }

            ENDHLSL
        }
    }

    FallBack Off
}
