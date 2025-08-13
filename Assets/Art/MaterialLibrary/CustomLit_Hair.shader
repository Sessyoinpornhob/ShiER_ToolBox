
// --------------------------------
// ShiER s Metallic workflow 
// - 标准的 PBR 材质，使用 Albedo Normal Metallic Glossiness(1 - Roughness) AO 在 SP 中导出Glossiness，但实际上当成 smoothness 在用。
// - - 基于 AO-Glossiness-Metallic 的纹理设置
// - 支持主光源的光照，支持多光源
// - 支持不同种类的 BRDF，【Cook-Torrance】【Kajiya-Kay】【GGX 各向异性】
// - 以 AlphaClip 为核心的消融等特效
// - 叠加菲涅尔效果
// --------------------------------

Shader "ALab/CustomLit_Hair"
{
    Properties
    {
        // 颜色调整
        [Header(ColorAdjust)][Space(10)]
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        
        // UV
        [Header(UV)][Space(10)]
        _TillingOffset("TillingOffset", Vector) = (1,1,0,0)
        
        // PBR 纹理
        [Header(PBR_Map)][Space(10)]
        [SingleLineTexture] [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [SingleLineTexture] _ARMMaskMap("ARMMaskMap", 2D) = "white" {}
        [SingleLineTexture] _EmissionMap("EmissionMap", 2D) = "white" {}
        [SingleLineTexture] _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Range(0.0, 2.0)) = 1.0
        
        // PBR 参数
        [Header(PBR_Data)][Space(10)]
        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        _SmoothnessMin("SmoothnessMin", Range(0.0, 1.0)) = 0.5
        _SmoothnessMax("SmoothnessMax", Range(0.0, 1.0)) = 0.5
        _SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
        _OcclusionStrength("AO_Strength", Range(0.0, 1.0)) = 1.0
        _MetallicMin("MetallicMin", Range(0.0, 1.0)) = 1.0
        _MetallicMax("MetallicMax", Range(0.0, 1.0)) = 1.0
        [HDR] _EmissionColor("EmissionColor", Color) = (0,0,0)
        
        // 毛发高光相关
        [Header(Hair Specular Ring)][Space(10)]
        [SingleLineTexture] _SpecularShiftTexture ("Specular Shift Texture", 2D) = "white" {}
        _HairSpecularTillingOffset                ("HairSpecularTillingOffset", Vector) = (1,1,0,0)
        _Exponent               ("Exponent", Range(0, 400)) = 1
        _ShiftOffset_01         ("ShiftOffset_01", Range(-1, 1)) = 0
        _ShiftOffset_02         ("ShiftOffset_02", Range(-1, 1)) = 0
        _SpecularWidth          ("SpecularWidth", Range(0, 1)) = 0
        
        // 溶解效果
		[Header(Dissolve)][Space(10)]
        [NoScaleOffset][SingleLineTexture]_NoiseMap("NoiseMap", 2D) = "white" {}
        _NoiseTillingOffset("NoiseTillingOffset", Vector) = (1,1,1,1)
		_Dissolve("Dissolve", Range( -0.1 , 1.1)) = 0.5427703
		_EdgeColor("EdgeColor", Color) = (0,0,0)
		_EdgeWidth("EdgeWidth", Range( 0 , 0.1)) = 0
        
        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _Cull("__cull", Float) = 2.0
        [HideInInspector] _AlphaClip("_AlphaClip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 1.0
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0
        [HideInInspector] _AddPrecomputedVelocity("_AddPrecomputedVelocity", Float) = 0.0

        [ToggleUI] [Space(10)] _ReceiveShadows("Receive Shadows", Float) = 1.0
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
        LOD 300

        // ------------------------------------------------------------------
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
            Blend[_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            ZWrite On// [_ZWrite]
            ZTest LEqual
            Cull Off// [_Cull]
            AlphaToMask On// [_AlphaToMask]

            HLSLPROGRAM
            #pragma target 4.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            // #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON _ALPHAMODULATE_ON
            // #pragma shader_feature_local_fragment _EMISSION
            // #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            // #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            // #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ _FORWARD_PLUS
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            // #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            // LitInput 相关 拉到本地来
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/LitForwardPass.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiERFunctions.hlsl"
            //--------------------------------------
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            //------------ SurfaceInput.hlsl ----------------
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
            #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_Lighting.hlsl"
            #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_BRDF.hlsl"
            

            // NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
            CBUFFER_START(UnityPerMaterial)
                // PBR Data
                float4 _BaseMap_ST;
                float4 _BaseMap_TexelSize;
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
                // half _Surface;

                // Hair Specular Ring
                half4 _HairSpecularTillingOffset;
                float _Exponent;
                float _Scale;
                half _ShiftOffset_01;
                half _ShiftOffset_02;
                half _SpecularWidth;

                // FX Dissolve
                half4 _NoiseTillingOffset;
                half _Dissolve;
                half4 _EdgeColor;
                half _EdgeWidth;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
            CBUFFER_END

            TEXTURE2D(_ParallaxMap);        SAMPLER(sampler_ParallaxMap);
            TEXTURE2D(_OcclusionMap);       SAMPLER(sampler_OcclusionMap);
            TEXTURE2D(_MetallicGlossMap);   SAMPLER(sampler_MetallicGlossMap);
            TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);
            TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_BumpMap);            SAMPLER(sampler_BumpMap);
            TEXTURE2D(_EmissionMap);        SAMPLER(sampler_EmissionMap);
            TEXTURE2D(_ARMMaskMap);         SAMPLER(sampler_ARMMaskMap);
            TEXTURE2D(_SpecularShiftTexture);       SAMPLER(sampler_SpecularShiftTexture);
            TEXTURE2D(_NoiseMap);           SAMPLER(sampler_NoiseMap);
            
            ///////////////////////////////////////////////////////////////////////////////
            //                      Material Property Helpers                            //
            ///////////////////////////////////////////////////////////////////////////////
            
            #if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)))
            #define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
            #endif

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
                float3 bitangentWS              : TEXCOORD9;
                float4 positionCS               : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            inline void InitializeKajiyaKay_HairData(float2 uv, Varyings input, out KajiyaKay_HairData outkkHairData)
            {
                outkkHairData.t = input.bitangentWS;
                
                outkkHairData.normalWS = input.normalWS;
                
                float3 lightDirWS = GetMainLight().direction;
                outkkHairData.lightDirWS = lightDirWS;
                
                float3 V = GetWorldSpaceNormalizeViewDir(input.positionWS);
                outkkHairData.viewDirWS = V;

                half shiftTexVal = SAMPLE_TEXTURE2D(_SpecularShiftTexture, sampler_SpecularShiftTexture, uv) - 0.5;
                outkkHairData.shiftTexVal = shiftTexVal;

                outkkHairData.ShiftOffset_01 = _ShiftOffset_01;
                outkkHairData.ShiftOffset_02 = _ShiftOffset_02;
                outkkHairData.SpecularWidth = _SpecularWidth;
                outkkHairData.SpecularColor = _SpecColor;
                outkkHairData.exponent = _Exponent;
            }
            
            inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
            {
                float4 albedoAlpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                float alpha = albedoAlpha.a;
                // clip(alpha - _Cutoff);
                outSurfaceData.alpha = saturate(alpha);// AlphaDiscard(albedoAlpha.a, _Cutoff);
                outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
                outSurfaceData.albedo = AlphaModulate(outSurfaceData.albedo, outSurfaceData.alpha);
                
                half4 ARMMaskColor = half4(SAMPLE_TEXTURE2D(_ARMMaskMap, sampler_ARMMaskMap, uv));
                
                // Metallic workflow
                outSurfaceData.metallic = ARMMaskColor.b;
                // 可以自定义高光颜色
                outSurfaceData.specular = _SpecColor;   // half3(0.0, 0.0, 0.0);

                outSurfaceData.smoothness = lerp(_SmoothnessMin, _SmoothnessMax, ARMMaskColor.g);
                outSurfaceData.normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv), _BumpScale);
                outSurfaceData.occlusion = LerpWhiteTo(ARMMaskColor.r, _OcclusionStrength);
                outSurfaceData.emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;
                outSurfaceData.clearCoatMask       = half(0.0);
                outSurfaceData.clearCoatSmoothness = half(0.0);
            }
            
            void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                
                inputData.positionWS = input.positionWS;

                half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);

                // NormalMap
                float sgn = input.tangentWS.w;      // should be either +1 or -1
                float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
                inputData.tangentToWorld = tangentToWorld;
                inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                
                inputData.viewDirectionWS = viewDirWS;
                
                // inputData.shadowCoord = input.shadowCoord;
                inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);

                // 多光源
                inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
                inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
            }

            void InitializeBakedGIData(Varyings input, inout InputData inputData)
            {
                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
                inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
            }

            // 溶解特效计算函数 inout 输入输出都是此参数
            void InitialFXData(Varyings input, inout SurfaceData outSurfaceData)
            {
                float2 FX_Dissolve_UV_xy = float2(_NoiseTillingOffset.x , _NoiseTillingOffset.y);
				float2 FX_Dissolve_UV_zw = float2(_TimeParameters.x * _NoiseTillingOffset.z , _TimeParameters.x * _NoiseTillingOffset.w);
				float2 FX_Dissolve_UV = input.uv.xy * FX_Dissolve_UV_xy + FX_Dissolve_UV_zw;
				float4 NoiseMapValue = SAMPLE_TEXTURE2D( _NoiseMap, sampler_NoiseMap, FX_Dissolve_UV);
                // FX emission
                half3 emission = ( step( ( NoiseMapValue.rgb - _EdgeWidth ) , _Dissolve ) * _EdgeColor );
                outSurfaceData.emission = emission;
                // FX alpha
                half AlphaValue145 = outSurfaceData.alpha * step( _Dissolve , NoiseMapValue.r );
                clip(AlphaValue145 - _Cutoff);
                outSurfaceData.alpha = AlphaValue145;
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

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.uv = input.texcoord * _TillingOffset.xy + _TillingOffset.zw;

                // already normalized from normal transform to WS.
                output.normalWS = normalInput.normalWS;
                // REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
                real sign = input.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
                // REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
                output.tangentWS = tangentWS;
                output.bitangentWS = normalInput.bitangentWS;

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                OUTPUT_SH4(vertexInput.positionWS, output.normalWS.xyz, GetWorldSpaceNormalizeViewDir(vertexInput.positionWS), output.vertexSH, output.probeOcclusion);

                // 多光源
                half fogFactor = 0;
                half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                
                output.positionWS = vertexInput.positionWS;
                // REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
                output.shadowCoord = GetShadowCoord(vertexInput);
                output.positionCS = vertexInput.positionCS;
                float3 ViewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
                output.ViewDirWS = ViewDirWS;

                return output;
            }

            // Used in Standard (Physically Based) shader
            void LitPassFragment( Varyings input, out half4 outColor : SV_Target0 )
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // 表面PBR信息
                SurfaceData surfaceData;
                InitializeStandardLitSurfaceData(input.uv, surfaceData);
                
                // 基础信息
                InputData inputData;
                InitializeInputData(input, surfaceData.normalTS, inputData);

                // 头发类高光信息
                KajiyaKay_HairData hair_data;
                float2 hairSpecularUV = input.uv.xy * _HairSpecularTillingOffset.xy + _HairSpecularTillingOffset.zw;
                InitializeKajiyaKay_HairData(hairSpecularUV, input, hair_data);

                // 环境光照相关
                InitializeBakedGIData(input, inputData);

                // 特效计算函数
                InitialFXData(input, surfaceData);

                half4 color = UniversalFragmentPBR_ShiER_Hair(inputData, surfaceData, hair_data);
                color.rgb = MixFog(color.rgb, inputData.fogCoord);
                // color.a = OutputAlpha(color.a, IsSurfaceTypeTransparent(_Surface));
                color.a = 1.0f;

                outColor = color;
                
            }

            
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Universal Pipeline keywords

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite[_ZWrite]
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitGBufferPassVertex
            #pragma fragment LitGBufferPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            //#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitGBufferPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            // LitInput 相关 拉到本地来
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/LitForwardPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiERFunctions.hlsl"
            ENDHLSL
        }

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
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 4.5

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            // -------------------------------------
            // Universal Pipeline keywords
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }
        
        
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "UnityEditor.ShaderGraphLitGUI"
}
