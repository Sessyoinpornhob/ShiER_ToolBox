// --------------------------------
// 简单地将纹理复制到平面上
// --------------------------------

Shader "ShiERTest/RendererFeature/002_ColorBlit"
{
    Properties
    {
        _BaseColor                  ("Base Color", Color) = (1,1,1,1)
        _Alpha                      ("Alpha",Range(0,1)) = 0.5
        _Frequency                  ("Frequency", Range(0, 50)) = 10
        _Speed                      ("Speed", Range(0, 10)) = 1
        _Intensity                  ("Intensity", Range(0, 0.2)) = 0.2
    }

    SubShader
    {
        
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
        }
        LOD 0
        
        HLSLINCLUDE
        #pragma target 4.0
        #pragma prefer_hlslcc gles
        #pragma only_renderers d3d11 metal

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        // ---------- Per-Material 常量（SRP Batcher） ----------
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor;
            half _Alpha;
            float _Frequency;
            float _Speed;
            float _Intensity;
        CBUFFER_END

        TEXTURE2D_X(_ShiER_CameraColorCopy);

        ENDHLSL

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Cull Off
            ZWrite On
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha  // 这里应该能穿透才对
//            Blend One Zero, One OneMinusSrcAlpha  // 在VP metal 透射逻辑下 保证不穿透
            
            HLSLPROGRAM
            #pragma target 4.0

            // --- 编译选项 ---
            #pragma vertex   vert
            #pragma fragment frag

            struct Attributes
            {
                float3 positionOS : POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                
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

                return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 suv = GetNormalizedScreenSpaceUV(input.positionCS);

                float phase = (suv.y * _Frequency + _Time.y * _Speed) * 6.2831853; // 2*pi
                float wave  = sin(phase);
                float2 uvS = float2(wave, 0.0) * _Intensity + suv;
                
                half4 col = SAMPLE_TEXTURE2D_X(_ShiER_CameraColorCopy, sampler_LinearClamp, uvS) * _BaseColor;

                return half4(col.rgb, col.a * _Alpha * _BaseColor.a);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
