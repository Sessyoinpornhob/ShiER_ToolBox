Shader "Unlit/shader_if_test"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white"{}
        [KeywordEnum(On,Off)] ENABLE_HAIR_RAMP("是否应用头发高光", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile ENABLE_HAIR_RAMP_ON ENABLE_HAIR_RAMP_OFF
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

            struct VertexInput
            {
                float4 positionOS : POSITION;
                float2 uv :         TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float2 uv :         TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                
                o.positionWS = positionInputs.positionWS;
                o.positionCS = positionInputs.positionCS;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                // sample the texture
                float4 col = (1.0,1.0,1.0,1.0);
                #if defined(ENABLE_HAIR_RAMP_ON)
                    return float4(0.0,0.2,1.0,1.0);//蓝
                #elif defined(ENABLE_HAIR_RAMP_OFF)
                    return float4(1.0,0.2,0.0,1.0);//红
                #else
                    return float4(0.0,1.0,0.0,1.0);//绿
                #endif
                return col;
            }
            ENDHLSL
        }
    }
}
