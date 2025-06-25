Shader "May100/3.1/TargetObj"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ID ("Mask ID", Int) = 1
        
    }
    SubShader
    {
        Tags
        {
            "LightMode" = "UniversalForward" "RenderType" = "Opaque" "Queue" = "Geometry+2"
        }
        LOD 100
        // 这个我感觉写在pass或者subshader里都行
        Stencil{
            Ref [_ID]
            Comp equal
        }

        HLSLINCLUDE
        // Material Keywords
        // #pragma shader_feature _REVERSE_FLOW
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

            v2f vert(appdata v)
            {
                v2f o;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                o.positionCS = positionInputs.positionCS;
                o.uv.xy = v.uv;
                VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS, v.tangentOS);
                o.normalWS = normalInputs.normalWS;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 finalColor;
                half3 texColor = tex2D(_MainTex, i.uv);
                
                // 整合
                finalColor = half4(texColor, 1);
                
                return finalColor;
            }
            ENDHLSL
        }
    }
}