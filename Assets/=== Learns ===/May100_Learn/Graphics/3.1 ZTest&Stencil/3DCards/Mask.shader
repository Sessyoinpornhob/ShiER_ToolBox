Shader "May100/3.1/Mask"
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
            "LightMode" = "UniversalForward" "RenderType" = "Opaque" "Queue" = "Geometry+1"
        }
        LOD 100
        
        ColorMask 0
        ZWrite Off
        Stencil
        {
            Ref [_ID]
            Comp always     // 是否通过
            Pass Replace    // 通过后的效果 将自身的Ref值写入缓冲区，其他的图元=Ref才能通过
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
                "LightMode" = "UniversalForward" "RenderType" = "Opaque" "Queue" = "Geometry+1"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 positionOS : POSITION;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
            };

            sampler2D _MainTex;     float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 finalColor;
                
                // 整合
                finalColor = half4(1,1,1, 1);
                
                return finalColor;
            }
            ENDHLSL
        }
    }
}