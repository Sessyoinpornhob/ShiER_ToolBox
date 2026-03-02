Shader "Hidden/HairOITResolve_HairOITResolve_002StyleStyle"
{
    Properties
    {
        _BaseMap        ("Albedo", 2D) = "gray" {}
    }

    
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" }
        Pass
        {
            Name "HairOITResolve"
            Tags { "LightMode"="UniversalForward" } // 这里无所谓，反正我们用 overrideMaterial 画

            Cull Off
            ZWrite Off
            ZTest LEqual
            Blend One Zero

            HLSLPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma only_renderers d3d11 metal

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            
            TEXTURE2D_X(_ShiER_CameraColorCopy);
            TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
            TEXTURE2D_X(_OITAccumTex);  SAMPLER(sampler_OITAccumTex);
            TEXTURE2D_X(_OITRevealTex); SAMPLER(sampler_OITRevealTex);

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

            Varyings vert(Attributes input)
            {
                Varyings o = (Varyings)0;
                
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.positionCS = TransformObjectToHClip(input.positionOS);
                return o;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = GetNormalizedScreenSpaceUV(input.positionCS);

                half3 samleTexColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).rgb;

                half4 scene  = SAMPLE_TEXTURE2D_X(_ShiER_CameraColorCopy, sampler_LinearClamp, uv);
                half4 accum  = SAMPLE_TEXTURE2D_X(_OITAccumTex,  sampler_OITAccumTex,  uv);
                half  reveal = SAMPLE_TEXTURE2D_X(_OITRevealTex, sampler_OITRevealTex, uv).r;

                half oitAlpha = saturate(1.0h - reveal);
                half invW = rcp(max(accum.a, 1e-4h));
                half3 oitColor = accum.rgb * invW;

                half3 outCol = lerp(scene.rgb, oitColor, oitAlpha);
                return half4(outCol, scene.a);
                // return half4(samleTexColor, 1);
            }
            ENDHLSL
        }
    }

    FallBack Off
}
