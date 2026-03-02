// --------------------------------
// 一个基础的 Lit Shader 模板，支持XR项目，主要支持的功能如下
// - XR平台的渲染：URP VisionPro Metal only
// - 不透明物体 + alphaClip
// - 不投射阴影 不写入深度 不需要光照烘焙
// - 可以自定义环境高光
// --------------------------------

Shader "ShiERTest/ShaderLab/003_Lit_XR_CustomReflect"
{
    Properties
    {
        [Header(PBR GGX different with unity)] [Space(10)]
        [SingleLineTexture] _BaseMap                ("Albedo", 2D)      = "white" {}
        [SingleLineTexture] _ARMMaskMap             ("ARMMaskMap", 2D)  = "white" {}
        [SingleLineTexture] _EmissionMap            ("EmissionMap", 2D) = "black" {}
        [SingleLineTexture] _BumpMap                ("Normal Map", 2D)  = "bump" {}
        
        _BaseColor          ("Base Color", Color) = (1,1,1,1)
        _TillingOffset      ("TillingOffset", Vector) = (1,1,0,0)
        _BumpScale          ("Normal Scale", Range(0.0, 2.0)) = 1.0
        _SmoothnessMin      ("SmoothnessMin", Range(0.0, 1.0)) = 0
        [Header(GGX Max smoothness is 0.6)]
        _SmoothnessMax      ("SmoothnessMax", Range(0.0, 1.0)) = 0.2
        _MetallicMin        ("MetallicMin", Range(0.0, 1.0)) = 0
        _MetallicMax        ("MetallicMax", Range(0.0, 1.0)) = 0.2
        _OcclusionStrength  ("OcclusionStrength", Range(0.0, 1.0)) = 0.2
        
        [Header(PBR CubeMap)] [Space(10)]
        [SingleLineTexture] _EnvCubeMap      ("Environment CubeMap", Cube)  = "" {}
        _EnvCubeIntensity   ("Env Intensity", Range(0.0, 8.0)) = 1.0
        _EnvCubeMaxMip      ("Env Max Mip", Range(0.0, 10.0)) = 7.0

        [Toggle(_ALPHATEST_ON)]
        _AlphaClip      ("Alpha Clip", Float) = 0
        _Cutoff         ("Alpha Cutoff", Range(0,1)) = 0.5
    }

    SubShader
    {
        
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
            "Queue" = "Geometry"
        }
        LOD 0
        
        Cull Off
        ZWrite On
        ZTest LEqual
        Blend One Zero     // 纯不透明
        
        HLSLINCLUDE

        #ifndef UNITY_INV_PI
            #define UNITY_INV_PI 0.31830988618      // 1.0 / PI
        #endif

        #ifndef UNITY_PI
            #define UNITY_PI 3.14159265359
        #endif

        #ifndef UNITY_FLT_MIN
            #define UNITY_FLT_MIN 1e-6   // 或 1e-6，根据你的 roughness 需求可调
        #endif

        
        #pragma target 4.0
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

        // ---------- Per-Material 常量（SRP Batcher） ----------
        CBUFFER_START(UnityPerMaterial)
            half4 _TillingOffset;
            float4 _BaseColor;
            float4 _BaseMap_ST;
            float  _Cutoff;
            half _BumpScale;
            half _SmoothnessMin;
            half _SmoothnessMax;
            half _MetallicMin;
            half _MetallicMax;
            half _OcclusionStrength;

            half _EnvCubeIntensity;
            half _EnvCubeMaxMip;
        CBUFFER_END
        
        TEXTURE2D(_BaseMap);                SAMPLER(sampler_BaseMap);
        TEXTURE2D(_ARMMaskMap);             SAMPLER(sampler_ARMMaskMap);
        TEXTURE2D(_BumpMap);                SAMPLER(sampler_BumpMap);
        TEXTURE2D(_EmissionMap);            SAMPLER(sampler_EmissionMap);
        TEXTURECUBE(_EnvCubeMap);           SAMPLER(sampler_EnvCubeMap);

        // ----------------- 简单 GGX PBR 工具函数 -----------------

        inline half3 FresnelSchlick(half cosTheta, half3 F0)
        {
            // Schlick 近似：F = F0 + (1 - F0) * (1 - cos)^5
            return F0 + (1.0h - F0) * pow(saturate(1.0h - cosTheta), 5.0h);
        }

        inline half DistributionGGX(half NdotH, half roughness)
        {
            half a  = roughness * roughness;
            half a2 = a * a;
            half denom = (NdotH * NdotH) * (a2 - 1.0h) + 1.0h;
            return a2 / max(UNITY_FLT_MIN, denom * denom);
        }

        inline half GeometrySchlickGGX(half NdotV, half roughness)
        {
            // 直接用 UE 风格的 k 近似
            half r = roughness + 1.0h;
            half k = (r * r) * 0.125h;      // (r^2)/8
            return NdotV / (NdotV * (1.0h - k) + k);
        }

        inline half GeometrySmith(half NdotV, half NdotL, half roughness)
        {
            half ggx1 = GeometrySchlickGGX(NdotV, roughness);
            half ggx2 = GeometrySchlickGGX(NdotL, roughness);
            return ggx1 * ggx2;
        }
        

        // ----------------- 自定义环境高光采样（用自己的 Cubemap） -----------------

        inline half3 SampleEnvSpecular_ShiER(half3 reflectVector, half perceptualRoughness, half occlusion)
        {
        #if defined(_ENVIRONMENTREFLECTIONS_OFF)
            return 0.0h;
        #else
            // perceptualRoughness [0,1] -> Mip [0, _EnvCubeMaxMip]
            half mip = saturate(perceptualRoughness) * _EnvCubeMaxMip;

            half3 env = SAMPLE_TEXTURECUBE_LOD(_EnvCubeMap, sampler_EnvCubeMap, reflectVector, mip).rgb;

            // 这里假设 _EnvCube 已经是线性 HDR 贴图，不再做 DecodeHDR
            return env * _EnvCubeIntensity * occlusion;
        #endif
        }

        
        ENDHLSL

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Cull Off
            ZWrite On
            ZTest LEqual
            Blend One Zero // SrcAlpha OneMinusSrcAlpha     // 纯不透明

            HLSLPROGRAM
            #pragma target 4.0

            // --- 编译选项 ---
            #pragma vertex   vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #define _NORMALMAP 1
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _EYE_EMISSION_MASK_ON
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ _FORWARD_PLUS
            #pragma multi_compile _ LIGHTMAP_ON // 没有间接光？
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            // —— 关键：混合光 Shadowmask 路线 —— //
            #pragma multi_compile_fragment  _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fragment  _ SHADOWS_SHADOWMASK

            struct Attributes
            {
                float3 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;
                float2 texcoord     : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 texcoord                 : TEXCOORD0;
                float3 positionWS               : TEXCOORD1;
                float3 normalWS                 : TEXCOORD2;
                float4 tangentWS                : TEXCOORD3;
                float3 ViewDirWS                : TEXCOORD4;
                float3 bitangentWS              : TEXCOORD5;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            

            Varyings vert (Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                // Normal
                output.normalWS = normalize(normalInput.normalWS);
                // Tangent
                real sign = input.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
                output.tangentWS = tangentWS;
                output.bitangentWS = normalInput.bitangentWS;
                
                output.positionWS = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                float3 ViewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
                output.ViewDirWS = ViewDirWS;
                
                output.texcoord = input.texcoord * _TillingOffset.xy + _TillingOffset.zw;
                
                return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // ---------------- 采样纹理 -------------------
                half4 albedoAlpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.texcoord);
                // 乘上 _BaseColor
                albedoAlpha.rgb *= (half3)_BaseColor.rgb;
                albedoAlpha.a   *= (half)_BaseColor.a;
                
                half3 ARMMaskColor = SAMPLE_TEXTURE2D(_ARMMaskMap, sampler_ARMMaskMap, input.texcoord);
                half metallic = lerp(_MetallicMin, _MetallicMax, ARMMaskColor.b);
                half smoothness = lerp(_SmoothnessMin, _SmoothnessMax, ARMMaskColor.g);
                half occlusion = LerpWhiteTo(ARMMaskColor.r, _OcclusionStrength);
                
                half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.texcoord), _BumpScale);
                half3 specular = half3(0.1, 0.1, 0.1);

                // 提前做 AlphaClip，省掉后面光照的开销
                #if defined(_ALPHATEST_ON)
                    clip(albedoAlpha.a - _Cutoff);
                #endif

                // ---------------- 构建TBN矩阵 -------------------
                float sgn = input.tangentWS.w;      // should be either +1 or -1
                float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                //TBN
                half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
                half3 normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
                normalWS = NormalizeNormalPerPixel(normalWS);
                
                
                // ----------------- 3. PBR 参数（Metallic 工作流） -----------------
                half3 baseColor = albedoAlpha.rgb;
                half perceptualRoughness = 1.0h - smoothness;
                half roughness = max(0.002h, perceptualRoughness * perceptualRoughness);

                // F0：金属用 baseColor，非金属用 0.04
                const half3 dieletricF0 = half3(0.04h, 0.04h, 0.04h);
                half3 F0 = lerp(dieletricF0, baseColor, metallic);

                half NdotV = saturate(dot(normalWS, input.ViewDirWS));

                //TODO 反射不对 InitializeBRDFData_ShiER()

                // ----------------- 4. 直接光（主光 + 额外灯光） -----------------
                half3 directLighting = 0;

                // ---- 主光 ----
                Light mainLight = GetMainLight();          // 不带 shadowCoord 的版本
                {
                    float3 L = mainLight.direction;
                    half  NdotL = saturate(dot(normalWS, L));
                    if (NdotL > 0.0h)
                    {
                        float3 H = SafeNormalize(L + input.ViewDirWS);
                        half  NdotH = saturate(dot(normalWS, H));
                        half  LdotH = saturate(dot(L, H));

                        half  D  = DistributionGGX(NdotH, roughness);
                        half  G  = GeometrySmith(NdotV, NdotL, roughness);
                        half3 F  = FresnelSchlick(LdotH, F0);

                        half3 numerator = D * G * F;
                        half  denom     = max(0.001h, 4.0h * NdotV * NdotL);
                        half3 specular  = numerator / denom;

                        // 漫反射系数：能量守恒 (1-F) 且金属不参与漫反射
                        half3 kd = (1.0h - F) * (1.0h - metallic);
                        half3 diffuse = kd * baseColor * UNITY_INV_PI;

                        half3 radiance = mainLight.color *
                                         (mainLight.distanceAttenuation * mainLight.shadowAttenuation * NdotL);

                        directLighting += (diffuse + specular) * radiance;
                    }
                }
                // ---- 额外灯光 ----
                #if defined(_ADDITIONAL_LIGHTS)
                {
                    int additionalLightsCount = GetAdditionalLightsCount();
                    for (int i = 0; i < additionalLightsCount; i++)
                    {
                        Light light = GetAdditionalLight(i, input.positionWS);
                        float3 L = light.direction;
                        half  NdotL = saturate(dot(normalWS, L));
                        if (NdotL <= 0.0h)
                            continue;

                        float3 H = normalize(L + input.ViewDirWS);
                        half  NdotH = saturate(dot(normalWS, H));
                        half  LdotH = saturate(dot(L, H));

                        half  D  = DistributionGGX(NdotH, roughness);
                        half  G  = GeometrySmith(NdotV, NdotL, roughness);
                        half3 F  = FresnelSchlick(LdotH, F0);

                        half3 numerator = D * G * F;
                        half  denom     = max(0.001h, 4.0h * NdotV * NdotL);
                        half3 specular  = numerator / denom;

                        half3 kd = (1.0h - F) * (1.0h - metallic);
                        half3 diffuse = kd * baseColor * UNITY_INV_PI;

                        half3 radiance = light.color *
                                         (light.distanceAttenuation * light.shadowAttenuation * NdotL);

                        directLighting += (diffuse + specular) * radiance;
                    }
                }
                #endif
                // ----------------- 5. Unity 环境光（环境 SH + 反射探头） -----------------
                // 环境漫反射：Unity 的 Ambient（Environment Lighting -> Ambient Color / Gradient）
                half3 sh = SampleSH(normalWS); // 根据场景环境光 + Skybox 预计算出来的 SH
                half3 F_env  = FresnelSchlick(NdotV, F0);
                half3 kd_env = (1.0h - F_env) * (1.0h - metallic);

                half3 diffuseEnv = kd_env * baseColor * sh * occlusion;

                // 环境高光：从反射探头 / Skybox 里采样，URP 自带函数
                float3 R = reflect(-input.ViewDirWS, normalWS);
                half3 specEnv = SampleEnvSpecular_ShiER(R, perceptualRoughness, occlusion) * F_env;
                half3 cubemapColor = SAMPLE_TEXTURECUBE_LOD(_EnvCubeMap, sampler_EnvCubeMap, R, 1).rgb;

                half3 iblLighting = diffuseEnv + specEnv;
                // half3 iblLighting = diffuseEnv + cubemapColor;

                // ----------------- 6. 自发光 -----------------
                half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, input.texcoord).rgb;

                // ----------------- 7. 最终颜色 -----------------
                half3 finalColor = directLighting + iblLighting + emission;

                return half4(finalColor, 1.0f);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
