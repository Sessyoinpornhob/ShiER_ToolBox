Shader "Hidden/SimpleTintBlit"
{
    Properties
    {
        _Tint("Tint", Color) = (1,1,1,1)
        _Strength("Strength", Range(0,2)) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }
        ZWrite Off ZTest Always Cull Off
        Pass
        {
            Name "SimpleTintBlit"
            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma multi_compile_instancing
            #pragma multi_compile _ _STEREO_MULTIVIEW_ON _STEREO_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D_X(_BlitTexture);
            // SAMPLER(sampler_LinearClamp);

            float4 _BlitScaleBias;   // xy: scale, zw: bias
            float4 _Tint;
            float  _Strength;

            struct Attributes
            {
                uint vertexID : SV_VertexID;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 texcoord   : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings Vert(Attributes input)
            {
                Varyings o;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
                o.texcoord   = GetFullScreenTriangleTexCoord(input.vertexID);
                return o;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);
                uv = uv * _BlitScaleBias.xy + _BlitScaleBias.zw;

                half4 col = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);

                // 简单调色：strength=0 不变；strength=1 完全乘 tint；可按需改成 lerp/加色等
                half3 tinted = col.rgb * _Tint.rgb;
                col.rgb = lerp(col.rgb, tinted, saturate(_Strength));

                return col;
            }
            ENDHLSL
        }
    }
}
