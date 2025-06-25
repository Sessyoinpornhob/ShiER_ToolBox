Shader "May100/3.1/StencilShaderEnums"
{
    Properties
    {
        [HDR] _MainColor ("MainColor", color) = (1.0,1.0,1.0)
        _SRef ("Stencil Ref", Int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Float) = 8
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 2
        [Toggle] _ZWrite ("OpenZWrite", Int) = 0
        [Toggle] _ZTest ("OpenZTest", Int) = 0
        
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry+1"
        }
        LOD 100

        ZWrite [_ZWrite]
        ZTest [_ZTest] 
        //CONGRATULATIONS        
        Stencil
        {
            Ref [_SRef]
            Comp [_StencilComp]
            Pass [_StencilOp]
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

            half4 _MainColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return _MainColor;
            }
            ENDHLSL
        }
    }
}