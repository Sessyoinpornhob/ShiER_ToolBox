// File: DebugDepthHeatmapPro.shader
// Unity 6000 / URP 17 / XR-safe (Metal + Compositor Services OK)
// 作用：基于相机深度做显眼的“深度热力图”调色，并可与源颜色混合；含边缘强化。
// 用法：创建材质，指向本 Shader；在你的 RenderGraph 合成 pass 中用 Blitter 传入源图（_BlitTexture）。

Shader "Hidden/DebugDepthHeatmapPro"
{
    Properties
    {
        // —— 距离映射（单位：米）
        _Near ("Near (meters)",    Float) = 0.30
        _Far  ("Far  (meters)",    Float) = 10.0

        // —— 外观控制
        _Style   ("Style 0=Heat 1=Viridis 2=Turbo 3=BlueRed", Float) = 1.0
        _Gamma   ("Gamma",          Float) = 1.2
        _Contrast("Contrast boost", Float) = 1.0
        _Invert  ("Invert 0/1",     Float) = 0.0

        // —— 轮廓
        _EdgeStrength  ("Edge Strength",        Range(0,3))   = 1.0
        _EdgeThreshold ("Edge Threshold",       Range(0,0.1)) = 0.02
        _EdgeThickness ("Edge Thickness (px)",  Range(0.5,4)) = 1.0
        _EdgeColor     ("Edge Color", Color) = (1,1,1,1)

        // —— 与源颜色混合（需要 Blitter 传入 _BlitTexture）
        _Blend ("Blend with Source (0..1)", Range(0,1)) = 1.0
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // XR：使用 _X 系列宏，兼容 2DArray（Single-Pass Instanced）
            TEXTURE2D_X_FLOAT(_CameraDepthTexture);
            TEXTURE2D_X(_BlitTexture); // 由 Blitter 作为源颜色输入

            // 采样器使用 Core.hlsl 已内置的，不要重复声明：
            // sampler_PointClamp / sampler_LinearClamp

            // —— 属性
            float _Near, _Far, _Gamma, _Contrast, _Invert, _Style, _Blend;
            float _EdgeStrength, _EdgeThreshold, _EdgeThickness;
            float4 _EdgeColor;

            struct VIn  { uint vertexID : SV_VertexID; UNITY_VERTEX_INPUT_INSTANCE_ID };
            struct VOut { float4 posHCS : SV_Position; float2 uv : TEXCOORD0;        UNITY_VERTEX_OUTPUT_STEREO };

            VOut Vert(VIn v)
            {
                VOut o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.posHCS = GetFullScreenTriangleVertexPosition(v.vertexID);
                o.uv     = GetFullScreenTriangleTexCoord(v.vertexID);
                return o;
            }

            //======================================================================
            // 工具与调色（做宏保护，避免多处 include 时重复定义）
            //======================================================================
            #ifndef DEBUG_DEPTH_LIB_GUARD
            #define DEBUG_DEPTH_LIB_GUARD

            inline float DDH_Remap01(float dEye, float n, float f, float gamma, float contrast, float invert01)
            {
                // 距离区间归一化到 [0,1]
                float t = saturate((dEye - n) / max(f - n, 1e-5));
                // Gamma（>1 强调近端；<1 强调远端）
                t = pow(t, max(gamma, 1e-5));
                // 对比度（以 0.5 为中心提拉）
                t = saturate((t - 0.5) * contrast + 0.5);
                // 反转
                if (invert01 > 0.5) t = 1.0 - t;
                return t;
            }

            inline float3 Palette_Heat(float t)
            {
                // 黑→红→黄→白（2 段）
                float3 c0 = float3(0.0, 0.0, 0.0);
                float3 c1 = float3(0.95, 0.10, 0.05);
                float3 c2 = float3(1.00, 0.85, 0.10);
                float3 c3 = float3(1.00, 1.00, 0.95);
                float u = saturate(t);
                float3 a = lerp(c0, c1, saturate(u * 2.0));
                float3 b = lerp(c2, c3, saturate(u * 2.0 - 1.0));
                return (u < 0.5) ? a : b;
            }

            inline float3 Palette_Viridis(float t)
            {
                // 近似 Viridis：分段线性插值（10 级）
                const float3 lut[10] = {
                    float3(0.267, 0.005, 0.329),
                    float3(0.283, 0.141, 0.458),
                    float3(0.254, 0.265, 0.530),
                    float3(0.207, 0.372, 0.553),
                    float3(0.164, 0.471, 0.558),
                    float3(0.128, 0.567, 0.551),
                    float3(0.135, 0.659, 0.518),
                    float3(0.266, 0.748, 0.441),
                    float3(0.478, 0.821, 0.318),
                    float3(0.741, 0.873, 0.150)
                };
                float u = saturate(t) * 9.0;
                int i0 = (int)floor(u);
                int i1 = min(i0 + 1, 9);
                float k = frac(u);
                return lerp(lut[i0], lut[i1], k);
            }

            inline float3 Palette_Turbo(float t)
            {
                // Turbo-ish：蓝→青→黄→红（5 级）
                const float3 lut[5] = {
                    float3(0.189, 0.071, 0.233),
                    float3(0.017, 0.305, 0.642),
                    float3(0.178, 0.725, 0.604),
                    float3(0.975, 0.905, 0.110),
                    float3(0.915, 0.316, 0.138)
                };
                float u = saturate(t) * 4.0;
                int i0 = (int)floor(u);
                int i1 = min(i0 + 1, 4);
                float k = frac(u);
                return lerp(lut[i0], lut[i1], k);
            }

            inline float3 Palette_BlueRed(float t)
            {
                // 蓝→白→红（中点显眼）
                float3 c0 = float3(0.10, 0.20, 0.90);
                float3 c1 = float3(1.00, 1.00, 1.00);
                float3 c2 = float3(0.90, 0.10, 0.10);
                float u = saturate(t);
                float3 a = lerp(c0, c1, saturate(u * 2.0));
                float3 b = lerp(c1, c2, saturate(u * 2.0 - 1.0));
                return (u < 0.5) ? a : b;
            }

            inline float3 ApplyPalette(float t, float style)
            {
                if (style < 0.5)        return Palette_Heat(t);
                else if (style < 1.5)   return Palette_Viridis(t);
                else if (style < 2.5)   return Palette_Turbo(t);
                else                    return Palette_BlueRed(t);
            }

            inline float Depth01AtUV(float2 uv)
            {
                float raw = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, uv).r;
                return Linear01Depth(raw, _ZBufferParams); // 0..1
            }

            inline float EdgeMask(float2 uv, float thicknessPx, float threshold, float strength)
            {
                // thickness: 像素 → UV 偏移
                float2 texel = thicknessPx * rcp(_ScreenParams.xy);

                float dL = Depth01AtUV(uv + float2(-texel.x, 0));
                float dR = Depth01AtUV(uv + float2( texel.x, 0));
                float dT = Depth01AtUV(uv + float2(0, -texel.y));
                float dB = Depth01AtUV(uv + float2(0,  texel.y));

                float g = abs(dR - dL) + abs(dB - dT);
                return saturate((g - threshold) * (20.0 * strength));
            }

            #endif // DEBUG_DEPTH_LIB_GUARD

            //======================================================================
            // Fragment
            //======================================================================
            half4 Frag(VOut i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                // 1) 读深度 → 眼空间距离（米）
                float raw  = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_PointClamp, i.uv).r;
                float dEye = LinearEyeDepth(raw, _ZBufferParams);

                // 2) 距离映射到 [0,1]
                float t = DDH_Remap01(dEye, _Near, _Far, _Gamma, _Contrast, _Invert);

                // 3) 调色
                float3 depthCol = ApplyPalette(t, _Style);

                // 4) 轮廓增强
                float e = EdgeMask(i.uv, _EdgeThickness, _EdgeThreshold, _EdgeStrength);
                depthCol = lerp(depthCol, _EdgeColor.rgb, e);

                // 5) 与源颜色混合（_BlitTexture 由 Blitter 提供；_Blend=1 表示完全覆盖）
                float3 srcCol = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, i.uv).rgb;
                float3 outCol = lerp(srcCol, depthCol, saturate(_Blend));

                float a = saturate(_Blend);

                return half4(outCol, a);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
