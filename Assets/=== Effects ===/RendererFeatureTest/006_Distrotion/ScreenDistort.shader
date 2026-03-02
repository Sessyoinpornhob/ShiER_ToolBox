Shader "Hidden/ScreenDistort"
{
    Properties
    {
        _StrengthPx ("Strength (Pixels)", Range(0, 50)) = 5
        _Frequency  ("Frequency", Range(0, 50)) = 10
        _Speed      ("Speed", Range(0, 10)) = 1
        _Intensity   ("Intensity", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Overlay" }

        Pass
        {
            Name "ScreenDistort"
            ZTest Always ZWrite Off Cull Off Blend One Zero

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex Vert
            #pragma fragment Frag

            // XR 相关变体（更稳）
            #pragma multi_compile _ _STEREO_MULTIVIEW _STEREO_INSTANCING
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ScreenCoordOverride.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DynamicScalingClamping.hlsl"

            float _StrengthPx;
            float _Frequency;
            float _Speed;
            float _Intensity;

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                // half4 inputColor = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, ClampUVForBilinear(SCREEN_COORD_REMOVE_SCALEBIAS(uvDistorted), _BlitTexture_TexelSize.xy));
                
                // ✅ URP17 后处理同款：XR + RTHandle scale/bias 的屏幕UV链路
                float2 uv = SCREEN_COORD_APPLY_SCALEBIAS(UnityStereoTransformScreenSpaceTex(input.texcoord));
                float phase = (uv.y * _Frequency + _Time.y * _Speed) * 6.2831853; // 2*pi
                float wave  = sin(phase);
                float2 uvS = float2(wave, 0.0) * _Intensity + uv;
                // 防止双线性采样越界带来的边缘脏
                uvS = ClampUVForBilinear(SCREEN_COORD_REMOVE_SCALEBIAS(uvS), _BlitTexture_TexelSize.xy);

                half4 col = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uvS);
                return col;
            }
            ENDHLSL
        }
    }

    Fallback Off
}
