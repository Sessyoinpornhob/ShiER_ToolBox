
// --------------------------------
// ShiER s Metallic workflow 
// - 标准的 PBR 材质，使用 Albedo Normal Metallic Glossiness(1 - Roughness) AO 在 SP 中导出Glossiness，但实际上当成 smoothness 在用。
// - - 基于 AO-Glossiness-Metallic 的纹理设置
// - 支持主光源的光照，支持多光源
// - 支持BRDF，【Cook-Torrance
// - 支持光照烘焙
// --------------------------------
// CustomLit_Opaque_Static
// - 静态的、烘焙光照的场景、环境
// - 取消菲涅尔效果
// - 取消溶解效果
// --------------------------------

Shader "ALab/CustomLit_Opaque_Static"
{
    Properties
    {
        // 以下是一些需要GUI修改的关键字 取消了[Toggle] 关键字的开关放在GUI
        [ShiERToggle]_NoShadowCast("不投射阴影", Float) = 0                                        // [Toggle(_NO_SHADOWCAST)]
        [ShiERToggle]_ReceiveShadows("Receive Shadows", Float) = 0.0                             // [Toggle(_RECEIVE_SHADOWS_OFF)]
        [ShiERToggle]_AlphaClip("Alpha Clipping", Float) = 0.0                                   // [Toggle(_ALPHATEST_ON)]
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        
        // [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        // [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
        
        // PBR 相关参数
        [ext] [Foldout] _PBR_Data("PBR_相关数据",Range (0,1)) = 0
        [ext] [if(_PBR_Data)] _TillingOffset("TillingOffset", Vector) = (1,1,0,0)
        [ext] [if(_PBR_Data)] [tipKey(_BaseColor)] _BaseColor("Color", Color) = (1,1,1,1)
        [ext] [if(_PBR_Data)] [SingleLineTexture] _BaseMap("Albedo", 2D) = "white" {}
        [ext] [if(_PBR_Data)] [SingleLineTexture] _ARMMaskMap("ARMMaskMap", 2D) = "white" {}
        [ext] [if(_PBR_Data)] [SingleLineTexture] _BumpMap("Normal Map", 2D) = "bump" {}
        [ext] [if(_PBR_Data)] _BumpScale("Normal Scale", Range(0.0, 2.0)) = 1.0
        [ext] [if(_PBR_Data)] _Crack("Crack", Range(0.0, 1.0)) = 0.0
        [ext] [if(_PBR_Data)] _SmoothnessMin("SmoothnessMin", Range(0.0, 1.0)) = 0
        [ext] [if(_PBR_Data)] _SmoothnessMax("SmoothnessMax", Range(0.0, 1.0)) = 0.2
        [ext] [if(_PBR_Data)] [Toggle(USE_SPECULAR_COLOR)] [tipKey(_UseSpecularColor)]_UseSpecularColor ("使用高光颜色", Float) = 0
        [ext] [if(_PBR_Data)] _SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
        [ext] [if(_PBR_Data)] _OcclusionStrength("AO_Strength", Range(0.0, 1.0)) = 1.0
        [ext] [if(_PBR_Data)] _MetallicMin("MetallicMin", Range(0.0, 1.0)) = 0
        [ext] [if(_PBR_Data)] _MetallicMax("MetallicMax", Range(0.0, 1.0)) = 0.2
        
        // 溶解效果
		[ext] [Foldout] _FX_Death_Dissolve_Regular_Foldout("溶解-常规",Range (0,1)) = 0
        [ext] [if(_FX_Death_Dissolve_Regular_Foldout)] [Toggle(FX_Death_Dissolve_Regular)] _FX_Death_Dissolve_Regular ("使用常规溶解", Float) = 1
        [ext] [if(_FX_Death_Dissolve_Regular_Foldout)] [SingleLineTexture] _NoiseMap("NoiseMap", 2D) = "white" {}
		[ext] [if(_FX_Death_Dissolve_Regular_Foldout)] _Dissolve("Dissolve", Range( -0.1 , 1.1)) = 0.5427703
        [ext] [if(_FX_Death_Dissolve_Regular_Foldout)] _NoiseTillingOffset("NoiseTillingOffset", Vector) = (1,1,1,1)
        
        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _Cull("__cull", Float) = 2.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 1.0
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0
        [HideInInspector] _AddPrecomputedVelocity("_AddPrecomputedVelocity", Float) = 0.0
        
        // Editmode props
        _QueueOffset("Queue offset", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }

    SubShader
    {
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }
        LOD 0
        
        // ======= Shared includes + one-and-only UnityPerMaterial (for ALL passes) =======
        HLSLINCLUDE
        #pragma target 5.0
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
        
        // NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
        CBUFFER_START(UnityPerMaterial)
            // PBR Data;
            half4 _BaseColor;
            half4 _SpecColor;
            half4 _TillingOffset;
        
            half _Cutoff;
            half _SmoothnessMax;
            half _SmoothnessMin;
            half _MetallicMin;
            half _MetallicMax;
            half _BumpScale;
            half _Parallax;
            half _OcclusionStrength;
            half _Surface;

            // FX Dissolve
            half4 _NoiseTillingOffset;
            half _Dissolve;
            UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        

        TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
        TEXTURE2D(_BumpMap);            SAMPLER(sampler_BumpMap);
        TEXTURE2D(_ARMMaskMap);         SAMPLER(sampler_ARMMaskMap);
        TEXTURE2D(_NoiseMap);           SAMPLER(sampler_NoiseMap);
        ENDHLSL
        
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // -------------------------------------
            // Render State Commands
            
            // 又出奇怪的混合bug了
            Blend One Zero, One OneMinusSrcAlpha // [_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            ZWrite On       // [_ZWrite]
            ZTest LEqual
            Cull [_Cull]
            // Cull Off
            AlphaToMask Off// [_AlphaToMask]   // 这个跟MSAA相关 不常用


            HLSLPROGRAM
            #pragma target 4.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            // -------------------------------------
            // Material Keywords
            #define _NORMALMAP 1
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            // -------------------------------------
            #pragma shader_feature_local USE_SPECULAR_COLOR
            // #ifdef USE_SPECULAR_COLOR
            //     outColor = half4(1,1,1,1);
            // #endif
            #pragma shader_feature_local FX_Death_Dissolve_Regular

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile MAIN_LIGHT_CALCULATE_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            // #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_HIGH
            // #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ LIGHTMAP_ON // 没有间接光？
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fragment _ FOG_EXP2
            // —— 关键：混合光 Shadowmask 路线 —— //
            #pragma multi_compile_fragment _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fragment _ SHADOWS_SHADOWMASK
            
            ///////////////////////////////////////////////////////////////////////////////
            //                      Material Property Helpers                            //
            ///////////////////////////////////////////////////////////////////////////////
            
            // #if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)))
            // #define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
            // #endif

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;
                float2 texcoord     : TEXCOORD0;
                float2 staticLightmapUV   : TEXCOORD1;
                float2 dynamicLightmapUV  : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                float3 positionWS               : TEXCOORD1;
                float3 normalWS                 : TEXCOORD2;
                float4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
                float3 ViewDirWS                : TEXCOORD4;    // 视线方向ws
                half4 fogFactorAndVertexLight   : TEXCOORD5;    // x: fogFactor, yzw: vertex light
                float4 shadowCoord              : TEXCOORD6;    // REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
                float2 dynamicLightmapUV        : TEXCOORD7;    // Dynamic lightmap UVs
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
                float3 bitangentWS              : TEXCOORD10;
                float4 positionCS               : SV_POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO

                // 这里顺序有要求
            #if defined(SHADER_STAGE_FRAGMENT)
                FRONT_FACE_TYPE cullFace        : FRONT_FACE_SEMANTIC;
            #endif
            };
            
            inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
            {
                half4 albedoAlpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half3 ARMMaskColor = half4(SAMPLE_TEXTURE2D(_ARMMaskMap, sampler_ARMMaskMap, uv)).rgb;
                
                outSurfaceData.alpha = albedoAlpha.a;
                outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
                // Metallic workflow
                outSurfaceData.metallic = lerp(_MetallicMin, _MetallicMax, ARMMaskColor.b);
                // 可以自定义高光颜色
                
                #ifdef USE_SPECULAR_COLOR
                    outSurfaceData.specular = _SpecColor;   // half3(0.0, 0.0, 0.0);
                #else
                    outSurfaceData.specular = half3(0.0, 0.0, 0.0);
                #endif
                

                outSurfaceData.smoothness           = lerp(_SmoothnessMin, _SmoothnessMax, ARMMaskColor.g);
                outSurfaceData.normalTS             = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv), _BumpScale);
                outSurfaceData.occlusion            = LerpWhiteTo(ARMMaskColor.r, _OcclusionStrength);
                outSurfaceData.emission             = half3(0,0,0);
                outSurfaceData.clearCoatMask        = half(0.0);
                outSurfaceData.clearCoatSmoothness  = half(0.0);
            }
            
            void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                
                inputData.positionWS = input.positionWS;
                half3 normalWS = normalize(input.normalWS);
                half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);

                // NormalMap
                float sgn = input.tangentWS.w;      // should be either +1 or -1
                float3 bitangent = sgn * cross(normalWS.xyz, input.tangentWS.xyz);
                half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, normalWS.xyz);
                inputData.tangentToWorld = tangentToWorld;
                inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                
                inputData.viewDirectionWS = viewDirWS;
                
                // inputData.shadowCoord = input.shadowCoord;
                inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);

                // 多光源
                inputData.fogCoord = InitializeInputDataFog(half4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
                inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
            }

            void InitializeBakedGIData(Varyings input, inout InputData inputData)
            {
                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
                inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
            }

            // 溶解特效计算函数 inout 输入输出都是此参数
            void InitialFXData(Varyings input, InputData inputData, inout SurfaceData outSurfaceData)
            {
                #ifdef _ALPHATEST_ON
                    clip(outSurfaceData.alpha - _Cutoff);  // 终止像素输出
                
                #ifdef FX_Death_Dissolve_Regular
				    half2 FX_Dissolve_UV = input.uv.xy * _NoiseTillingOffset.xy + _NoiseTillingOffset.zw * _TimeParameters;
				    half NoiseMapValue = SAMPLE_TEXTURE2D( _NoiseMap, sampler_NoiseMap, FX_Dissolve_UV).r;
                    // FX alpha
                    half AlphaValue145 = outSurfaceData.alpha * step( _Dissolve , NoiseMapValue );
                    clip(AlphaValue145 - _Cutoff);  // 终止像素输出
                    outSurfaceData.alpha = AlphaValue145;
                #else
                    outSurfaceData.alpha = 1;
                #endif
                #endif
            }

            ///////////////////////////////////////////////////////////////////////////////
            //                  Vertex and Fragment functions                            //
            ///////////////////////////////////////////////////////////////////////////////

            // Used in Standard (Physically Based) shader
            Varyings LitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // input.positionWS = TransformObjectToWorld(positionOS);
                // input.positionVS = TransformWorldToView(input.positionWS);
                // input.positionCS = TransformWorldToHClip(input.positionWS);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                float3 positionWS = TransformObjectToWorld(input.positionOS);   // World space position
                float4 positionCS = TransformWorldToHClip(positionWS);          // Homogeneous clip space position
                
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.uv = input.texcoord * _TillingOffset.xy + _TillingOffset.zw;
                
                output.normalWS = normalize(normalInput.normalWS);
                
                real sign = input.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
                output.tangentWS = tangentWS;
                output.bitangentWS = normalInput.bitangentWS;

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                OUTPUT_SH(normalInput.normalWS, output.vertexSH);

                // 多光源
                half fogFactor = ComputeFogFactor(positionCS.z);
                half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);
                output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                
                output.positionWS = positionWS;
                // REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR 
                output.shadowCoord = GetShadowCoord(vertexInput);
                output.positionCS = positionCS;
                output.ViewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);

                return output;
            }

            // Used in Standard (Physically Based) shader
            half4 LitPassFragment( Varyings input ) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // 处理单面模型的双面渲染问题
                #if defined(SHADER_STAGE_FRAGMENT)
                    half faceSign = IS_FRONT_VFACE(input.cullFace, 1.0h, -1.0h);
                #else
                    half faceSign = 1.0h; // 理论上这里不会走到，只是防守式写法
                #endif
                
                // 表面PBR信息
                SurfaceData surfaceData;
                // surfaceData.normalTS = TransformWorldToTangent(normalWS);
                InitializeStandardLitSurfaceData(input.uv, surfaceData);
                
                // 基础信息
                InputData inputData;
                InitializeInputData(input, surfaceData.normalTS, inputData);

                // 环境光照相关
                InitializeBakedGIData(input, inputData);

                // 特效计算函数
                InitialFXData(input, inputData, surfaceData);

                half4 color = UniversalFragmentPBR_ShiER_Base(inputData, surfaceData);
                color.rgb = MixFog(color.rgb, inputData.fogCoord);

                half shadowAmount = MainLightRealtimeShadow(inputData.shadowCoord);
                half fade = GetMainLightShadowFade(input.positionWS);
                // shadowAmount = lerp(1.0h, shadowAmount, fade);
                
                // color = inputData.fogCoord;
                return shadowAmount;
                // outColor = half4(surfaceData.alpha, surfaceData.alpha, surfaceData.alpha, 1);
            }
            
            ENDHLSL
        }
        
        // ShadowCaster Pass 按照通用的逻辑渲染阴影
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Back

            HLSLPROGRAM
            #pragma target 2.0
            #pragma vertex   ShadowPassVertex
            #pragma fragment ShadowPassFragment
            // #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _NO_SHADOWCAST
            // 需要支持点光/聚光的阴影投射时的变体
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

            // float3 _LightDirection;
            //
            // // —— 我们自己实现一个与 URP 等价的函数 —— //
            // float4 GetShadowPositionHClip(VertexPositionInputs vpos, half3 normalWS)
            // {
            //     float3 lightDirWS;
            //
            //     #if defined(_CASTING_PUNCTUAL_LIGHT_SHADOW)
            //         // 点光/聚光：从光源位置指向当前点
            //         lightDirWS = normalize(_LightPosition.xyz - vpos.positionWS);
            //     #else
            //         // 平行光：方向由 _MainLightPosition 提供（xyz 为方向）
            //         lightDirWS = _LightDirection;
            //     #endif
            //
            //     // 施加阴影偏移并变换到裁剪空间
            //     float3 posWSBiased = ApplyShadowBias(vpos.positionWS, normalWS, lightDirWS);
            //     float4 posCS       = TransformWorldToHClip(posWSBiased);
            //
            //     // 逼近近平面（和 URP 的 ShadowCasterPass 一致）
            //     #if UNITY_REVERSED_Z
            //         posCS.z = min(posCS.z, posCS.z * UNITY_NEAR_CLIP_VALUE);
            //     #else
            //         posCS.z = max(posCS.z, posCS.z * UNITY_NEAR_CLIP_VALUE);
            //     #endif
            //     return posCS;
            // }
            //
            // struct Attributes
            // {
            //     float4 positionOS : POSITION;
            //     float3 normalOS   : NORMAL;
            //     float2 uv         : TEXCOORD0;
            //     UNITY_VERTEX_INPUT_INSTANCE_ID
            // };
            //
            // struct Varyings
            // {
            //     float4 positionCS : SV_POSITION;
            //     float2 uv         : TEXCOORD0;
            //     UNITY_VERTEX_INPUT_INSTANCE_ID
            // };
            //
            // Varyings ShadowVert(Attributes input)
            // {
            //     Varyings output;
            //     UNITY_SETUP_INSTANCE_ID(input);
            //     UNITY_TRANSFER_INSTANCE_ID(input, output);
            //     
            //     VertexPositionInputs vpos = GetVertexPositionInputs(input.positionOS.xyz);
            //     half3 normalWS = TransformObjectToWorldNormal(input.normalOS);
            //
            //     output.positionCS = GetShadowPositionHClip(vpos, normalWS);
            //     output.uv = input.uv * _NoiseTillingOffset.xy + _NoiseTillingOffset.zw;
            //     return output;
            // }
            //
            // half4 ShadowFrag(Varyings input) : SV_TARGET
            // {
            //     UNITY_SETUP_INSTANCE_ID(input);
            //     
            //     #if defined(_NO_SHADOWCAST)
            //         clip(-1);        // 永远丢弃 → 不写入阴影贴图
            //         return 0;
            //     #endif
            //     // #if defined(_ALPHATEST_ON)
            //         // 阴影部分的消融应当与 Forward Pass 保持一致
            //         // half a = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, IN.uv).r;
            //         // clip(a - _Cutoff);
            //     // #endif
            //     return 0;
            // }
            ENDHLSL
        }

        // DepthOnly 有 AlphaClip 的情况需要记录一下来源于纹理的深度
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ColorMask R
            Cull Back

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            // #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #if defined(LOD_FADE_CROSSFADE)
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

            struct Attributes
            {
                float4 position     : POSITION;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                #if defined(_ALPHATEST_ON)
                    float2 uv       : TEXCOORD0;
                #endif
                float4 positionCS   : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                #if defined(_ALPHATEST_ON)
                    output.uv = input.texcoord * _TillingOffset.xy + _TillingOffset.zw;
                #endif
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                return output;
            }

            half DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                #if defined(_ALPHATEST_ON)  // 不用Unity自带的函数了，容易出问题
                    // Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
                    half a = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).a;
                    a *= _BaseColor.a;      // 与 BaseColor 的 alpha 相乘
                    clip(a - _Cutoff);      // 等价于 Alpha(...) 的裁剪
                #endif

                #if defined(LOD_FADE_CROSSFADE)
                    LODFadeCrossFade(input.positionCS);
                #endif

                return input.positionCS.z;
            }
            ENDHLSL
        }

        // Meta：只为光照烘焙提供 Albedo / Emission，保持与 Forward 的采样与 AlphaClip一致
        Pass
        {
            Name "Meta"
            Tags { "LightMode" = "Meta" }
            Cull Back

            HLSLPROGRAM
            #pragma vertex   UniversalVertexMeta
            #pragma fragment UniversalFragmentMeta

            // 与 Forward 保持一致的 AlphaClip 宏
            // #pragma shader_feature_local_fragment _ALPHATEST_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv0        : TEXCOORD0;
                float2 uv1        : TEXCOORD1;
                float2 uv2        : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                #ifdef EDITOR_VISUALIZATION
                float2 VizUV      : TEXCOORD1;
                float4 LightCoord : TEXCOORD2;
                #endif
            };

            Varyings UniversalVertexMeta(Attributes IN)
            {
                Varyings o = (Varyings)0;
                // 让烘焙器使用正确的光照贴图/图集坐标系
                o.positionCS = UnityMetaVertexPosition(IN.positionOS.xyz, IN.uv1, IN.uv2);

                // 与 Forward 一致的主纹理 UV（你项目里用 _TillingOffset）
                // 若要用贴图自带的 ST，换成：TRANSFORM_TEX(IN.uv0, _BaseMap);
                o.uv = IN.uv0 * _TillingOffset.xy + _TillingOffset.zw;

                #ifdef EDITOR_VISUALIZATION
                UnityEditorVizData(IN.positionOS.xyz, IN.uv0, IN.uv1, IN.uv2, o.VizUV, o.LightCoord);
                #endif
                return o;
            }

            // —— 片元：手动输出 Albedo / Emission 到两个目标 —— //
            struct MetaOut
            {
                half4 albedo   : SV_Target0; // RGB = Albedo (linear),   A=1
                half4 emission : SV_Target1; // RGB = Emission (linear), A=1
            };

            MetaOut UniversalFragmentMeta(Varyings IN)
            {
                MetaOut OUT;

                const half2 uv = IN.uv;

                // 采样与 Forward 一致
                half4 baseRGBA = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half3 albedo   = baseRGBA.rgb * _BaseColor.rgb;

                // #if defined(_ALPHATEST_ON)
                // clip(baseRGBA.a - _Cutoff);
                // #endif

                half3 emission = half3(0,0,0); // 这里不考虑自发光贴图

                // 写出到 RT0/RT1
                OUT.albedo   = half4(albedo,   1.0);
                OUT.emission = half4(emission, 1.0);

                #ifdef EDITOR_VISUALIZATION
                // 让编辑器的可视化正常工作（可选，简单做法：把可视化信息编码到 RT0 的 A 中）
                // 如果你想更严格地复刻可视化，可在这里根据 VizUV/LightCoord 自行编码。
                #endif

                return OUT;
            }
            ENDHLSL
        }
        
    }

    Fallback Off
    CustomEditor "URPLitExtGUI"
}
