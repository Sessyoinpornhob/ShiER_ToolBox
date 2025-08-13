Shader "ShiERTest/Hair"
{
    Properties
    {
        _Exponent("Exponent", Range(0, 400)) = 1
        _Scale("Scale", Range(0, 1)) = 1
        _BaseColor("BaseColor", Color) = (1,1,1,1)
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        _SpecularWidth("_SpecularWidth", Range(0, 1)) = 0
        _PrimaryShift("_PrimaryShift", Range(-1,1)) = 0
        _SecondaryShift("_SecondaryShift", Range(-1,1)) = 0
        [NoScaleOffset] _SpecularShiftTexture("specular shift texture", 2D) = "white" {}
        _TillingOffset("TillingOffset", Vector) = (1,1,0,0)
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
 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"            
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
                float4 tangent : TANGENT;
            };
 
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 V: TEXCOORD1;
                float3 bitangentWS: TEXCOORD2;
                float3 positionWS: TEXCOORD3;
                float3 normalWS: TEXCOORD4;
            };
 
            struct Surface{
                float3 positionWS;
                float3 normalWS;
                float3 baseColor;
            };
 
            //支持SRP Batcher
            CBUFFER_START(UnityPerMaterial)
                float _Exponent;
                float _Scale;
                float _SpecularWidth;
                float _PrimaryShift;
                float _SecondaryShift;
                half4 _BaseColor;
                half4 _SpecularColor;
                half4 _TillingOffset;
            CBUFFER_END
            TEXTURE2D(_SpecularShiftTexture);       SAMPLER(sampler_SpecularShiftTexture);

            // 
            float3 shiftTangent(float3 T, float3 N, float shift)
            {
                float3 shiftedT = T + shift * N;
                return normalize(shiftedT);
            }
 
            //计算各向异性光照系数，基于Kajyiya-Kay Model
            float StrandSpecular(float3 V, float3 T, float3 L, float3 N, float exponent,float scale)
            {
                //V：点到相机方向
                //T：切线方向
                //L：点到光源方向，如果是直射光就是光的照射方向的反方向
                //N：法线方向
                float nl = saturate(dot(N, L));//影响反射
                float3 H = normalize(L + V);//光源方向和相机方向是高光模型的一部分
                T = normalize((scale * 2 - 1) * N + T);//这个地方是为了调整天使环位置
                float dotTH = dot(T, H);
                float sinTH = sqrt(1.0 - dotTH * dotTH);
                float dirAtten = smoothstep(-1.0, 0.0, dotTH);
                float factor = dirAtten * pow(sinTH, exponent);
                factor *= nl;
                return factor;
            }

            //计算各向异性光照系数，基于Kajyiya-Kay Model
            float strandSpecular(float3 T, float3 V, float3 L, float exponent)
            {
                // V = viewDirWS
                // T = tangentWS or bitangentWS
                // L = lightDirWS
                float3 H = normalize(L + V);
                float dotTH = dot(T, H);
                float sinTH = sqrt(1.0 - dotTH * dotTH);
                float dirAtten = smoothstep(-_SpecularWidth, 0, dotTH);
                return dirAtten * pow(sinTH, exponent);
            }

            float hairSpecular(float3 T, float3 N, float3 L, float3 V, float2 uv){
                float shiftTex  = SAMPLE_TEXTURE2D(_SpecularShiftTexture, sampler_SpecularShiftTexture, uv * _TillingOffset.xy + _TillingOffset.zw) - 0.5;
                float3 t1 = shiftTangent(T, N, _PrimaryShift + shiftTex);
                float3 t2 = shiftTangent(T, N, _SecondaryShift + shiftTex);
                float3 specular = _SpecularColor * strandSpecular(t1, V, L, _Exponent);
                specular += _SpecularColor * strandSpecular(t2, V, L, _Exponent);
                return specular;
            }
 
            float3 ComputeLighting(float3 lightColor, float3 lightDirectionWS, Surface surface){
                float3 cameraWS = _WorldSpaceCameraPos;
 
                float lambertDot = saturate(dot(surface.normalWS, lightDirectionWS));
                float halfLambert = lambertDot * 0.5 + 0.5;
 
                float3 diffuseColor = halfLambert * lightColor * surface.baseColor;
                diffuseColor = max(float3(0,0,0), diffuseColor);
 
                float3 surfaceColor = diffuseColor;
                return surfaceColor;
            }
 
            v2f vert (appdata v)
            {
                VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normal, v.tangent);
 
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 V = GetWorldSpaceNormalizeViewDir(positionWS);
 
                v2f o;
                o.vertex = TransformWorldToHClip(positionWS);
                o.bitangentWS = normalInputs.bitangentWS;
                o.V = V;
                o.positionWS = positionWS;
                o.normalWS = normalInputs.normalWS;
                o.uv = v.uv * _TillingOffset.xy + _TillingOffset.zw;
                return o;
            }
 
            half4 frag (v2f IN) : SV_Target
            {
                float3 L = GetMainLight().direction;
                // float factor = StrandSpecular(IN.V, IN.bitangentWS, L, IN.normalWS.xyz, _Exponent, _Scale);
                float factor = hairSpecular(IN.bitangentWS, IN.normalWS, L, IN.V, IN.uv);
 
                Surface surface;
                surface.positionWS = IN.positionWS;
                surface.normalWS = IN.normalWS;
                surface.baseColor = _BaseColor.rgb;
 
                half3 lightColor = ComputeLighting(_MainLightColor.rgb, normalize(_MainLightPosition.xyz), surface);
                lightColor = lightColor + factor * GetMainLight().color;

                // return half4(IN.T,1);
                return half4(lightColor.rgb, 1);
            }
 
 
            ENDHLSL
        }
    }
}