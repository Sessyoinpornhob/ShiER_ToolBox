// 可用
Shader "ALab/SD_UDIM_ASE_CODE"
{
	Properties
	{
		// ------------------------- Vertex_RBD -----------------------------
		[Header(Vertex_RBD)] [Space(10)]
		[ToggleUI]_B_autoPlayback("Auto Playback", Float) = 1
		_displayFrame("Display Frame", Range(1, 120)) = 1
		_playbackSpeed("Playback Speed", Float) = 1
		[NoScaleOffset]_posTexture("Position Texture", 2D) = "white" {}
        [NoScaleOffset]_rotTexture("Rotation Texture", 2D) = "white" {}
	    _frameCount("Frame Count", Float) = 0
        _boundMaxX("Bound Max X", Float) = 0
        _boundMaxY("Bound Max Y", Float) = 0
        _boundMaxZ("Bound Max Z", Float) = 0
        _boundMinX("Bound Min X", Float) = 0
        _boundMinY("Bound Min Y", Float) = 0
        _boundMinZ("Bound Min Z", Float) = 0
        _Tiling("Tiling", Vector) = (0, 0, 0, 0)
        _Offset("Offset", Vector) = (0, 0, 0, 0)
        [NoScaleOffset]_BaseColor_Tex("BaseColor_Tex", 2D) = "white" {}
        [NoScaleOffset]_ARM_Tex("ARM_Tex", 2D) = "white" {}
        [NoScaleOffset]_Normal_Tex("Normal_Tex", 2D) = "white" {}
        _NormalLerp("NormalLerp", Range(0, 1)) = 0
		
		// ------------------------- UDIM_PBR ------------------------------
		[Header(UDIM_PBR)] [Space(10)]
		_BaseMapArray("BaseMapArray", 2DArray) = "white" {}
		_MetallicArray("Metallic Array", 2DArray) = "white" {}
		_NormalArray("Normal Array", 2DArray) = "bump" {}
		_SM_Min("SM_Min", Range( 0 , 1)) = 0
		_SM_Max("SM_Max", Range( 0 , 1)) = 0
		_Meta_Min("Meta_Min", Range( 0 , 1)) = 0
		_Meta_Max("Meta_Max", Range( 0 , 1)) = 0
		[Toggle]_UseAO("UseAO", Float) = 0
		_AO_Min("AO_Min", Range( 0 , 1)) = 0
		_AO_Max("AO_Max", Range( 0 , 1)) = 0
		
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector][ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1
		[HideInInspector][ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0
		
		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1
		
        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0
		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Lit" }

		Cull Back
		ZWrite On
		ZTest LEqual
		Offset 0,0
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 4.0
		#pragma prefer_hlslcc gles
		#pragma only_renderers metal // ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			
			HLSLPROGRAM

			#pragma multi_compile_fragment _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#define _NORMALMAP 1
			#define ASE_VERSION 19801
			#define ASE_SRP_VERSION 170003


			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _FORWARD_PLUS

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile _ USE_LEGACY_LIGHTMAPS

			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

			#define SHADERPASS SHADERPASS_FORWARD

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				float4 normalWS : TEXCOORD2;
				float4 tangentWS : TEXCOORD3;
				float4 bitangentWS : TEXCOORD4;
				float4 shadowCoord : TEXCOORD5;
				float2 dynamicLightmapUV : TEXCOORD6;
				float4 probeOcclusion : TEXCOORD7;
				float4 uv0 : TEXCOORD8;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseMapArray_ST;
			float4 _NormalArray_ST;
			float4 _MetallicArray_ST;
			float _Meta_Min;
			float _Meta_Max;
			float _SM_Min;
			float _SM_Max;
			float _UseAO;
			float _AO_Min;
			float _AO_Max;
			CBUFFER_END
			
			TEXTURE2D_ARRAY(_BaseMapArray);
			SAMPLER(sampler_BaseMapArray);
			TEXTURE2D_ARRAY(_NormalArray);
			SAMPLER(sampler_NormalArray);
			TEXTURE2D_ARRAY(_MetallicArray);
			SAMPLER(sampler_MetallicArray);


			float3 MyCustomExpression120( float3 NormalTexColor )
			{
				return NormalTexColor * float3(2,2,1) - float3(1,1,0);
			}

			// -------------------------- vert ----------------------------------
			PackedVaryings vert ( Attributes input )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				output.uv0.xy = input.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.uv0.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif
				// input.normalOS = input.normalOS;
				// input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				output.normalWS = float4( normalInput.normalWS, vertexInput.positionWS.x );
				output.tangentWS = float4( normalInput.tangentWS, vertexInput.positionWS.y );
				output.bitangentWS = float4( normalInput.bitangentWS, vertexInput.positionWS.z );

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(input.texcoord1, unity_LightmapST, output.lightmapUVOrVertexSH.xy);
				#else
					OUTPUT_SH(normalInput.normalWS.xyz, output.lightmapUVOrVertexSH.xyz);
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV.xy = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				OUTPUT_SH4( vertexInput.positionWS, normalInput.normalWS.xyz, GetWorldSpaceNormalizeViewDir( vertexInput.positionWS ), output.lightmapUVOrVertexSH.xyz, output.probeOcclusion );

				output.positionCS = vertexInput.positionCS;
				output.clipPosV = vertexInput.positionCS;
				return output;
			}

			// -------------------------- frag ----------------------------------
			half4 frag ( PackedVaryings input ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
				
				float3 WorldNormal = normalize( input.normalWS.xyz );
				float3 WorldTangent = input.tangentWS.xyz;
				float3 WorldBiTangent = input.bitangentWS.xyz;

				float3 WorldPosition = float3(input.normalWS.w,input.tangentWS.w,input.bitangentWS.w);
				float3 WorldViewDirection = GetWorldSpaceNormalizeViewDir( WorldPosition );
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = input.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				// ----- 计算相关 -----
				float2 uv_Array = input.uv0.xy;
				float2 texCoord15 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_17_0 = floor( texCoord15.x );
				float3 lerpResult31 = lerp(
					SAMPLE_TEXTURE2D_ARRAY( _BaseMapArray, sampler_BaseMapArray, uv_Array,0.0 ).rgb ,
					SAMPLE_TEXTURE2D_ARRAY( _BaseMapArray, sampler_BaseMapArray, uv_Array,1.0 ).rgb ,
					step( 1.0 , temp_output_17_0 ));
				float3 lerpResult32 = lerp( lerpResult31 , SAMPLE_TEXTURE2D_ARRAY( _BaseMapArray, sampler_BaseMapArray, uv_Array,2.0 ).rgb , step( 2.0 , temp_output_17_0 ));
				float3 lerpResult33 = lerp( lerpResult32 , SAMPLE_TEXTURE2D_ARRAY( _BaseMapArray, sampler_BaseMapArray, uv_Array,3.0 ).rgb , step( 3.0 , temp_output_17_0 ));
				float3 lerpResult34 = lerp( lerpResult33 , SAMPLE_TEXTURE2D_ARRAY( _BaseMapArray, sampler_BaseMapArray, uv_Array,4.0 ).rgb , step( 4.0 , temp_output_17_0 ));
				float3 lerpResult35 = lerp( lerpResult34 , SAMPLE_TEXTURE2D_ARRAY( _BaseMapArray, sampler_BaseMapArray, uv_Array,5.0 ).rgb , step( 5.0 , temp_output_17_0 ));
				float3 BaseColor73 = lerpResult35;
				
				// float2 uv_Array = input.uv0.xy;
				float2 texCoord96 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float3 NormalTexColor120 = SAMPLE_TEXTURE2D_ARRAY( _NormalArray, sampler_NormalArray, uv_Array,0.0 ).rgb;
				float3 localMyCustomExpression120 = MyCustomExpression120( NormalTexColor120 );
				float3 NormalTexColor124 = SAMPLE_TEXTURE2D_ARRAY( _NormalArray, sampler_NormalArray, uv_Array,1.0 ).rgb;
				float3 localMyCustomExpression124 = MyCustomExpression120( NormalTexColor124 );
				float temp_output_99_0 = floor( texCoord96.x );
				float3 lerpResult103 = lerp( localMyCustomExpression120 , localMyCustomExpression124 , step( 1.0 , temp_output_99_0 ));
				float3 NormalTexColor125 = SAMPLE_TEXTURE2D_ARRAY( _NormalArray, sampler_NormalArray, uv_Array,2.0 ).rgb;
				float3 localMyCustomExpression125 = MyCustomExpression120( NormalTexColor125 );
				float3 lerpResult108 = lerp( lerpResult103 , localMyCustomExpression125 , step( 2.0 , temp_output_99_0 ));
				float3 NormalTexColor126 = SAMPLE_TEXTURE2D_ARRAY( _NormalArray, sampler_NormalArray, uv_Array,3.0 ).rgb;
				float3 localMyCustomExpression126 = MyCustomExpression120( NormalTexColor126 );
				float3 lerpResult109 = lerp( lerpResult108 , localMyCustomExpression126 , step( 3.0 , temp_output_99_0 ));
				float3 NormalTexColor127 = SAMPLE_TEXTURE2D_ARRAY( _NormalArray, sampler_NormalArray, uv_Array,4.0 ).rgb;
				float3 localMyCustomExpression127 = MyCustomExpression120( NormalTexColor127 );
				float3 lerpResult112 = lerp( lerpResult109 , localMyCustomExpression127 , step( 4.0 , temp_output_99_0 ));
				float3 NormalTexColor128 = SAMPLE_TEXTURE2D_ARRAY( _NormalArray, sampler_NormalArray, uv_Array,5.0 ).rgb;
				float3 localMyCustomExpression128 = MyCustomExpression120( NormalTexColor128 );
				float3 lerpResult115 = lerp( lerpResult112 , localMyCustomExpression128 , step( 5.0 , temp_output_99_0 ));
				float3 NormalColor121 = lerpResult115;
				
				// float2 uv_Array = input.uv0.xy;
				float2 texCoord44 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_46_0 = floor( texCoord44.x );
				float4 lerpResult48 = lerp( SAMPLE_TEXTURE2D_ARRAY( _MetallicArray, sampler_MetallicArray, uv_Array,0.0 ) , SAMPLE_TEXTURE2D_ARRAY( _MetallicArray, sampler_MetallicArray, uv_Array,1.0 ) , step( 1.0 , temp_output_46_0 ));
				float4 lerpResult50 = lerp( lerpResult48 , SAMPLE_TEXTURE2D_ARRAY( _MetallicArray, sampler_MetallicArray, uv_Array,2.0 ) , step( 2.0 , temp_output_46_0 ));
				float4 lerpResult52 = lerp( lerpResult50 , SAMPLE_TEXTURE2D_ARRAY( _MetallicArray, sampler_MetallicArray, uv_Array,3.0 ) , step( 3.0 , temp_output_46_0 ));
				float4 lerpResult54 = lerp( lerpResult52 , SAMPLE_TEXTURE2D_ARRAY( _MetallicArray, sampler_MetallicArray, uv_Array,4.0 ) , step( 4.0 , temp_output_46_0 ));
				float4 lerpResult56 = lerp( lerpResult54 , SAMPLE_TEXTURE2D_ARRAY( _MetallicArray, sampler_MetallicArray, uv_Array,5.0 ) , step( 5.0 , temp_output_46_0 ));
				float4 MaskColor68 = lerpResult56;
				float4 break88 = MaskColor68;
				
				float lerpResult89 = lerp( _Meta_Min , _Meta_Max , break88.r);
				float lerpResult84 = lerp( _SM_Min , _SM_Max , break88.a);
				float lerpResult93 = lerp( _AO_Min , _AO_Max , break88.g);
				

				float3 BaseColor = BaseColor73;
				float3 Normal = NormalColor121;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = lerpResult89;
				float Smoothness = lerpResult84;
				float Occlusion = (( _UseAO )?( lerpResult93 ):( 1.0 ));
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.positionCS = input.positionCS;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					inputData.shadowCoord = ShadowCoords;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				#else
					inputData.shadowCoord = float4(0, 0, 0, 0);
				#endif


				float3 SH = input.lightmapUVOrVertexSH.xyz;
				inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
				inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;
				
				SurfaceData surfaceData;
				surfaceData.albedo              = BaseColor;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;
				
				
				half4 color = UniversalFragmentPBR( inputData, surfaceData);

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#pragma multi_compile _ALPHATEST_ON
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#define _NORMALMAP 1
			#define ASE_VERSION 19801
			#define ASE_SRP_VERSION 170003


			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#pragma vertex vert
			#pragma fragment frag

			#if defined(_SPECULAR_SETUP) && defined(_ASE_LIGHTING_SIMPLE)
				#define _SPECULAR_COLOR 1
			#endif

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseMapArray_ST;
				float4 _NormalArray_ST;
				float4 _MetallicArray_ST;
				float _Meta_Min;
				float _Meta_Max;
				float _SM_Min;
				float _SM_Max;
				float _UseAO;
				float _AO_Min;
				float _AO_Max;
			CBUFFER_END
			
			float3 _LightDirection;
			float3 _LightPosition;

			PackedVaryings VertexFunction( Attributes input )
			{
				PackedVaryings output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );
				float3 normalWS = TransformObjectToWorldDir(input.normalOS);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				//code for UNITY_REVERSED_Z is moved into Shadows.hlsl from 6000.0.22 and or higher
				positionCS = ApplyShadowClamping(positionCS);

				output.positionCS = positionCS;
				output.clipPosV = positionCS;
				output.positionWS = positionWS;
				return output;
			}


			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}


			half4 frag(	PackedVaryings input
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				float3 WorldPosition = input.positionWS;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = input.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

	
	}
	
	CustomEditor "UnityEditor.ShaderGraphLitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
