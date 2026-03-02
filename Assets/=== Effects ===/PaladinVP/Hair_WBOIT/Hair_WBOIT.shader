// 优化相关
// 

Shader "ALab/RendererFeature/Hair_WBOIT"
{
    Properties
    {
        [SingleLineTexture] _BaseMap    ("Base Map", 2D)       = "white" {}
        _BaseColor  ("Base Color", Color)  = (1,1,1,1)

        // 传统 cutout 还保留，但 WBOIT 起步建议先关掉，保证边缘柔
        [Toggle(_ALPHATEST_ON)] _UseClip ("Use Clip (debug/noise)", Float) = 0
        _Cutoff                         ("Alpha Cutoff", Range(0,1)) = 0.03
        
        // ---- WBOIT tuning ----
        _OITDepthBeta                   ("OIT Depth Beta", Range(0,8)) = 2.0
        _OITDepthEps                    ("OIT Depth Eps",  Range(0.001,1)) = 0.1

        _OITAlphaScale                  ("OIT Alpha Scale", Range(0,4)) = 1.0
        _OITAlphaBias                   ("OIT Alpha Bias",  Range(0,1)) = 0.0
        _OITAlphaGamma                  ("OIT Alpha Gamma", Range(0.2,10)) = 1.0
        
        _DepthCutoff                    ("Depth Cutoff", Range(0, 1)) = 0.1
        _Alpha                          ("Alpha", Range(0, 2)) = 1.0
        _LOD                            ("LOD", Range(0, 8)) = 1.0
        
        [Header(NPR)] [Space(10)]
        _HalfToonScale                  ("HalfToon Scale", Range(0.1, 2)) = 1.0
        _HalfToonOffset                 ("HalfToon Offset", Range(0, 2)) = 1.0
        
        [Header(PBR)] [Space(10)]
        [SingleLineTexture] _AlbedoMap          ("Albedo Map", 2D)       = "white" {}
        [SingleLineTexture] _BumpMap            ("Normal Map", 2D)       = "bump" {}
        [SingleLineTexture] _ARMMaskMap         ("ARMMaskMap", 2D)       = "white" {}
        [Toggle(USE_SPECULAR_COLOR)] _UseSpecularColor ("Use Specular Color", Float) = 0
        _BumpScale                      ("BumpScale", Range(0, 2)) = 1.0
        _SmoothnessMin                  ("SmoothnessMin", Range(0, 1)) = 0
        _SmoothnessMax                  ("SmoothnessMax", Range(0, 1)) = 1
        _MetallicMin                    ("MetallicMin", Range(0, 1)) = 0
        _MetallicMax                    ("MetallicMax", Range(0, 1)) = 1
        _SpecColor                      ("Specular", Color) = (0.2, 0.2, 0.2)
        _OcclusionStrength              ("AO_Strength", Range(0.0, 1.0)) = 1.0
        // _OcclusionPow                   ("OcclusionPow", Range(0.1, 5.0)) = 1.0
        
        [Header(Dissolve)] [Space(10)]
        [SingleLineTexture] _NoiseMap   ("Noise Map", 2D)       = "white" {}
        _Dissolve                       ("Dissolve", Range(-0.5, 1.5)) = 0.0
        _EdgeColor                      ("EdgeColor", Color) = (0.2, 0.2, 0.2)
        _EdgeWidth                      ("EdgeWidth", Range(0, 0.2)) = 0.0
        _NoiseTillingOffset             ("Noise Tilling Offset", Vector) = (1,1,0,0)
        
        [Header(Fresnel)] [Space(10)]
        _FXIntensityBack                ("FXIntensityBack", Range(0, 1)) = 0.0
        _FXIntensity                    ("FXIntensity", Range(0, 1)) = 1.0
        _FresnelPower                   ("Fresnel Power", Range(0.1, 5)) = 5.0
        [HDR]_FXColor                   ("FXColor", Color) = (0.2, 0.2, 0.2)
        
        [Header(Final Test)] [Space(10)]
        [Toggle(_TEST)] _TEST ("使用测试", Float) = 0
        
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }

    SubShader
    {
        Tags
        {
             "RenderPipeline" = "UniversalPipeline"
             "RenderType"     = "Transparent"
             "Queue"          = "Transparent"
        }
        
        HLSLINCLUDE
        #pragma prefer_hlslcc gles
        #pragma only_renderers d3d11 metal
        
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        //------------ SurfaceInput.hlsl ----------------
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
        #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_Lighting.hlsl"
        #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_BRDF.hlsl"

        // ----------------- 简单 GGX PBR 工具函数 -----------------
        inline half3 FresnelSchlick(half cosTheta, half3 F0)
        {
            // Schlick 近似：F = F0 + (1 - F0) * (1 - cos)^5
            return F0 + (1.0h - F0) * pow(saturate(1.0h - cosTheta), 5.0h);
        }
        
        ENDHLSL

        
        Pass
        {
            Name "HairOITDepth"
            Tags { "LightMode" = "HairOITDepth" }

            ZWrite On
            ZTest LEqual
            Cull Off
            ColorMask 0

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex   vert
            #pragma fragment frag_depth
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NoiseMap); SAMPLER(sampler_NoiseMap);
            float4 _BaseMap_ST;

            CBUFFER_START(UnityPerMaterial)
                float4 _NoiseTillingOffset;
                half4 _BaseColor;
                half  _Cutoff;

                // 如果你想深度更“厚/薄”，单独给 depth 用一个阈值最好
                half  _DepthCutoff; // 你也可以复用 _Cutoff
                half _Dissolve;
                half _LOD;
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

                o.positionCS = TransformObjectToHClip(input.positionOS);
                o.uv         = TRANSFORM_TEX(input.uv, _BaseMap);
                return o;
            }

            half4 frag_depth(Varyings i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                // TODO 将LOD的计算方法添加Offset
                // half a = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, i.uv, _LOD).a * _BaseColor.a;
                half a = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv).a * _BaseColor.a;
                
                // 深度体积阈值：建议比颜色更“硬一点”，形成稳定遮挡骨架
                // 例如 _DepthCutoff = 0.2~0.35（视贴图而定）    ?
                half dissolve = clamp(_Dissolve,0,1);

                float NoiseUV_Speed_X = _NoiseTillingOffset.z * _Time.x;
                float NoiseUV_Speed_Y = _NoiseTillingOffset.w * _Time.y;
                float2 NoiseUV = i.uv * _NoiseTillingOffset.xy + float2(NoiseUV_Speed_X, NoiseUV_Speed_Y);
                
                half3 NoiseMapValue = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, NoiseUV).r;
                NoiseMapValue = saturate(NoiseMapValue);

                half AlphaValue145 = step( _Dissolve, NoiseMapValue.r );
                // clip(AlphaValue145 - _Cutoff);
                
                clip(a - dissolve - _DepthCutoff);

                // return half4(1, 0, 0, 1);
                return 0;
            }
            ENDHLSL
        }

        // ============================================================
        // Pass 0: WBOIT accumulate pass (MRT)
        // 进入 WBOIT 的关键：LightMode = HairOIT
        // 输出：
        //  RT0 (accum): rgb = color * alpha * w, a = alpha * w
        //  RT1 (reveal): r = alpha   (配合 Blend 1 做 “reveal *= (1 - alpha)” 的等效累计)
        // ============================================================
        Pass
        {
            Name "HairOIT"
            Tags { "LightMode" = "HairOIT" }

            ZWrite Off
            ZTest LEqual
            Cull Off

            // MRT blend：
            // RT0: 加法累积
            Blend 0 One One
            // RT1: 累积透过量（等效做 reveal *= (1 - alpha)）
            // 这里采用常见的写法：dst = dst * (1 - srcAlpha)
            // 约定 RT1 输出 alpha 到 .r，并让 srcAlpha = alpha（见 frag）
            Blend 1 Zero OneMinusSrcColor

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex   vert
            #pragma fragment frag_oit

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local USE_SPECULAR_COLOR
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _TEST
            
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment  _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fragment  _ SHADOWS_SHADOWMASK

            // XR / instancing
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            //------------ SurfaceInput.hlsl ----------------
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
            #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_BRDF.hlsl"
            // #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_Lighting.hlsl"
            // #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_BRDF.hlsl"

            
            float4 _BaseMap_ST;
            CBUFFER_START(UnityPerMaterial)
                half  _OITDepthBeta;
                half  _OITDepthEps;

                half  _OITAlphaScale;
                half  _OITAlphaBias;
                half  _OITAlphaGamma;

                half _Alpha;
                half _AlphaMin;
                half _AlphaMax;

                half _LOD;

                half4 _BaseColor;
                half4 _SpecColor;
                half4 _EmissionColor;
                half4 _TillingOffset;
            
                half _Cutoff;
                half _SmoothnessMax;
                half _SmoothnessMin;
                half _MetallicMin;
                half _MetallicMax;
                half _BumpScale;
                half _Parallax;
                half _OcclusionStrength;
                // half _OcclusionPow;
                half _Surface;

                // FX Dissolve
                half4 _NoiseTillingOffset;
                half _Dissolve;
                half4 _EdgeColor;
                half _EdgeWidth;

                // FX Fresnel
                half _FXIntensity;
                half _FXIntensityBack;
                half _FresnelPower;
                half4 _FXColor;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
            CBUFFER_END

            TEXTURE2D(_AlbedoMap);          SAMPLER(sampler_AlbedoMap);
            TEXTURE2D(_AlphaCrack);         SAMPLER(sampler_AlphaCrack);
            TEXTURE2D(_BumpMap);            SAMPLER(sampler_BumpMap);
            TEXTURE2D(_EmissionMap);        SAMPLER(sampler_EmissionMap);
            TEXTURE2D(_ARMMaskMap);         SAMPLER(sampler_ARMMaskMap);
            TEXTURE2D(_NoiseMap);           SAMPLER(sampler_NoiseMap);

            // ============================
            // Structs
            // ============================
            struct SurfaceDataHair
            {
                half3 baseColor;
                half  alpha;
                half3 normalTS;
                half  metallic;
                half  smoothness;
                half  occlusion;
                half3 F0;
            };

            struct InputDataHair
            {
                float2 uv;
                float2 ssuv;
                float3 positionWS;
                half3  normalWS;
                half3  viewDirWS;
                float4 shadowCoord;
                half3  vertexSH;
                float2 staticLightmapUV;
            };

            struct FragOutOIT
            {
                half4 accum  : SV_Target0; // RGBA
                half4 reveal : SV_Target1; // 我们只用 r，但写 half4 更保险
            };
            
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;
                float2 uv         : TEXCOORD0;
                float2 staticLightmapUV   : TEXCOORD1;
                float2 dynamicLightmapUV  : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS               : SV_POSITION;
                float2 uv                       : TEXCOORD0;
                float3 positionWS               : TEXCOORD1;
                float3 normalWS                 : TEXCOORD2;
                float3 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
                float3 ViewDirWS                : TEXCOORD4;    // 视线方向ws
                half4 fogFactorAndVertexLight   : TEXCOORD5;    // x: fogFactor, yzw: vertex light
                float4 shadowCoord              : TEXCOORD6;    // REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
                float2 dynamicLightmapUV        : TEXCOORD7;    // Dynamic lightmap UVs
                // DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
                // 以下是对宏解释
                float2 staticLightmapUV         : TEXCOORD8;
                half3  vertexSH                 : TEXCOORD9;
                float3 bitangentWS              : TEXCOORD10;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // ============================
            // Sampling
            // ============================
            SurfaceDataHair SampleSurface(Varyings i)
            {
                SurfaceDataHair s;

                // half4 albedoMapColor = SAMPLE_TEXTURE2D_LOD(_AlbedoMap, sampler_AlbedoMap, i.uv, _LOD);
                // s.normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D_LOD(_BumpMap, sampler_BumpMap, i.uv, _LOD), _BumpScale);

                half4 albedoMapColor = SAMPLE_TEXTURE2D(_AlbedoMap, sampler_AlbedoMap, i.uv);
                s.normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv), _BumpScale);

                half3 armMaskMap = SAMPLE_TEXTURE2D(_ARMMaskMap, sampler_ARMMaskMap, i.uv).rgb;

                half alphaRaw = saturate(albedoMapColor.a * _BaseColor.a);
                s.alpha = alphaRaw;
                s.baseColor = albedoMapColor.rgb * _BaseColor.rgb;

                s.metallic   = lerp(_MetallicMin,   _MetallicMax,   armMaskMap.b);
                s.smoothness = lerp(_SmoothnessMin, _SmoothnessMax, armMaskMap.g);

                // 你当前选的“乘法 occlusion”我保留
                s.occlusion = saturate(albedoMapColor.a * _OcclusionStrength);

                const half3 dielectricF0 = half3(0.04h, 0.04h, 0.04h);

                #ifdef USE_SPECULAR_COLOR
                    s.F0 = _SpecColor.rgb;
                #else
                    // 标准金属度模型：F0 = lerp(dielectricF0, baseColor, metallic)
                    s.F0 = lerp(dielectricF0, s.baseColor, s.metallic);
                #endif

                return s;
            }

            // ============================
            // Input build
            // ============================
            InputDataHair BuildInputData(Varyings i, half3 normalWS)
            {
                InputDataHair d;
                d.uv = i.uv;
                d.ssuv = GetNormalizedScreenSpaceUV(i.positionCS);
                d.positionWS = i.positionWS;
                d.normalWS = normalWS;
                d.viewDirWS = normalize(i.ViewDirWS);
                d.shadowCoord = i.shadowCoord;
                d.vertexSH = i.vertexSH;
                d.staticLightmapUV = i.staticLightmapUV;
                return d;
            }

            // ============================
            // Direct lighting for one light (your BRDF)
            // ============================
            half3 ComputeDirectPBR(BRDFData brdfData, half3 N, half3 V, half3 L, half3 lightColor, half atten)
            {
                half NdotL = saturate(dot(N, L));
                if (NdotL <= 0) return 0;

                half3 radiance = lightColor * (atten * NdotL);

                // 你的写法：diffuse + specular * DirectBRDFSpecular_ShiER(...)
                half3 brdf = brdfData.diffuse;
                brdf += brdfData.specular * DirectBRDFSpecular_ShiER(brdfData, N, L, V);

                return radiance * brdf;
            }

            // ============================
            // Main + Additional
            // ============================
            half3 ComputeMainLightPBR(InputDataHair IN, BRDFData brdfData, half4 shadowMask)
            {
                Light mainLight = GetMainLight(IN.shadowCoord, IN.positionWS, shadowMask);
                half atten = mainLight.distanceAttenuation * mainLight.shadowAttenuation;
                return ComputeDirectPBR(brdfData, IN.normalWS, IN.viewDirWS, normalize(mainLight.direction), mainLight.color, atten);
            }

            half3 ComputeAdditionalLightsPBR(InputDataHair IN, BRDFData brdfData, half4 shadowMask)
            {
                half3 sum = 0;

                #if defined(_ADDITIONAL_LIGHTS)
                    uint lightCount = GetAdditionalLightsCount();

                    // 重要：VP 上建议给一个上限，避免爆循环成本（你可调）
                    uint capped = min(lightCount, (uint)4);

                    for (uint li = 0; li < capped; li++)
                    {
                        Light light = GetAdditionalLight(li, IN.positionWS, shadowMask);
                        half atten = light.distanceAttenuation * light.shadowAttenuation;
                        sum += ComputeDirectPBR(brdfData, IN.normalWS, IN.viewDirWS, normalize(light.direction), light.color, atten);
                    }
                #endif

                #if defined(_ADDITIONAL_LIGHTS_VERTEX)
                    // 你已经在 vert 算了 vertexLight，但你当前没把它加进 finalColor
                    // 如果你希望它生效，可以在外面把 i.fogFactorAndVertexLight.yzw 加进去（见 frag 末尾）
                #endif

                return sum;
            }

            // ============================
            // IBL (SH + Reflection Probe)
            // ============================
            half3 ComputeIBL(InputDataHair IN, SurfaceDataHair S, BRDFData brdfData)
            {
                // Ambient Occlusion factor (URP)
                AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(IN.ssuv, S.occlusion);
            
                // Baked GI
                half3 bakedGI = SAMPLE_GI(IN.staticLightmapUV, IN.vertexSH, IN.normalWS);
            
                // Diffuse ambient from SH
                half3 sh = SampleSH(IN.normalWS);
                half3 diffuseEnv = S.baseColor * sh * S.occlusion;
            
                // Specular environment
                half3 R = reflect(-IN.viewDirWS, IN.normalWS);
                half NdotV = saturate(dot(IN.normalWS, IN.viewDirWS));
                half3 F_env = FresnelSchlick(NdotV, S.F0);
            
                half perceptualRoughness = 1 - S.smoothness;
                half3 specEnv = GlossyEnvironmentReflection(R, perceptualRoughness, aoFactor.indirectAmbientOcclusion);
                half3 specEnvColor = EnvironmentBRDF(brdfData, bakedGI, specEnv, F_env);
            
                return diffuseEnv + specEnvColor * S.occlusion;
            }

            // ============================
            // FX (dissolve + fresnel emission)
            // ============================
            half3 ApplyFX(InputDataHair IN, half3 baseLitColor)
            {
                float NoiseUV_Speed_X = _NoiseTillingOffset.z * _Time.x;
                float NoiseUV_Speed_Y = _NoiseTillingOffset.w * _Time.y;
                float2 NoiseUV = IN.uv * _NoiseTillingOffset.xy + float2(NoiseUV_Speed_X, NoiseUV_Speed_Y);

                half noise = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, NoiseUV).r;
                noise = saturate(noise);

                // dissolve clip
                half alphaStep = step(_Dissolve, noise);
                clip(alphaStep - _Cutoff);

                // edge emission
                half3 emission = step((noise.xxx - _EdgeWidth), _Dissolve) * _EdgeColor.rgb;

                // fresnel emission
                half NdotV = saturate(dot(IN.normalWS, IN.viewDirWS));
                half fresnel = (_FXIntensityBack * _FXIntensity) * pow(1.0h - NdotV, _FresnelPower);
                emission += _FXColor.rgb * fresnel;

                return baseLitColor + emission;
            }

            // ============================
            // OIT encode
            // ============================
            FragOutOIT EncodeOIT(half3 finalColor, half alphaRaw, float4 positionCS)
            {
                // 策略2：Alpha 预处理（防“雾化”）
                half a = saturate(alphaRaw * _OITAlphaScale - _OITAlphaBias);
                a = pow(a, max(_OITAlphaGamma, 1e-5h));

                // 策略1：深度权重（前层更有话语权）
                // 似乎没有效果 查bug
                float ndcZ = positionCS.z / positionCS.w;
                float depth01 = ndcZ * 0.5f + 0.5f;
                float eyeDepth = LinearEyeDepth(depth01, _ZBufferParams);
                float w = rcp(_OITDepthEps + pow(max(eyeDepth, 1e-5f), _OITDepthBeta));

                half a_w = (half)w * a;

                // -------------------------
                // 深度权重版本的测试
                // -------------------------
                // float dVis = saturate(eyeDepth / 10.0); // 假设2m内主要活动范围


                FragOutOIT o;
                o.accum = half4(finalColor * a_w, a_w);
                // o.accum = half4(dVis, dVis, dVis, dVis);
                o.reveal = half4(a, 0, 0, a);
                // o.reveal = half4(dVis, 0, 0, 1);
                return o;
            }

            // ============================
            // Vertex / Fragment
            // ============================
            Varyings vert(Attributes input)
            {
                Varyings o = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput   = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                o.uv = input.uv;

                o.normalWS    = normalize(normalInput.normalWS);
                o.tangentWS   = normalInput.tangentWS;
                o.bitangentWS = normalize(normalInput.bitangentWS);

                // FIX: 输出到 o
                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, o.staticLightmapUV);
                o.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                OUTPUT_SH(normalInput.normalWS, o.vertexSH);

                half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

                o.positionWS  = vertexInput.positionWS;
                o.shadowCoord = GetShadowCoord(vertexInput);
                o.positionCS  = vertexInput.positionCS;
                o.ViewDirWS   = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);

                return o;
            }

            FragOutOIT frag_oit(Varyings i)
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                // --- Surface
                SurfaceDataHair S = SampleSurface(i);

                // --- TBN -> normalWS
                half3x3 tangentToWorld = half3x3(i.tangentWS, i.bitangentWS, i.normalWS);
                half3 normalWS = normalize(TransformTangentToWorld(S.normalTS, tangentToWorld));

                // --- Input
                InputDataHair IN = BuildInputData(i, normalWS);

                // --- BRDF init (your custom)
                BRDFData brdfData;
                InitializeBRDFData_ShiER(S.baseColor, S.metallic, S.F0, S.smoothness, S.alpha, brdfData);

                // --- Shadows / GI
                half4 shadowMask = SAMPLE_SHADOWMASK(IN.staticLightmapUV);

                // --- Direct lights
                half3 directMain = ComputeMainLightPBR(IN, brdfData, shadowMask);
                half3 directAdd  = ComputeAdditionalLightsPBR(IN, brdfData, shadowMask);

                // --- IBL
                half3 ibl = ComputeIBL(IN, S, brdfData);

                half3 finalColor = directMain + directAdd + ibl;

                // 可选：如果你希望 vertexLight 生效（_ADDITIONAL_LIGHTS_VERTEX 路径），加这一句
                // finalColor += i.fogFactorAndVertexLight.yzw;

                // --- FX
                finalColor = ApplyFX(IN, finalColor);

                // --- OIT output
                return EncodeOIT(finalColor, S.alpha, i.positionCS);
            }
            
            ENDHLSL
        }

        // ============================================================
        // Pass: HairOITResolve  (no overrideMaterial, VP safe)
        // 作用：在“头发几何体覆盖的区域”把 sceneCopy + (accum/reveal) 合成后写回 CameraColor
        // 依赖：RenderFeature 先 SetGlobalTexture(_OITAccumTex/_OITRevealTex)
        //      CopyFeature/本Feature 已把 _ShiER_CameraColorCopy 设为全局
        // ============================================================
        Pass
        {
            Name "HairOITResolve"
            Tags { "LightMode" = "HairOITResolve" }

            Cull Off
            ZWrite On
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
            // Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 4.0
            #pragma vertex   vert_resolve
            #pragma fragment frag_resolve
            #pragma multi_compile_instancing
            #pragma only_renderers d3d11 metal

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)

                // 如果你想深度更“厚/薄”，单独给 depth 用一个阈值最好
                half  _Alpha; // 你也可以复用 _Cutoff
            CBUFFER_END

            // WBOIT RT（RenderFeature 会 SetGlobalTexture）
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

            Varyings vert_resolve(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 positionWS  = TransformObjectToWorld(input.positionOS);
                output.positionCS  = TransformWorldToHClip(positionWS);
                return output;
            }

            half4 frag_resolve(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = GetNormalizedScreenSpaceUV(input.positionCS);
                
                // 测试 03
                // sampler_LinearClamp -> sampler_LinearRepeat
                half4 accum  = SAMPLE_TEXTURE2D_X(_OITAccumTex,  sampler_OITAccumTex,  uv);
                half  reveal = SAMPLE_TEXTURE2D_X(_OITRevealTex, sampler_OITRevealTex, uv).r;

                half oitAlpha = saturate((1.0h - reveal) * _Alpha);
                half invW = rcp(max(accum.a, 1e-4h));
                half3 oitColor = accum.rgb * invW;

                // 直接覆盖回 CameraColor（Blend One Zero），alpha 保持 scene 的
                return half4(oitColor, oitAlpha);
                // return half4(reveal, reveal, reveal, oitAlpha);
                // return half4(invW, invW, invW, 1);
            }
            ENDHLSL
        }

        // ============================================================
        // Pass: Shadow Caster
        // 作用：投射阴影
        // ============================================================
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Off
            
            HLSLPROGRAM
            #pragma target 2.0
            #pragma vertex   ShadowVert
            #pragma fragment ShadowFrag
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _NO_SHADOWCAST
            // 需要支持点光/聚光的阴影投射时的变体
            // #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            TEXTURE2D(_AlbedoMap);          SAMPLER(sampler_AlbedoMap);
            half _Cutoff;
            half _Dissolve;

            // —— 我们自己实现一个与 URP 等价的函数 —— //
            float4 GetShadowPositionHClip(VertexPositionInputs vpos, half3 normalWS)
            {
                float3 lightDirWS;

                #if defined(_CASTING_PUNCTUAL_LIGHT_SHADOW)
                    // 点光/聚光：从光源位置指向当前点
                    lightDirWS = normalize(_LightPosition.xyz - vpos.positionWS);
                #else
                    // 平行光：方向由 _MainLightPosition 提供（xyz 为方向）
                    lightDirWS = _MainLightPosition.xyz;
                #endif

                // 施加阴影偏移并变换到裁剪空间
                float3 posWSBiased = ApplyShadowBias(vpos.positionWS, normalWS, lightDirWS);
                float4 posCS       = TransformWorldToHClip(posWSBiased);

                // 逼近近平面（和 URP 的 ShadowCasterPass 一致）
                #if UNITY_REVERSED_Z
                    posCS.z = min(posCS.z, UNITY_NEAR_CLIP_VALUE);
                #else
                    posCS.z = max(posCS.z, UNITY_NEAR_CLIP_VALUE);
                #endif
                return posCS;
            }

            struct A
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct V 
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            V ShadowVert(A IN)
            {
                V OUT;
                VertexPositionInputs vpos = GetVertexPositionInputs(IN.positionOS.xyz);
                half3 normalWS = TransformObjectToWorldNormal(IN.normalOS);

                OUT.positionCS = GetShadowPositionHClip(vpos, normalWS);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 ShadowFrag(V IN) : SV_Target
            {
                #if defined(_NO_SHADOWCAST)
                    clip(-1);        // 永远丢弃 → 不写入阴影贴图
                    return 0;
                #endif
                #if defined(_ALPHATEST_ON)
                    half a = SAMPLE_TEXTURE2D(_AlbedoMap, sampler_AlbedoMap, IN.uv).a;
                    clip(a * (1-_Dissolve) - _Cutoff);
                #endif
                return 0;
            }
            ENDHLSL
        }

        
    }

    FallBack Off
}
