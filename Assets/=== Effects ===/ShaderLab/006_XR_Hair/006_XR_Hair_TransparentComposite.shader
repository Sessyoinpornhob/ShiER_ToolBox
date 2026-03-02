Shader "ShiERTest/ShaderLab/006_XR_Hair_TransparentComposite"
{
    Properties
    {
        _BaseMap    ("Base Map", 2D)       = "white" {}
        _BaseColor  ("Base Color", Color)  = (1,1,1,1)
        _Cutoff     ("Alpha Cutoff", Range(0,1)) = 0.3
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"     = "Transparent"
            "Queue"          = "Transparent"
        }
        
        ZWrite Off          // 先按常规透明来（如果想要更稳的遮挡可以改成 On 再看）
        ZTest LEqual
        Cull Off
        // Blend One Zero      // 直接覆盖，颜色已在片元里混好了
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex   vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // 头发贴图
            TEXTURE2D(_BaseMap);           SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;

            // Opaque 背景（只包含虚拟场景）
            TEXTURE2D_X(_CameraOpaqueTexture); SAMPLER(sampler_CameraOpaqueTexture);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half  _Cutoff;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings vert(Attributes input)
            {
                Varyings o;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float4 posCS = TransformObjectToHClip(input.positionOS);
                o.positionCS = posCS;
                o.uv         = TRANSFORM_TEX(input.uv, _BaseMap);
                
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                // 采头发贴图
                half4 baseSample = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                half  alphaTex   = baseSample.a * _BaseColor.a;

                // 细发丝用 cutout 保证深度正确，可以视需求减小 _Cutoff
                clip(alphaTex - _Cutoff);

                half3 hairColor = baseSample.rgb * _BaseColor.rgb;
                
                return half4(hairColor, alphaTex);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
