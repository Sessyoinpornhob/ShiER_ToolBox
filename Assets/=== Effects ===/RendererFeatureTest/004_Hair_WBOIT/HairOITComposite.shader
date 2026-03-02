Shader "Hidden/HairOITComposite"
{
//    SubShader
//    {
//        // 这里还是出现了左眼显示 右眼没显示东西，猜测是某些东西不对。
//        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Overlay" }
//        Pass
//        {
//            Name "HairOITComposite"
//            ZTest Always
//            ZWrite Off
//            Cull Off
//            
//            // 方案2：直接用 Blend 把 OIT 结果叠到 cameraColor
//            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
//
//            HLSLPROGRAM
//            #pragma target 4.5
//            #pragma vertex Vert
//            #pragma fragment Frag
//
//            // 建议补上 XR 变体（有些项目不写也能跑，但写了更稳）
//            #pragma multi_compile _ _STEREO_MULTIVIEW _STEREO_INSTANCING
//            #pragma multi_compile_instancing
//
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
//            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ScreenCoordOverride.hlsl"
//            
//
//            TEXTURE2D_X(_OITAccumTex);  SAMPLER(sampler_OITAccumTex);
//            TEXTURE2D_X(_OITRevealTex); SAMPLER(sampler_OITRevealTex);
//
//            half4 Frag(Varyings input) : SV_Target
//            {
//                UNITY_SETUP_INSTANCE_ID(input);
//                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
//
//                // 关键：用 URP17 UberPost 同款的 XR 屏幕 UV 链路
//                float2 uv = SCREEN_COORD_APPLY_SCALEBIAS(UnityStereoTransformScreenSpaceTex(input.texcoord));
//                float2 uvS = SCREEN_COORD_REMOVE_SCALEBIAS(uv);
//
//                half4 accum  = SAMPLE_TEXTURE2D_X(_OITAccumTex,  sampler_OITAccumTex,  uv);
//                half  reveal = SAMPLE_TEXTURE2D_X(_OITRevealTex, sampler_OITRevealTex, uv).r;
//
//                // 你清屏为 1，并且在 hair pass 用 “dst *= (1 - alpha)” 的方式累积后
//                // reveal 越小代表越“不透”
//                half oitAlpha = saturate(1.0h - reveal);
//
//                // 防止除 0
//                half invW = rcp(max(accum.a, 1e-4h));
//                half3 oitColor = accum.rgb * invW;
//
//                // 取当前 cameraColor（Blit.hlsl 里提供 _BlitTexture）
//                // half4 scene = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);
//
//                // half3 outCol = lerp(scene.rgb, oitColor, oitAlpha);
//
//                // 方案2：不采样 scene，不做 lerp
//                // 让 Blend 去完成与 cameraColor 的混合
//                return half4(oitColor, oitAlpha);
//            }
//            ENDHLSL
//        }
//    }
    FallBack Off
}
