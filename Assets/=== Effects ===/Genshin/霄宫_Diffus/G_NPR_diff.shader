Shader "Genshin/G_NPR_diff"
{
    Properties
    {
        [Header(BaseColor)]
        [MainTexture] _BaseMap("Base Map", 2D) = "white"{}
        
        [Header(RampTex)]
        _RampMap("RampTex", 2D) = "white"{}
        _RampShadowRange("RampTex取值范围",range(0.4, 1)) = 0.5
        
        [Header(LightMap AO )]
        _LightMap("LightMap", 2D) = "white"{}
        _ShadowRampLerp("AO强度",range(0, 1)) = 0.5
        _RampAOLerp("Ramp和AO强度",range(0, 1)) = 0.5
        
        _LightThreshold("LightThreshold",range(0, 1)) = 0.5        
        [HideInInspector]_ShadowMultColor("亮部阴影色", Color) = (1, 1, 1, 1)
        _BrightIntensity("亮部强度",range(0, 1)) = 0.5
        [HideInInspector]_DarkShadowMultColor("暗部阴影色", Color) = (1, 1, 1, 1)
        _DarkIntensity("暗部强度",range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

            struct VertexInput
            {
                float4 positionOS  : POSITION;
                float2 uv :     TEXCOORD0;
                half3 normalOS :  NORMAL;
            };

            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float2 uv :         TEXCOORD0;
                float3 positionWS :    TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
            };
            
            // 此宏将 _BaseMap 声明为 Texture2D 对象。
            TEXTURE2D(_BaseMap);        SAMPLER(sampler_BaseMap);
            TEXTURE2D(_RampMap);        SAMPLER(sampler_RampMap);
            TEXTURE2D(_LightMap);       SAMPLER(sampler_LightMap);
            
            // 要使 Unity 着色器 SRP Batcher 兼容，
            // 请在名为 UnityPerMaterial 的单个 CBUFFER 代码块中声明与材质相关的所有属性。
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _BaseMap_ST;

                float _RampShadowRange;
                float _RampChoice;
                float4 _ShadowMultColor;
                float4 _DarkShadowMultColor;
            
                float _ShadowRampLerp;
                float _RampAOLerp;
                float _LightThreshold;
                float _BrightIntensity;
                float _DarkIntensity;
            CBUFFER_END

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                // 视线方向
                VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS .xyz);
                o.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;
                // 法线方向
                VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS.xyz);                                // input.normalOS, input.tangentOS ?
                o.normalWS = normalInputs.normalWS;
                // 位置信息
                o.positionWS = positionInputs.positionWS;
                o.positionCS = positionInputs.positionCS;
                // uv采样
                o.uv = v.uv;
                // 顶点色？ 用顶点色干嘛
                float3 vertexLight = VertexLighting(positionInputs.positionWS, normalInputs.normalWS);
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                // sample the texture
                float4 BaseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                float4 LightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv);

                // 准备向量
                // 光方向
                Light light = GetMainLight();
                float3 lightDirWS = normalize(light.direction);
                float4 LightColor = float4(light.color, 1);
                // 法线方向
                float3 normalDirWS = i.normalWS;
                // 摄像机方向
                float3 viewDirWS = normalize(i.viewDirWS);
                float3 halfDirWS = normalize(viewDirWS + lightDirWS);
                float SpecularLayerMask = LightMap.r;       // ⾼光类型Layer
                float ShadowAOMask = LightMap.g;            //ShadowAOMask
                float SpecularIntensityMask = LightMap.b;   //SpecularIntensityMask

                // 中间数据和点乘结果
                float ndotl = dot(normalDirWS, lightDirWS);
                
                // 光照模型 半兰伯特
                half halfLambert = max(0.0, ndotl) * 0.5 + 0.5;
                // AO
                ShadowAOMask = 1 - smoothstep(saturate(ShadowAOMask), 0.2, 0.6);
                // RampTex采样
                float rampValue = halfLambert  * lerp(0.5, 1.0, ShadowAOMask) * (1.0 / _RampShadowRange);
                half3 ShadowRamp = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, _RampChoice)).rgb;     // 更柔和的明暗分界线
                half3 finalRamp = ShadowRamp;       // 最终混合 等后面再加不同材质和昼夜的变化情况

                float3 BaseMapShadowed = lerp(BaseColor.rgb * finalRamp, BaseColor.rgb, ShadowAOMask);
                BaseMapShadowed = lerp(BaseColor.rgb, BaseMapShadowed, _ShadowRampLerp);                                // 纯底图 + AO范围叠加采样色
                float IsBrightSide = ShadowAOMask * step(_LightThreshold, halfLambert); // 亮区  

                
                half3 diffuse = lerp(
                    lerp(BaseMapShadowed, BaseColor.rgb * finalRamp, _RampAOLerp) * _DarkIntensity,
                    _BrightIntensity * BaseMapShadowed , IsBrightSide * _BrightIntensity);
                // lerp 暗区和亮区 但亮区和暗区的明亮程度不同（_BrightIntensity != _DarkIntensity） 且 emmmm 有点整不会了，后面再看

                // half3 diffuse = lerp(BaseMapShadowed, BaseColor.rgb * finalRamp, _RampAOLerp) * _DarkIntensity;
                
                // 返回结果
                // return float4(IsBrightSide, IsBrightSide, IsBrightSide, 1.0);
                // return float4(BaseMapShadowed, 1.0);
                return float4(diffuse, 1.0);
                
            }
            ENDHLSL
        }
    }
}

