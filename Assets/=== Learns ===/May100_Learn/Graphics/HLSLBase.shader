Shader "May100/HLSLBase"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        // FlowMap
        [Header(FlowMap)]
        _FlowMap ("FlowMap", 2D) = "white" {}
        _FlowSpeed ("向量场强度", float) = 0.1
        _TimeSpeed ("全局流速", float) = 1
        [Toggle(_REVERSE_FLOW)] _REVERSE_FLOW("翻转流向", int) = 0
        
        // Noise
        //_HeightMap ("HeigheMap",2D) = "white"{}
        //_HeightScale ("HeightScale",range(0,0.5)) = 0.005
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        HLSLINCLUDE
        // Material Keywords
        #pragma shader_feature _REVERSE_FLOW
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        ENDHLSL

        Pass
        {
            Name "URPLighting"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS :   NORMAL;
                float2 uv :         TEXCOORD0;

                float4 tangentOS :  TANGENT;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS:    TEXCOORD0;
                float4 uv :         TEXCOORD2;
            };

            sampler2D _MainTex;     float4 _MainTex_ST;
            sampler2D _FlowMap;     float4 _FlowMap_ST;
            float _FlowSpeed;
            float _TimeSpeed;

            v2f vert(appdata v)
            {
                v2f o;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                o.positionCS = positionInputs.positionCS;
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS, v.tangentOS);
                o.normalWS = normalInputs.normalWS;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 finalColor;
                
                
                // 整合
                finalColor = half4(1.0, 1.0, 1.0, 1);
                
                return finalColor;
            }
            ENDHLSL
        }
    }
}