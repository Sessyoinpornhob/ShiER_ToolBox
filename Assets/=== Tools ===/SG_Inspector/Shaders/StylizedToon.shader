// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Stylized Toon"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_PositionY("PositionY", Range( 0.5 , 8)) = 0.5
		[Toggle(_USERIMLIGHT_ON)] _UseRimLight("UseRim Light", Float) = 0
		[Toggle(_USEHEIGHTMASK_ON)] _UseHeightMask("UseHeight Mask", Float) = 0
		[Toggle(_USESPECULAR_ON)] _UseSpecular("UseSpecular Highlights", Float) = 1
		_SpecColor("Specular Value", Color) = (1,1,1,1)
		_Color("Color", Color) = (0.6792453,0.6792453,0.6792453,1)
		_SpecularFaloff("Specular Falloff", Range( 0 , 1)) = 0
		_LightRampOffset("Light Ramp Offset", Range( -1 , 1)) = 0
		_MainTex1("Albedo Texture1", 2D) = "white" {}
		_MainTex("Albedo Texture", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_LightRampTexture("Light Ramp Texture", 2D) = "white" {}
		_SideShineHardness("Side Shine Hardness", Range( 0 , 0.5)) = 0
		_BacklightHardness("Backlight Hardness", Range( 0 , 0.5)) = 0
		_StepOffset("Step Offset", Range( -0.5 , 0.5)) = 0
		[KeywordEnum(Step,DiffuseRamp,Posterize)] _UseLightRamp("Shading Mode", Float) = 0
		[HideInInspector]_RampDiffuseTextureLoaded("RampDiffuseTextureLoaded", Float) = 1
		[NoScaleOffset][SingleLineTexture]_DiffuseWarpNoise("Diffuse Warp Noise", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_SpecularMaskTexture("Specular Mask Texture", 2D) = "white" {}
		_SpecularMaskStrength("Specular Mask Strength", Range( 0 , 1)) = 0.1856417
		_WarpStrength("Warp Strength", Range( -1 , 1)) = 0
		_SpecularMaskScale("Specular Mask Tiling", Float) = 1
		_WarpTextureScale("UV Tiling", Float) = 1
		[Toggle]_UseDiffuseWarp("UseDiffuse Warp", Float) = 0
		[Toggle]_UseSpecularMask("UseSpecular Mask", Float) = 0
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimThickness("Rim Thickness", Range( 0 , 3)) = 1
		_RimPower("Rim Power", Range( 1 , 12)) = 2
		_RimSmoothness("Rim Smoothness", Range( 0 , 0.5)) = 0
		[Normal]_BumpMap1("Normal Map1", 2D) = "bump" {}
		[Normal]_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalMapStrength("Normal Map Strength", Float) = 1
		_SpecularPosterizeSteps("Specular Posterize Steps", Range( 0 , 15)) = 0
		[Toggle(_USEENVIRONMENTREFLETION_ON)] _UseEnvironmentRefletion("UseEnvironment Reflections", Float) = 0
		_Strength("Strength", Range( 0 , 1)) = 0
		[NoScaleOffset][SingleLineTexture]_SpecGlossMap1("Specular Map1", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_SpecGlossMap("Specular Map", 2D) = "white" {}
		_Glossiness("Smoothness", Range( 0 , 1)) = 0.5
		_Cutoff("Alpha Clip Threshold", Range( 0 , 1)) = 0
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		[HDR][NoScaleOffset][SingleLineTexture]_EmissionMap("Emission Map", 2D) = "white" {}
		[HDR][NoScaleOffset][SingleLineTexture]_EmissionMap1("Emission Map1", 2D) = "white" {}
		_UseEmission("UseEmission", Float) = 0
		_IndirectLightStrength("Indirect Light Strength", Range( 0 , 1)) = 1
		_SpecularShadowMask("Specular Shadow Mask", Range( 0 , 1)) = 0
		_WarpTextureRotation("UV Rotation", Range( 0 , 180)) = 0
		_SpecularMaskRotation("Specular Mask Rotation", Range( 0 , 180)) = 0
		_BacklightAmount("Backlight Amount", Range( 0 , 1)) = 0.5
		[Toggle]_UseShadows("Use Shadows", Float) = 1
		_BacklightIntensity("Backlight Intensity", Range( 0 , 4)) = 1
		[Toggle(_USEBACKLIGHT_ON)] _UseBacklight("Rim As Backlight & Side Shine", Float) = 0
		_SideShineIntensity("Side Shine Intensity", Range( 0 , 4)) = 1
		_SideShineAmount("Side Shine Amount", Range( 0 , 0.7)) = 0.2717647
		[NoScaleOffset][SingleLineTexture]_HalftoneTexture("Halftone Texture", 2D) = "white" {}
		_HalftoneSmoothness("Halftone Smoothness", Range( 0 , 2)) = 0.3
		_HalftoneEdgeOffset("Halftone Edge Offset", Range( -1 , 1)) = 0.1
		_HalftoneThreshold("Halftone Threshold", Range( 0 , 0.15)) = 0.1
		_HalftoneColor("Halftone Color", Color) = (0,0,0,1)
		[NoScaleOffset]_Hatch2("Hatch Texture Brighter", 2D) = "white" {}
		[NoScaleOffset]_Hatch1("Hatch Texture Darker", 2D) = "white" {}
		_MaxScaleDependingOnCamera("Max Scale Depends On Camera", Range( 1 , 10)) = 1
		[Toggle(_USEHATCHINGCONSTANTSCALE_ON)] _UseHatchingConstantScale("Hatching Constant Scale", Float) = 1
		[KeywordEnum(None,Haftone,Hatching)] _OverlayMode1("Overlay Mode", Float) = 0
		_ShapeSmoothness("Transition Smoothness", Range( 0 , 1)) = 0.2
		_OverlayRotation("UV Rotation", Range( 0 , 180)) = 0
		_OverlayUVTilling("UV Tiling", Float) = 0
		[Toggle(_USESCREENUVS_ON)] _UseScreenUvs("Screen Uvs", Float) = 0
		[Toggle(_USESCREENUVSSPECULAR_ON)] _UseScreenUvsSpecular("Screen Uvs", Float) = 0
		_Darken("Darken", Range( -1 , 1)) = 0
		_Lighten("Lighten", Range( -1 , 1)) = 0
		_AdditionalLightsSmoothnessMultiplier("Additional Lights Specular Size", Range( 0 , 2)) = 1
		_SmoothnessMultiplier("Main Specular Size", Range( 0 , 2)) = 1
		_AdditionalLightsIntesity("Additional Lights Intensity", Range( 0 , 6)) = 1
		[Toggle(_USEADDITIONALLIGHTSDIFFUSE_ON)] _UseAdditionalLightsDiffuse("UseAdditional Lights", Float) = 1
		_AdditionalLightsAmount("Additional Lights Size", Range( 0 , 1)) = 1
		_AdditionalLightsFaloff("Additional Lights Falloff", Range( 0 , 1)) = 1
		_HatchingColor("Hatching Color", Color) = (0,0,0,1)
		[Toggle(_USEPURESKETCH_ON)] _UsePureSketch("Pure Sketch", Float) = 1
		[KeywordEnum(None,Haftone,Hatching)] _OverlayMode("Overlay Mode", Float) = 0
		_UVAnimationSpeedWarp("UV Animation Speed", Range( 0 , 5)) = 0
		_UVAnimationSpeedSpec("UV Animation Speed", Range( 0 , 5)) = 0
		_UVAnimationSpeed("UV Animation Speed", Range( 0 , 5)) = 0
		_UVSrcrollAngleSpec("UV Scroll Angle", Range( 0 , 360)) = 0
		_UVSrcrollAngle("UV Scroll Angle", Range( 0 , 360)) = 0
		_UVSrcrollAngleWarp("UV Scroll Angle", Range( 0 , 360)) = 0
		_UVScrollSpeedWarp("UV Scroll Speed", Range( 0 , 0.1)) = 0
		_UVScrollSpeed("UV Scroll Speed", Range( 0 , 0.1)) = 0
		_UVScrollSpeedSpec("UV Scroll Speed", Range( 0 , 0.1)) = 0
		_DiffusePosterizeSteps("Posterize Steps", Range( 1 , 10)) = 3
		_DiffusePosterizePower("Posterize Power", Range( 0.5 , 3)) = 1
		_DiffusePosterizeOffset("Posterize Offset", Range( -0.5 , 0.5)) = 0
		_MainLightIntesity("Main Light Intensity", Range( 0 , 6)) = 1
		_ShadowColor("Shadow Color", Color) = (0,0,0,0)
		_HalftoneToonAffect("Toon Affect", Range( 0 , 1)) = 0
		_IndirectLightAffectOnHatch("Indirect Light Affect On Hatch", Range( 0 , 1)) = 0
		[Toggle(_USEDIFFUSEWARPASOVERLAY_ON)] _UseDiffuseWarpAsOverlay("Impact Shadows", Float) = 0
		_DiffuseWarpBrightnessOffset("Brightness Offset", Float) = 1.12
		[Toggle(_USESCREENUVSWARP_ON)] _UseScreenUvsWarp("Screen Uvs", Float) = 0
		[Toggle]_StepHalftoneTexture("Step Halftone Texture", Float) = 0
		_HaltonePatternSize("Halftone Pattern Size", Range( 0 , 1)) = 0
		_RimShadowColor("Rim Shadow Color", Color) = (0,0.05551431,0.9622642,0)
		[KeywordEnum(NoSplit,MultiplyWithDiffuse,UseSecondColor)] _RimSplitColor("Rim Split Color", Float) = 0
		_OcclusionMap1("Occlusion Map1", 2D) = "white" {}
		_OcclusionMap("Occlusion Map", 2D) = "white" {}
		_OcclusionStrength("Occlusion Strength ", Range( 0 , 1)) = 1
		[Toggle(_USEADAPTIVESCREENUVS_ON)] _UseAdaptiveScreenUvs("Adaptive Screen Uvs", Float) = 0
		[Toggle(_USEADAPTIVEUVSSPECULAR_ON)] _UseAdaptiveUvsSpecular("Adaptive Screen Uvs", Float) = 0
		[Toggle(_USEADAPTIVESCREENUVSWARP_ON)] _UseAdaptiveScreenUvsWarp("Adaptive Screen Uvs ", Float) = 0
		[Toggle(_INVERSEMASK_ON)] _InverseMask("Inverse Mask", Float) = 0
		_PaperTilling("Paper Tiling", Float) = 1
		[NoScaleOffset]_PaperTexture("Paper Texture", 2D) = "white" {}
		[Toggle(_HEIGHTMASKSWITCH_ON)] _HeightMaskSwitch("HeightMaskSwitch", Float) = 0
		[ASEEnd][Toggle(_USEAORR_ON)] _UseAorR("UseAorR", Float) = 0


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Unlit" }

		Cull Back
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010


			#pragma instancing_options renderinglayer

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        	#pragma multi_compile_fragment _ DEBUG_DISPLAY
        	#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        	#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#pragma shader_feature_local _OVERLAYMODE_NONE _OVERLAYMODE_HAFTONE _OVERLAYMODE_HATCHING
			#pragma shader_feature_local _USELIGHTRAMP_STEP _USELIGHTRAMP_DIFFUSERAMP _USELIGHTRAMP_POSTERIZE
			#pragma shader_feature_local _USEDIFFUSEWARPASOVERLAY_ON
			#pragma shader_feature_local _USESCREENUVSWARP_ON
			#pragma shader_feature_local _USEADAPTIVESCREENUVSWARP_ON
			#pragma shader_feature_local _USEADDITIONALLIGHTSDIFFUSE_ON
			#pragma shader_feature_local _USEHEIGHTMASK_ON
			#pragma shader_feature_local _HEIGHTMASKSWITCH_ON
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma shader_feature_local _USESCREENUVS_ON
			#pragma shader_feature_local _USEADAPTIVESCREENUVS_ON
			#pragma shader_feature_local _USESPECULAR_ON
			#pragma shader_feature_local _INVERSEMASK_ON
			#pragma shader_feature_local _USESCREENUVSSPECULAR_ON
			#pragma shader_feature_local _USEADAPTIVEUVSSPECULAR_ON
			#pragma shader_feature_local _OVERLAYMODE1_NONE _OVERLAYMODE1_HAFTONE _OVERLAYMODE1_HATCHING
			#pragma shader_feature_local _USEENVIRONMENTREFLETION_ON
			#pragma shader_feature_local _RIMSPLITCOLOR_NOSPLIT _RIMSPLITCOLOR_MULTIPLYWITHDIFFUSE _RIMSPLITCOLOR_USESECONDCOLOR
			#pragma shader_feature_local _USERIMLIGHT_ON
			#pragma shader_feature_local _USEBACKLIGHT_ON
			#pragma shader_feature_local _USEPURESKETCH_ON
			#pragma shader_feature_local _USEHATCHINGCONSTANTSCALE_ON
			#pragma shader_feature_local _USEAORR_ON
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _FORWARD_PLUS


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				float4 lightmapUVOrVertexSH : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color;
			float4 _ShadowColor;
			float4 _RimShadowColor;
			float4 _OcclusionMap_ST;
			float4 _HatchingColor;
			float4 _EmissionColor;
			float4 _OcclusionMap1_ST;
			float4 _SpecColor;
			float4 _HalftoneColor;
			float4 _RimColor;
			float _Strength;
			float _SpecularShadowMask;
			float _SpecularMaskStrength;
			float _SpecularMaskRotation;
			float _UVSrcrollAngleSpec;
			float _UVScrollSpeedSpec;
			float _UVAnimationSpeedSpec;
			float _SpecularMaskScale;
			float _StepHalftoneTexture;
			float _UseSpecularMask;
			float _SmoothnessMultiplier;
			float _HaltonePatternSize;
			float _RampDiffuseTextureLoaded;
			float _RimSmoothness;
			float _RimThickness;
			float _RimPower;
			float _BacklightIntensity;
			float _BacklightHardness;
			float _BacklightAmount;
			float _SideShineIntensity;
			float _SideShineHardness;
			float _SideShineAmount;
			float _UseEmission;
			float _IndirectLightAffectOnHatch;
			float _Darken;
			float _Lighten;
			float _MaxScaleDependingOnCamera;
			float _MainLightIntesity;
			float _AdditionalLightsIntesity;
			float _AdditionalLightsSmoothnessMultiplier;
			float _SpecularPosterizeSteps;
			float _DiffusePosterizeSteps;
			float _DiffusePosterizePower;
			float _DiffusePosterizeOffset;
			float _LightRampOffset;
			float _DiffuseWarpBrightnessOffset;
			float _WarpStrength;
			float _PositionY;
			float _WarpTextureRotation;
			float _UVSrcrollAngleWarp;
			float _UVScrollSpeedWarp;
			float _WarpTextureScale;
			float _UseDiffuseWarp;
			float _UseShadows;
			float _StepOffset;
			float _UVAnimationSpeedWarp;
			float _SpecularFaloff;
			float _NormalMapStrength;
			float _AdditionalLightsFaloff;
			float _PaperTilling;
			float _Glossiness;
			float _OverlayRotation;
			float _UVAnimationSpeed;
			float _UVSrcrollAngle;
			float _UVScrollSpeed;
			float _AdditionalLightsAmount;
			float _OverlayUVTilling;
			float _HalftoneEdgeOffset;
			float _HalftoneThreshold;
			float _ShapeSmoothness;
			float _HalftoneToonAffect;
			float _IndirectLightStrength;
			float _OcclusionStrength;
			float _HalftoneSmoothness;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _DiffuseWarpNoise;
			sampler2D _LightRampTexture;
			sampler2D _BumpMap1;
			sampler2D _OcclusionMap1;
			sampler2D _BumpMap;
			sampler2D _OcclusionMap;
			sampler2D _MainTex1;
			sampler2D _MainTex;
			sampler2D _HalftoneTexture;
			sampler2D _SpecGlossMap1;
			sampler2D _SpecGlossMap;
			sampler2D _SpecularMaskTexture;
			sampler2D _EmissionMap1;
			sampler2D _EmissionMap;
			sampler2D _Hatch1;
			sampler2D _Hatch2;
			sampler2D _PaperTexture;


			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			
			float Posterize1331( float In, float Steps )
			{
				return  floor(In / (1 / Steps)) * (1 / Steps);
			}
			
			float3 AdditionalLight( float3 WorldPosition, float3 WorldNormal, float3 LightWrapVector, float SMin, float SMax, float Faloff, float4 shadowmask )
			{
				float3 Color = 0;
				int numLights = GetAdditionalLightsCount();
				for(int i = 0; i<numLights;i++)
				{
					
							#if VERSION_GREATER_EQUAL(10, 1)
							Light light = GetAdditionalLight(i, WorldPosition, shadowmask);
							// see AdditionalLights_float for explanation of this
						#else
							Light light = GetAdditionalLight(i, WorldPosition);
						#endif
					
					float3 DotVector = dot(light.direction,WorldNormal);
					
					half3 AttLightColor = (light.shadowAttenuation * light.distanceAttenuation);
					 float3 colout = max(float3(0.f,0.f,0.f),LightWrapVector + (1-LightWrapVector) * DotVector )*AttLightColor*light.color; 
					float maxColor = max(colout.r,max(colout.g,colout.b));
					float3 outColor = smoothstep(SMin,SMax,maxColor)*light.color;
					 Color += outColor;
					//Color += smoothstep(float3(Faloff,Faloff,Faloff),float3(0.5f,0.5f,0.5f),colout);
				}
				return Color;
			}
			
			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			float3 AdditionalLightsSpecularMy( float3 WorldPosition, float3 WorldNormal, float3 WorldView, float3 SpecColor, float Smoothness, float Steps, float SpecFaloff )
			{
				float3 Color = 0;
				Smoothness = exp2(10 * Smoothness + 1);
				int numLights = GetAdditionalLightsCount();
				for(int i = 0; i<numLights;i++)
				{
					
							#if VERSION_GREATER_EQUAL(10, 1)
							Light light = GetAdditionalLight(i, WorldPosition, half4(1,1,1,1));
							// see AdditionalLights_float for explanation of this
						#else
							Light light = GetAdditionalLight(i, WorldPosition);
						#endif
					
					half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
					Color += LightingSpecular(AttLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), Smoothness);	
				}
				float IN = max(Color.b,max(Color.r,Color.g));
				float minOut = 0.5 * SpecFaloff - 0.005;
				float faloff = lerp(IN, smoothstep(minOut, 0.5, IN), SpecFaloff);
				if(Steps < 1)
				{
				    return Color *faloff;
				}
				else
				{
				    return  Color *floor(faloff / (1 / Steps)) * (1 / Steps);
				}
			}
			
			float FaloffPosterize( float IN, float SpecFaloff, float Steps )
			{
				float minOut = 0.5 * SpecFaloff - 0.005;
				float faloff = lerp(IN, smoothstep(minOut, 0.5, IN), SpecFaloff);
				if(Steps < 1)
				{
				    return faloff;
				}
				else
				{
				    return  floor(faloff / (1 / Steps)) * (1 / Steps);
				}
			}
			
			float3 Hatching476( float2 _uv, float color, sampler2D _Hatch0, sampler2D _Hatch1 )
			{
				float intensity = color;
				    float3 hatch0 = tex2D(_Hatch0, _uv).rgb;
				    float3 hatch1 = tex2D(_Hatch1, _uv).rgb;
				    float3 overbright = max(0, intensity - 1.0);
				    float3 weightsA = saturate((intensity * 6.0) + float3(-0, -1, -2));
				    float3 weightsB = saturate((intensity * 6.0) + float3(-3, -4, -5));
				    weightsA.xy -= weightsA.yz;
				    weightsA.z -= weightsB.x;
				    weightsB.xy -= weightsB.yz;
				    hatch0 = hatch0 * weightsA;
				    hatch1 = hatch1 * weightsB;
				    float3 hatching = overbright + hatch0.r +
				        hatch0.g + hatch0.b +
				        hatch1.r + hatch1.g +
				        hatch1.b;
				    return hatching;
				    return hatching;
			}
			
			float3 HatchingConstantScale491( float2 _uv, float _intensity, sampler2D _Hatch0, sampler2D _Hatch1, float _dist, float _MaxScaleDependingOnCamera )
			{
					float log2_dist = log2(_dist)-0.2;
					
					float2 floored_log_dist = floor( (log2_dist + float2(0.0, 1.0) ) * 0.5) *2.0 - float2(0.0, 1.0);				
					float2 uv_scale = min(_MaxScaleDependingOnCamera, pow(2.0, floored_log_dist));
					
					float uv_blend = abs(frac(log2_dist * 0.5) * 2.0 - 1.0);
					
					float2 scaledUVA = _uv / uv_scale.x; // 16
					float2 scaledUVB = _uv / uv_scale.y; // 8 
					float3 hatch0A = tex2D(_Hatch0, scaledUVA).rgb;
					float3 hatch1A = tex2D(_Hatch1, scaledUVA).rgb;
					float3 hatch0B = tex2D(_Hatch0, scaledUVB).rgb;
					float3 hatch1B = tex2D(_Hatch1, scaledUVB).rgb;
					float3 hatch0 = lerp(hatch0A, hatch0B, uv_blend);
					float3 hatch1 = lerp(hatch1A, hatch1B, uv_blend);
					float3 overbright = max(0, _intensity - 1.0);
					float3 weightsA = saturate((_intensity * 6.0) + float3(-0, -1, -2));
					float3 weightsB = saturate((_intensity * 6.0) + float3(-3, -4, -5));
					weightsA.xy -= weightsA.yz;
					weightsA.z -= weightsB.x;
					weightsB.xy -= weightsB.yz;
					hatch0 = hatch0 * weightsA;
					hatch1 = hatch1 * weightsB;
					float3 hatching = overbright + hatch0.r +
						hatch0.g + hatch0.b +
						hatch1.r + hatch1.g +
						hatch1.b;
					return hatching;
			}
			

			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord6.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord7.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord8.xyz = ase_worldBitangent;
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( ase_worldNormal, o.lightmapUVOrVertexSH.xyz );
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord5 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;
				o.ase_texcoord8.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				o.texcoord1 = v.texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN
				#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
				#endif
				 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float temp_output_371_0 = ( _StepOffset + 0.5 );
				float smoothstepResult444 = smoothstep( ( temp_output_371_0 - 0.009 ) , temp_output_371_0 , 0.0);
				float4 lerpResult1619 = lerp( _ShadowColor , _MainLightColor , saturate( smoothstepResult444 ));
				float localLightAttenuation1412 = ( 0.0 );
				float3 WorldPos1412 = WorldPosition;
				float DistanceAtten1412 = 0;
				float ShadowAtten1412 = 0;
				{
				    #if SHADOWS_SCREEN
				        half4 clipPos = TransformWorldToHClip(WorldPos1412);
				        half4 shadowCoord = ComputeScreenPos(clipPos);
				    #else
				        half4 shadowCoord = TransformWorldToShadowCoord(WorldPos1412);
				    #endif
				    Light mainLight = GetMainLight(shadowCoord);
				    DistanceAtten1412 = mainLight.distanceAttenuation;
				    ShadowAtten1412 = mainLight.shadowAttenuation;
				}
				float4 temp_cast_0 = (ShadowAtten1412).xxxx;
				float4 ShadowAtten1415 = ( 1.0 == _UseShadows ? temp_cast_0 : float4(1,1,1,1) );
				float2 temp_cast_1 = (_WarpTextureScale).xx;
				float mulTime1523 = _TimeParameters.x * _UVScrollSpeedWarp;
				float temp_output_1518_0 = radians( _UVSrcrollAngleWarp );
				float2 appendResult1520 = (float2(cos( temp_output_1518_0 ) , sin( temp_output_1518_0 )));
				float2 temp_output_1522_0 = ( mulTime1523 * appendResult1520 );
				float2 texCoord1495 = IN.ase_texcoord3.xy * temp_cast_1 + temp_output_1522_0;
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult1847 = (float2(( _WarpTextureScale * ( _ScreenParams.x / _ScreenParams.y ) ) , _WarpTextureScale));
				#ifdef _USEADAPTIVESCREENUVSWARP_ON
				float4 staticSwitch1664 = float4( 0,0,0,0 );
				#else
				float4 staticSwitch1664 = ( ase_grabScreenPosNorm * float4( appendResult1847, 0.0 , 0.0 ) );
				#endif
				float mulTime1525 = _TimeParameters.x * _UVAnimationSpeedWarp;
				float temp_output_1527_0 = ( floor( ( mulTime1525 % 2.0 ) ) * 0.5 );
				float2 appendResult1531 = (float2(temp_output_1527_0 , temp_output_1527_0));
				#ifdef _USESCREENUVSWARP_ON
				float4 staticSwitch1514 = ( staticSwitch1664 + float4( appendResult1531, 0.0 , 0.0 ) + float4( temp_output_1522_0, 0.0 , 0.0 ) );
				#else
				float4 staticSwitch1514 = float4( texCoord1495, 0.0 , 0.0 );
				#endif
				float cos1489 = cos( radians( _WarpTextureRotation ) );
				float sin1489 = sin( radians( _WarpTextureRotation ) );
				float2 rotator1489 = mul( staticSwitch1514.xy - float2( 0.5,0.5 ) , float2x2( cos1489 , -sin1489 , sin1489 , cos1489 )) + float2( 0.5,0.5 );
				float BNLightWarpVector250 = ( _UseDiffuseWarp == 1.0 ? ( tex2D( _DiffuseWarpNoise, rotator1489 ).r * _WarpStrength ) : 0.0 );
				#ifdef _USEDIFFUSEWARPASOVERLAY_ON
				float4 staticSwitch1470 = saturate( ( ShadowAtten1415 + BNLightWarpVector250 + ( _DiffuseWarpBrightnessOffset * float4( -1,0,0,0 ) * ( 1.0 - ShadowAtten1415 ) ) ) );
				#else
				float4 staticSwitch1470 = ShadowAtten1415;
				#endif
				float4 lerpResult1626 = lerp( _ShadowColor , lerpResult1619 , staticSwitch1470);
				float2 appendResult356 = (float2(( _LightRampOffset + 0.0 ) , 0.0));
				float2 temp_cast_8 = (0.01).xx;
				float2 temp_cast_9 = (0.98).xx;
				float2 clampResult358 = clamp( appendResult356 , temp_cast_8 , temp_cast_9 );
				float4 lerpResult1617 = lerp( tex2D( _LightRampTexture, float2( 0.02,0 ) ) , ( tex2D( _LightRampTexture, clampResult358 ) * _MainLightColor ) , staticSwitch1470);
				float In1331 = pow( saturate( ( 0.0 + ( _DiffusePosterizeOffset * -1.0 ) ) ) , _DiffusePosterizePower );
				float Steps1331 = round( _DiffusePosterizeSteps );
				float localPosterize1331 = Posterize1331( In1331 , Steps1331 );
				float4 lerpResult1629 = lerp( _ShadowColor , _MainLightColor , localPosterize1331);
				float4 lerpResult1628 = lerp( _ShadowColor , lerpResult1629 , staticSwitch1470);
				#if defined(_USELIGHTRAMP_STEP)
				float4 staticSwitch372 = lerpResult1626;
				#elif defined(_USELIGHTRAMP_DIFFUSERAMP)
				float4 staticSwitch372 = lerpResult1617;
				#elif defined(_USELIGHTRAMP_POSTERIZE)
				float4 staticSwitch372 = lerpResult1628;
				#else
				float4 staticSwitch372 = lerpResult1626;
				#endif
				float3 WorldPosition1181 = WorldPosition;
				float2 uv_OcclusionMap1 = IN.ase_texcoord3.xy * _OcclusionMap1_ST.xy + _OcclusionMap1_ST.zw;
				float2 uv_OcclusionMap = IN.ase_texcoord3.xy * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
				float4 transform1877 = mul(GetObjectToWorldMatrix(),IN.ase_texcoord5);
				float temp_output_1878_0 = step( transform1877.y , _PositionY );
				#ifdef _HEIGHTMASKSWITCH_ON
				float staticSwitch1883 = ( 1.0 - temp_output_1878_0 );
				#else
				float staticSwitch1883 = temp_output_1878_0;
				#endif
				#ifdef _USEHEIGHTMASK_ON
				float staticSwitch1881 = staticSwitch1883;
				#else
				float staticSwitch1881 = 1.0;
				#endif
				float HeightMask1886 = staticSwitch1881;
				float3 lerpResult1908 = lerp( UnpackNormalScale( tex2D( _BumpMap1, uv_OcclusionMap1 ), 1.0f ) , UnpackNormalScale( tex2D( _BumpMap, uv_OcclusionMap ), 1.0f ) , HeightMask1886);
				float3 lerpResult1536 = lerp( float3(0,0,1) , lerpResult1908 , _NormalMapStrength);
				float3 ase_worldTangent = IN.ase_texcoord6.xyz;
				float3 ase_worldNormal = IN.ase_texcoord7.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord8.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal1537 = lerpResult1536;
				float3 worldNormal1537 = normalize( float3(dot(tanToWorld0,tanNormal1537), dot(tanToWorld1,tanNormal1537), dot(tanToWorld2,tanNormal1537)) );
				float3 BNCurrentNormal1538 = worldNormal1537;
				float3 WorldNormal1181 = BNCurrentNormal1538;
				float3 temp_cast_12 = (BNLightWarpVector250).xxx;
				float3 LightWrapVector1181 = temp_cast_12;
				float temp_output_1203_0 = ( 1.0 - ( (2.0 + (_AdditionalLightsAmount - 0.0) * (2.9 - 2.0) / (1.0 - 0.0)) + -2.0 ) );
				float SMin1181 = ( ( temp_output_1203_0 * _AdditionalLightsFaloff ) - 0.005 );
				float SMax1181 = temp_output_1203_0;
				float Faloff1181 = 0.0;
				float4 shadowmask1181 = float4( 1,1,1,1 );
				float3 localAdditionalLight1181 = AdditionalLight( WorldPosition1181 , WorldNormal1181 , LightWrapVector1181 , SMin1181 , SMax1181 , Faloff1181 , shadowmask1181 );
				#ifdef _USEADDITIONALLIGHTSDIFFUSE_ON
				float3 staticSwitch1143 = localAdditionalLight1181;
				#else
				float3 staticSwitch1143 = float3( 0,0,0 );
				#endif
				float3 AdditionalLightsDiffuse1144 = staticSwitch1143;
				float4 BNDiffuse391 = ( staticSwitch372 + float4( AdditionalLightsDiffuse1144 , 0.0 ) );
				#if defined(_OVERLAYMODE_NONE)
				float4 staticSwitch1266 = BNDiffuse391;
				#elif defined(_OVERLAYMODE_HAFTONE)
				float4 staticSwitch1266 = BNDiffuse391;
				#elif defined(_OVERLAYMODE_HATCHING)
				float4 staticSwitch1266 = BNDiffuse391;
				#else
				float4 staticSwitch1266 = BNDiffuse391;
				#endif
				float4 lerpResult1894 = lerp( tex2D( _MainTex1, uv_OcclusionMap1 ) , tex2D( _MainTex, uv_OcclusionMap ) , HeightMask1886);
				float lerpResult1902 = lerp( tex2D( _OcclusionMap1, uv_OcclusionMap1 ).r , tex2D( _OcclusionMap, uv_OcclusionMap ).r , HeightMask1886);
				float lerpResult1655 = lerp( 1.0 , lerpResult1902 , _OcclusionStrength);
				float4 appendResult1656 = (float4(lerpResult1655 , lerpResult1655 , lerpResult1655 , 1.0));
				float4 MainTexture364 = ( _Color * lerpResult1894 * appendResult1656 );
				float3 bakedGI276 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, BNCurrentNormal1538);
				Light ase_mainLight = GetMainLight( ShadowCoords );
				MixRealtimeAndBakedGI(ase_mainLight, BNCurrentNormal1538, bakedGI276, half4(0,0,0,0));
				float IndirectLightStrength1221 = _IndirectLightStrength;
				float3 lerpResult692 = lerp( float3( 0,0,0 ) , bakedGI276 , IndirectLightStrength1221);
				float4 IndirectDiffuseLight1269 = ( MainTexture364 * float4( lerpResult692 , 0.0 ) );
				float4 BNFinalDiffuse239 = ( ( staticSwitch1266 * MainTexture364 ) + IndirectDiffuseLight1269 );
				float4 BNDiffuseNoAdditionalLights1554 = staticSwitch372;
				float4 lerpResult1462 = lerp( _MainLightColor , BNDiffuseNoAdditionalLights1554 , _HalftoneToonAffect);
				float4 temp_output_1225_0 = ( ( lerpResult1462 + float4( AdditionalLightsDiffuse1144 , 0.0 ) ) * MainTexture364 );
				float4 lerpResult1784 = lerp( temp_output_1225_0 , _HalftoneColor , _HalftoneColor.a);
				float smoothstepResult525 = smoothstep( _HalftoneEdgeOffset , ( _HalftoneEdgeOffset + _HalftoneSmoothness ) , 0.0);
				float2 temp_cast_18 = (_OverlayUVTilling).xx;
				float mulTime1287 = _TimeParameters.x * _UVScrollSpeed;
				float temp_output_1293_0 = radians( _UVSrcrollAngle );
				float2 appendResult1294 = (float2(cos( temp_output_1293_0 ) , sin( temp_output_1293_0 )));
				float2 temp_output_1288_0 = ( mulTime1287 * appendResult1294 );
				float2 texCoord478 = IN.ase_texcoord3.xy * temp_cast_18 + temp_output_1288_0;
				float2 appendResult1849 = (float2(( _OverlayUVTilling * ( _ScreenParams.x / _ScreenParams.y ) ) , _OverlayUVTilling));
				#ifdef _USEADAPTIVESCREENUVS_ON
				float4 staticSwitch1661 = float4( 0,0,0,0 );
				#else
				float4 staticSwitch1661 = ( float4( appendResult1849, 0.0 , 0.0 ) * ase_grabScreenPosNorm );
				#endif
				float mulTime1278 = _TimeParameters.x * _UVAnimationSpeed;
				float temp_output_1281_0 = ( floor( ( mulTime1278 % 2.0 ) ) * 0.5 );
				#if defined(_OVERLAYMODE_NONE)
				float staticSwitch1277 = 0.0;
				#elif defined(_OVERLAYMODE_HAFTONE)
				float staticSwitch1277 = temp_output_1281_0;
				#elif defined(_OVERLAYMODE_HATCHING)
				float staticSwitch1277 = temp_output_1281_0;
				#else
				float staticSwitch1277 = 0.0;
				#endif
				float2 appendResult1803 = (float2(staticSwitch1277 , staticSwitch1277));
				#ifdef _USESCREENUVS_ON
				float4 staticSwitch488 = ( staticSwitch1661 + float4( appendResult1803, 0.0 , 0.0 ) + float4( temp_output_1288_0, 0.0 , 0.0 ) );
				#else
				float4 staticSwitch488 = float4( texCoord478, 0.0 , 0.0 );
				#endif
				float cos1047 = cos( radians( _OverlayRotation ) );
				float sin1047 = sin( radians( _OverlayRotation ) );
				float2 rotator1047 = mul( staticSwitch488.xy - float2( 0.5,0.5 ) , float2x2( cos1047 , -sin1047 , sin1047 , cos1047 )) + float2( 0.5,0.5 );
				float2 OverlayUVs1051 = rotator1047;
				float smoothstepResult1045 = smoothstep( ( ( _ShapeSmoothness * -0.5 ) + 0.5 ) , ( ( _ShapeSmoothness * 0.5 ) + 0.5 ) , ( 0.1 / ( ( _HalftoneThreshold / smoothstepResult525 ) * (0.0 + (tex2D( _HalftoneTexture, OverlayUVs1051 ).r - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ) ));
				float4 lerpResult1774 = lerp( lerpResult1784 , temp_output_1225_0 , smoothstepResult1045);
				float4 Halftone1022 = ( lerpResult1774 + IndirectDiffuseLight1269 );
				#if defined(_OVERLAYMODE_NONE)
				float4 staticSwitch1231 = BNFinalDiffuse239;
				#elif defined(_OVERLAYMODE_HAFTONE)
				float4 staticSwitch1231 = Halftone1022;
				#elif defined(_OVERLAYMODE_HATCHING)
				float4 staticSwitch1231 = BNFinalDiffuse239;
				#else
				float4 staticSwitch1231 = BNFinalDiffuse239;
				#endif
				float3 WorldPosition1573 = WorldPosition;
				float3 WorldNormal1573 = BNCurrentNormal1538;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 WorldView1573 = ase_worldViewDir;
				float3 SpecColor1573 = float3(1,1,1);
				float lerpResult1892 = lerp( tex2D( _SpecGlossMap1, uv_OcclusionMap1 ).r , tex2D( _SpecGlossMap, uv_OcclusionMap ).r , HeightMask1886);
				float Smoothness638 = ( ( 1.0 - lerpResult1892 ) * _Glossiness );
				float Smoothness1573 = ( Smoothness638 * ( 2.0 - _AdditionalLightsSmoothnessMultiplier ) );
				float temp_output_588_0 = round( _SpecularPosterizeSteps );
				float Steps1573 = temp_output_588_0;
				float SpecFaloff1573 = _SpecularFaloff;
				float3 localAdditionalLightsSpecularMy1573 = AdditionalLightsSpecularMy( WorldPosition1573 , WorldNormal1573 , WorldView1573 , SpecColor1573 , Smoothness1573 , Steps1573 , SpecFaloff1573 );
				float3 normalizeResult222 = normalize( _MainLightPosition.xyz );
				float3 normalizeResult238 = normalize( ( normalizeResult222 + ase_worldViewDir ) );
				float3 BNHalfDirection265 = normalizeResult238;
				float dotResult252 = dot( BNHalfDirection265 , BNCurrentNormal1538 );
				float IN1578 = ( pow( max( dotResult252 , 0.0 ) , ( exp2( ( ( Smoothness638 * 10.0 * ( 2.0 - _SmoothnessMultiplier ) ) + -2.0 ) ) * 2.0 ) ) * ( _SmoothnessMultiplier == 0.0 ? 0.0 : 1.0 ) );
				float SpecFaloff1578 = _SpecularFaloff;
				float Steps1578 = temp_output_588_0;
				float localFaloffPosterize1578 = FaloffPosterize( IN1578 , SpecFaloff1578 , Steps1578 );
				float2 temp_cast_25 = (_SpecularMaskScale).xx;
				float2 texCoord1123 = IN.ase_texcoord3.xy * temp_cast_25 + float2( 0,0 );
				float2 appendResult1842 = (float2(( _SpecularMaskScale * ( _ScreenParams.x / _ScreenParams.y ) ) , _SpecularMaskScale));
				#ifdef _USEADAPTIVEUVSSPECULAR_ON
				float4 staticSwitch1665 = float4( 0,0,0,0 );
				#else
				float4 staticSwitch1665 = ( float4( appendResult1842, 0.0 , 0.0 ) * ase_grabScreenPosNorm );
				#endif
				float mulTime1814 = _TimeParameters.x * _UVAnimationSpeedSpec;
				float temp_output_1817_0 = ( floor( ( mulTime1814 % 2.0 ) ) * 0.5 );
				#if defined(_OVERLAYMODE1_NONE)
				float staticSwitch1812 = temp_output_1817_0;
				#elif defined(_OVERLAYMODE1_HAFTONE)
				float staticSwitch1812 = temp_output_1817_0;
				#elif defined(_OVERLAYMODE1_HATCHING)
				float staticSwitch1812 = temp_output_1817_0;
				#else
				float staticSwitch1812 = temp_output_1817_0;
				#endif
				float2 appendResult1818 = (float2(staticSwitch1812 , staticSwitch1812));
				#ifdef _USESCREENUVSSPECULAR_ON
				float4 staticSwitch1132 = ( staticSwitch1665 + float4( appendResult1818, 0.0 , 0.0 ) );
				#else
				float4 staticSwitch1132 = float4( texCoord1123, 0.0 , 0.0 );
				#endif
				float mulTime1811 = _TimeParameters.x * _UVScrollSpeedSpec;
				float temp_output_1807_0 = radians( _UVSrcrollAngleSpec );
				float2 appendResult1808 = (float2(cos( temp_output_1807_0 ) , sin( temp_output_1807_0 )));
				float cos1124 = cos( radians( _SpecularMaskRotation ) );
				float sin1124 = sin( radians( _SpecularMaskRotation ) );
				float2 rotator1124 = mul( ( staticSwitch1132 + float4( ( mulTime1811 * appendResult1808 ), 0.0 , 0.0 ) ).xy - float2( 0.5,0.5 ) , float2x2( cos1124 , -sin1124 , sin1124 , cos1124 )) + float2( 0.5,0.5 );
				float2 SpecularUVs1125 = rotator1124;
				float4 tex2DNode441 = tex2D( _SpecularMaskTexture, SpecularUVs1125 );
				float temp_output_1634_0 = ( 1.0 - _HaltonePatternSize );
				float smoothstepResult1557 = smoothstep( ( temp_output_1634_0 - 0.3 ) , temp_output_1634_0 , tex2DNode441.r);
				float lerpResult446 = lerp( 1.0 , (( _StepHalftoneTexture )?( smoothstepResult1557 ):( tex2DNode441.r )) , _SpecularMaskStrength);
				#ifdef _INVERSEMASK_ON
				float staticSwitch1681 = ( 1.0 - lerpResult446 );
				#else
				float staticSwitch1681 = lerpResult446;
				#endif
				float SpecularMask902 = ( _UseSpecularMask == 1.0 ? staticSwitch1681 : 1.0 );
				float4 SpecularColor1388 = _SpecColor;
				#ifdef _USESPECULAR_ON
				float4 staticSwitch627 = ( float4( ( ( localAdditionalLightsSpecularMy1573 * _AdditionalLightsIntesity * ( _AdditionalLightsSmoothnessMultiplier == 0.0 ? 0.0 : 1.0 ) ) + ( _MainLightColor.rgb * _MainLightIntesity * localFaloffPosterize1578 ) ) , 0.0 ) * SpecularMask902 * Smoothness638 * SpecularColor1388 );
				#else
				float4 staticSwitch627 = float4( 0,0,0,0 );
				#endif
				float4 BNspecularFinalColor243 = staticSwitch627;
				float4 lerpResult1216 = lerp( _HalftoneColor , lerpResult1462 , smoothstepResult1045);
				float4 HalftoneDiffuseShadowMask1236 = lerpResult1216;
				#if defined(_OVERLAYMODE_NONE)
				float4 staticSwitch1237 = BNDiffuse391;
				#elif defined(_OVERLAYMODE_HAFTONE)
				float4 staticSwitch1237 = HalftoneDiffuseShadowMask1236;
				#elif defined(_OVERLAYMODE_HATCHING)
				float4 staticSwitch1237 = BNDiffuse391;
				#else
				float4 staticSwitch1237 = BNDiffuse391;
				#endif
				float grayscale1797 = dot(staticSwitch1237.rgb, float3(0.299,0.587,0.114));
				float lerpResult695 = lerp( 1.0 , grayscale1797 , _SpecularShadowMask);
				half3 reflectVector618 = reflect( -ase_worldViewDir, BNCurrentNormal1538 );
				float3 indirectSpecular618 = GlossyEnvironmentReflection( reflectVector618, 1.0 - Smoothness638, 0.75 );
				#ifdef _USEENVIRONMENTREFLETION_ON
				float3 staticSwitch621 = ( indirectSpecular618 * _Strength * Smoothness638 );
				#else
				float3 staticSwitch621 = float3( 0,0,0 );
				#endif
				float3 IndirectSpecular1364 = staticSwitch621;
				float4 BNBlinnPhongLightning274 = ( staticSwitch1231 + ( BNspecularFinalColor243 * lerpResult695 ) + float4( IndirectSpecular1364 , 0.0 ) );
				float grayscale1648 = Luminance(BNDiffuseNoAdditionalLights1554.rgb);
				float4 lerpResult1650 = lerp( _RimShadowColor , _RimColor , grayscale1648);
				#if defined(_RIMSPLITCOLOR_NOSPLIT)
				float4 staticSwitch1646 = _RimColor;
				#elif defined(_RIMSPLITCOLOR_MULTIPLYWITHDIFFUSE)
				float4 staticSwitch1646 = ( _RimColor * BNDiffuseNoAdditionalLights1554 );
				#elif defined(_RIMSPLITCOLOR_USESECONDCOLOR)
				float4 staticSwitch1646 = lerpResult1650;
				#else
				float4 staticSwitch1646 = _RimColor;
				#endif
				float4 RimColor1642 = staticSwitch1646;
				float fresnelNdotV454 = dot( normalize( BNCurrentNormal1538 ), ase_worldViewDir );
				float fresnelNode454 = ( 0.0 + _RimThickness * pow( max( 1.0 - fresnelNdotV454 , 0.0001 ), _RimPower ) );
				float smoothstepResult462 = smoothstep( ( ( 1.0 - _RimSmoothness ) - 0.5 ) , 0.5 , fresnelNode454);
				float FresnelValue738 = smoothstepResult462;
				float dotResult704 = dot( ase_worldViewDir , _MainLightPosition.xyz );
				float smoothstepResult726 = smoothstep( _BacklightHardness , 0.5 , saturate( ( 1.0 - ( dotResult704 - ( ( _BacklightAmount * 2.0 ) + -2.0 ) ) ) ));
				float dotResult749 = dot( BNCurrentNormal1538 , _MainLightPosition.xyz );
				float temp_output_766_0 = ( 1.0 - ( _SideShineAmount - -0.3 ) );
				float dotResult745 = dot( ( ase_worldViewDir * -1.0 ) , _MainLightPosition.xyz );
				float clampResult753 = clamp( ( ( ( dotResult749 - temp_output_766_0 ) * 4.0 ) + ( dotResult745 - temp_output_766_0 ) ) , 0.0 , 1.1 );
				float smoothstepResult759 = smoothstep( _SideShineHardness , 0.5 , ( clampResult753 * FresnelValue738 ));
				#ifdef _USEBACKLIGHT_ON
				float staticSwitch732 = ( ( _BacklightIntensity * ( FresnelValue738 * smoothstepResult726 ) ) + ( _SideShineIntensity * smoothstepResult759 ) );
				#else
				float staticSwitch732 = FresnelValue738;
				#endif
				#ifdef _USERIMLIGHT_ON
				float staticSwitch464 = staticSwitch732;
				#else
				float staticSwitch464 = 0.0;
				#endif
				float RimLight460 = staticSwitch464;
				float4 lerpResult1635 = lerp( BNBlinnPhongLightning274 , RimColor1642 , RimLight460);
				float4 lerpResult1905 = lerp( tex2D( _EmissionMap1, uv_OcclusionMap1 ) , tex2D( _EmissionMap, uv_OcclusionMap ) , HeightMask1886);
				float4 Emission680 = ( _UseEmission == 1.0 ? ( lerpResult1905 * _EmissionColor ) : float4( 0,0,0,0 ) );
				float4 temp_output_282_0 = ( lerpResult1635 + Emission680 );
				float3 IndirectHatching1466 = lerpResult692;
				float3 lerpResult1468 = lerp( float3( 0,0,0 ) , IndirectHatching1466 , _IndirectLightAffectOnHatch);
				float4 temp_output_1270_0 = ( _HatchingColor + float4( lerpResult1468 , 0.0 ) );
				float4 lerpResult1264 = lerp( BNBlinnPhongLightning274 , temp_output_1270_0 , _HatchingColor.a);
				float2 _uv476 = OverlayUVs1051;
				float temp_output_1064_0 = (( _Darken * -2.0 ) + (0.0 - 0.0) * (( ( _Lighten * 2.0 ) + 1.0 ) - ( _Darken * -2.0 )) / (1.0 - 0.0));
				float color476 = temp_output_1064_0;
				sampler2D _Hatch0476 = _Hatch1;
				sampler2D _Hatch1476 = _Hatch2;
				float3 localHatching476 = Hatching476( _uv476 , color476 , _Hatch0476 , _Hatch1476 );
				float2 _uv491 = OverlayUVs1051;
				float _intensity491 = temp_output_1064_0;
				sampler2D _Hatch0491 = _Hatch1;
				sampler2D _Hatch1491 = _Hatch2;
				float _dist491 = distance( _WorldSpaceCameraPos , WorldPosition );
				float _MaxScaleDependingOnCamera491 = _MaxScaleDependingOnCamera;
				float3 localHatchingConstantScale491 = HatchingConstantScale491( _uv491 , _intensity491 , _Hatch0491 , _Hatch1491 , _dist491 , _MaxScaleDependingOnCamera491 );
				#ifdef _USEHATCHINGCONSTANTSCALE_ON
				float3 staticSwitch490 = localHatchingConstantScale491;
				#else
				float3 staticSwitch490 = localHatching476;
				#endif
				float3 Hatching1025 = saturate( staticSwitch490 );
				float4 lerpResult1260 = lerp( lerpResult1264 , BNBlinnPhongLightning274 , Hatching1025.x);
				float2 appendResult1857 = (float2(( _PaperTilling * ( _ScreenParams.x / _ScreenParams.y ) ) , _PaperTilling));
				float4 tex2DNode1795 = tex2D( _PaperTexture, ( ase_grabScreenPosNorm * float4( appendResult1857, 0.0 , 0.0 ) ).xy );
				float4 lerpResult1254 = lerp( temp_output_1270_0 , tex2DNode1795 , Hatching1025.x);
				float4 lerpResult1257 = lerp( lerpResult1254 , tex2DNode1795 , ( 1.0 - _HatchingColor.a ));
				#ifdef _USEPURESKETCH_ON
				float4 staticSwitch1258 = lerpResult1257;
				#else
				float4 staticSwitch1258 = lerpResult1260;
				#endif
				float4 lerpResult1637 = lerp( staticSwitch1258 , RimColor1642 , RimLight460);
				#if defined(_OVERLAYMODE_NONE)
				float4 staticSwitch1024 = temp_output_282_0;
				#elif defined(_OVERLAYMODE_HAFTONE)
				float4 staticSwitch1024 = temp_output_282_0;
				#elif defined(_OVERLAYMODE_HATCHING)
				float4 staticSwitch1024 = ( lerpResult1637 + Emission680 );
				#else
				float4 staticSwitch1024 = temp_output_282_0;
				#endif
				
				float4 break671 = MainTexture364;
				#ifdef _USEAORR_ON
				float staticSwitch1915 = break671.a;
				#else
				float staticSwitch1915 = break671.r;
				#endif
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = staticSwitch1024.rgb;
				float Alpha = staticSwitch1915;
				float AlphaClipThreshold = _Cutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return half4( Color, Alpha );
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

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#pragma shader_feature_local _USEAORR_ON
			#pragma shader_feature_local _USEHEIGHTMASK_ON
			#pragma shader_feature_local _HEIGHTMASKSWITCH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color;
			float4 _ShadowColor;
			float4 _RimShadowColor;
			float4 _OcclusionMap_ST;
			float4 _HatchingColor;
			float4 _EmissionColor;
			float4 _OcclusionMap1_ST;
			float4 _SpecColor;
			float4 _HalftoneColor;
			float4 _RimColor;
			float _Strength;
			float _SpecularShadowMask;
			float _SpecularMaskStrength;
			float _SpecularMaskRotation;
			float _UVSrcrollAngleSpec;
			float _UVScrollSpeedSpec;
			float _UVAnimationSpeedSpec;
			float _SpecularMaskScale;
			float _StepHalftoneTexture;
			float _UseSpecularMask;
			float _SmoothnessMultiplier;
			float _HaltonePatternSize;
			float _RampDiffuseTextureLoaded;
			float _RimSmoothness;
			float _RimThickness;
			float _RimPower;
			float _BacklightIntensity;
			float _BacklightHardness;
			float _BacklightAmount;
			float _SideShineIntensity;
			float _SideShineHardness;
			float _SideShineAmount;
			float _UseEmission;
			float _IndirectLightAffectOnHatch;
			float _Darken;
			float _Lighten;
			float _MaxScaleDependingOnCamera;
			float _MainLightIntesity;
			float _AdditionalLightsIntesity;
			float _AdditionalLightsSmoothnessMultiplier;
			float _SpecularPosterizeSteps;
			float _DiffusePosterizeSteps;
			float _DiffusePosterizePower;
			float _DiffusePosterizeOffset;
			float _LightRampOffset;
			float _DiffuseWarpBrightnessOffset;
			float _WarpStrength;
			float _PositionY;
			float _WarpTextureRotation;
			float _UVSrcrollAngleWarp;
			float _UVScrollSpeedWarp;
			float _WarpTextureScale;
			float _UseDiffuseWarp;
			float _UseShadows;
			float _StepOffset;
			float _UVAnimationSpeedWarp;
			float _SpecularFaloff;
			float _NormalMapStrength;
			float _AdditionalLightsFaloff;
			float _PaperTilling;
			float _Glossiness;
			float _OverlayRotation;
			float _UVAnimationSpeed;
			float _UVSrcrollAngle;
			float _UVScrollSpeed;
			float _AdditionalLightsAmount;
			float _OverlayUVTilling;
			float _HalftoneEdgeOffset;
			float _HalftoneThreshold;
			float _ShapeSmoothness;
			float _HalftoneToonAffect;
			float _IndirectLightStrength;
			float _OcclusionStrength;
			float _HalftoneSmoothness;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _MainTex1;
			sampler2D _OcclusionMap1;
			sampler2D _MainTex;
			sampler2D _OcclusionMap;


			
			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = clipPos;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_OcclusionMap1 = IN.ase_texcoord2.xy * _OcclusionMap1_ST.xy + _OcclusionMap1_ST.zw;
				float2 uv_OcclusionMap = IN.ase_texcoord2.xy * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
				float4 transform1877 = mul(GetObjectToWorldMatrix(),IN.ase_texcoord3);
				float temp_output_1878_0 = step( transform1877.y , _PositionY );
				#ifdef _HEIGHTMASKSWITCH_ON
				float staticSwitch1883 = ( 1.0 - temp_output_1878_0 );
				#else
				float staticSwitch1883 = temp_output_1878_0;
				#endif
				#ifdef _USEHEIGHTMASK_ON
				float staticSwitch1881 = staticSwitch1883;
				#else
				float staticSwitch1881 = 1.0;
				#endif
				float HeightMask1886 = staticSwitch1881;
				float4 lerpResult1894 = lerp( tex2D( _MainTex1, uv_OcclusionMap1 ) , tex2D( _MainTex, uv_OcclusionMap ) , HeightMask1886);
				float lerpResult1902 = lerp( tex2D( _OcclusionMap1, uv_OcclusionMap1 ).r , tex2D( _OcclusionMap, uv_OcclusionMap ).r , HeightMask1886);
				float lerpResult1655 = lerp( 1.0 , lerpResult1902 , _OcclusionStrength);
				float4 appendResult1656 = (float4(lerpResult1655 , lerpResult1655 , lerpResult1655 , 1.0));
				float4 MainTexture364 = ( _Color * lerpResult1894 * appendResult1656 );
				float4 break671 = MainTexture364;
				#ifdef _USEAORR_ON
				float staticSwitch1915 = break671.a;
				#else
				float staticSwitch1915 = break671.r;
				#endif
				

				float Alpha = staticSwitch1915;
				float AlphaClipThreshold = _Cutoff;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On


			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140010


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
        	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#pragma shader_feature_local _USEAORR_ON
			#pragma shader_feature_local _USEHEIGHTMASK_ON
			#pragma shader_feature_local _HEIGHTMASKSWITCH_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color;
			float4 _ShadowColor;
			float4 _RimShadowColor;
			float4 _OcclusionMap_ST;
			float4 _HatchingColor;
			float4 _EmissionColor;
			float4 _OcclusionMap1_ST;
			float4 _SpecColor;
			float4 _HalftoneColor;
			float4 _RimColor;
			float _Strength;
			float _SpecularShadowMask;
			float _SpecularMaskStrength;
			float _SpecularMaskRotation;
			float _UVSrcrollAngleSpec;
			float _UVScrollSpeedSpec;
			float _UVAnimationSpeedSpec;
			float _SpecularMaskScale;
			float _StepHalftoneTexture;
			float _UseSpecularMask;
			float _SmoothnessMultiplier;
			float _HaltonePatternSize;
			float _RampDiffuseTextureLoaded;
			float _RimSmoothness;
			float _RimThickness;
			float _RimPower;
			float _BacklightIntensity;
			float _BacklightHardness;
			float _BacklightAmount;
			float _SideShineIntensity;
			float _SideShineHardness;
			float _SideShineAmount;
			float _UseEmission;
			float _IndirectLightAffectOnHatch;
			float _Darken;
			float _Lighten;
			float _MaxScaleDependingOnCamera;
			float _MainLightIntesity;
			float _AdditionalLightsIntesity;
			float _AdditionalLightsSmoothnessMultiplier;
			float _SpecularPosterizeSteps;
			float _DiffusePosterizeSteps;
			float _DiffusePosterizePower;
			float _DiffusePosterizeOffset;
			float _LightRampOffset;
			float _DiffuseWarpBrightnessOffset;
			float _WarpStrength;
			float _PositionY;
			float _WarpTextureRotation;
			float _UVSrcrollAngleWarp;
			float _UVScrollSpeedWarp;
			float _WarpTextureScale;
			float _UseDiffuseWarp;
			float _UseShadows;
			float _StepOffset;
			float _UVAnimationSpeedWarp;
			float _SpecularFaloff;
			float _NormalMapStrength;
			float _AdditionalLightsFaloff;
			float _PaperTilling;
			float _Glossiness;
			float _OverlayRotation;
			float _UVAnimationSpeed;
			float _UVSrcrollAngle;
			float _UVScrollSpeed;
			float _AdditionalLightsAmount;
			float _OverlayUVTilling;
			float _HalftoneEdgeOffset;
			float _HalftoneThreshold;
			float _ShapeSmoothness;
			float _HalftoneToonAffect;
			float _IndirectLightStrength;
			float _OcclusionStrength;
			float _HalftoneSmoothness;
			float _Cutoff;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _MainTex1;
			sampler2D _OcclusionMap1;
			sampler2D _MainTex;
			sampler2D _OcclusionMap;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			void frag( VertexOutput IN
				, out half4 outNormalWS : SV_Target0
			#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
			#endif
				 )
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float2 uv_OcclusionMap1 = IN.ase_texcoord1.xy * _OcclusionMap1_ST.xy + _OcclusionMap1_ST.zw;
				float2 uv_OcclusionMap = IN.ase_texcoord1.xy * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
				float4 transform1877 = mul(GetObjectToWorldMatrix(),IN.ase_texcoord2);
				float temp_output_1878_0 = step( transform1877.y , _PositionY );
				#ifdef _HEIGHTMASKSWITCH_ON
				float staticSwitch1883 = ( 1.0 - temp_output_1878_0 );
				#else
				float staticSwitch1883 = temp_output_1878_0;
				#endif
				#ifdef _USEHEIGHTMASK_ON
				float staticSwitch1881 = staticSwitch1883;
				#else
				float staticSwitch1881 = 1.0;
				#endif
				float HeightMask1886 = staticSwitch1881;
				float4 lerpResult1894 = lerp( tex2D( _MainTex1, uv_OcclusionMap1 ) , tex2D( _MainTex, uv_OcclusionMap ) , HeightMask1886);
				float lerpResult1902 = lerp( tex2D( _OcclusionMap1, uv_OcclusionMap1 ).r , tex2D( _OcclusionMap, uv_OcclusionMap ).r , HeightMask1886);
				float lerpResult1655 = lerp( 1.0 , lerpResult1902 , _OcclusionStrength);
				float4 appendResult1656 = (float4(lerpResult1655 , lerpResult1655 , lerpResult1655 , 1.0));
				float4 MainTexture364 = ( _Color * lerpResult1894 * appendResult1656 );
				float4 break671 = MainTexture364;
				#ifdef _USEAORR_ON
				float staticSwitch1915 = break671.a;
				#else
				float staticSwitch1915 = break671.r;
				#endif
				

				surfaceDescription.Alpha = staticSwitch1915;
				surfaceDescription.AlphaClipThreshold = _Cutoff;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float3 normalWS = normalize(IN.normalWS);
					float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					float3 normalWS = IN.normalWS;
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
				#endif
			}

			ENDHLSL
		}

	
	}
	
	CustomEditor "StylizedToonEditor"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;1887;1893.385,1823.4;Inherit;False;1480.912;376;Height Mask;9;1877;1878;1880;1879;1882;1883;1881;1885;1886;Height Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;678;1892.655,2411.535;Inherit;False;1746.969;2588.265;Comment;52;1539;1538;1537;1536;1540;1909;1908;1900;1907;1541;1906;1905;679;680;685;686;677;1903;1902;1899;1904;682;1652;1895;1894;1898;1897;1901;1651;362;1893;1656;1655;364;204;1653;636;1890;1669;1891;1892;659;1876;658;638;1388;1376;1910;1911;1912;1913;1914;Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;277;-8712.34,-525.5221;Inherit;False;6331.035;6906.721;;12;217;1122;386;901;390;213;385;215;1208;216;219;1829;BlinnPhong;0.2631274,0.6002151,0.6886792,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;504;-2238.51,2542.837;Inherit;False;2567.819;1176.527;;24;1053;1069;1111;490;1066;482;503;476;491;1025;275;498;1121;1070;1120;1119;499;492;1067;1064;481;1187;1265;1460;Hatching;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1829;-8608.175,2790.528;Inherit;False;285;161;do not delete;1;1828;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;465;-5640.059,-2170.365;Inherit;False;3204.799;1529.321;;58;760;766;740;764;741;749;762;753;745;763;742;767;748;737;759;743;744;751;747;765;1644;1647;456;1645;1646;1642;739;732;731;726;712;715;457;537;463;718;704;454;467;738;708;702;464;462;719;460;716;755;721;757;758;705;458;756;466;727;1648;1650;Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;213;-4223.762,-101.4342;Inherit;False;1762.018;982.026;;14;1231;274;696;694;270;695;259;693;271;1232;1237;1238;1366;1797;Diffuse + Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;386;-8620.72,1491.55;Inherit;False;4310.062;1258.77;;74;1451;372;361;1360;1331;1416;1157;1504;391;1554;267;1276;370;1355;1087;1188;1418;248;262;1356;1502;264;965;260;1501;240;251;356;1505;223;1417;358;1329;1508;1211;360;371;1362;359;1359;389;1500;1274;249;444;1357;1358;1330;445;1498;1599;1600;1604;1605;1509;1611;1485;1470;1483;1511;1486;1510;1617;1618;1619;1622;1623;1625;1626;1628;1629;1680;1683;1684;Main Light Diffuse Mode;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;216;-6699.028,-120.1005;Inherit;False;698.8475;398.5884;;4;1542;269;233;234;NDotL;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;901;-6259.982,3119.963;Inherit;False;1917.12;636.1124;;14;1681;440;1561;1631;1213;1632;1634;902;1557;446;437;441;438;1682;Main Specular Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1461;-2166.924,1205.188;Inherit;False;1696.135;1222.97;;24;1790;1556;1249;1637;1555;1270;1469;1264;1026;1260;1468;1467;1256;1253;1254;1258;1257;1789;1791;1795;1856;1857;1858;1855;Hatching Implementation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;385;-8634.13,377.4267;Inherit;False;2881.489;1001.912;Comment;36;1846;1845;1844;1847;1770;1495;1664;1524;1525;1526;1527;1528;1518;1492;1522;1668;1521;1529;1520;1514;384;1519;1517;1530;1523;375;382;250;378;1488;1496;1489;379;1531;381;1794;Diffuse Warp;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;387;-394.1882,1253.675;Inherit;False;338;166;;1;373;Editor Properties;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;390;-4150.935,974.0866;Inherit;False;1678.375;818.0153;;14;229;263;1269;692;642;392;1221;691;276;581;239;1266;1363;1466;Final Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1021;-2244.832,3912.274;Inherit;False;4020.123;1130.029;;39;1022;1216;1226;1225;1222;1220;1217;1042;1186;1045;508;1055;531;1041;1040;1046;1043;529;528;525;527;966;526;516;517;1234;1235;1236;1351;1354;1462;1463;1465;1552;1774;1782;1783;1784;1785;Halftone;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;219;-8646.107,-156.2836;Inherit;False;1797.078;446.0921;;9;1415;1412;244;1414;227;247;1852;1854;1853;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;217;-5812.944,-88.04369;Inherit;False;977.2441;332.3028;;6;265;238;237;236;226;222;Half Dir;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;215;-8581.911,3954.474;Inherit;False;3808.721;1802.809;;49;1577;805;1574;1576;1573;627;220;1397;903;1403;618;256;619;1093;651;1098;1094;1103;1102;623;1404;621;660;207;243;1099;650;252;1400;1097;1100;254;653;652;406;401;1096;583;649;644;588;661;1364;246;665;804;1104;1578;1579;Main Specular ;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1208;-8255.233,2855.969;Inherit;False;1877.47;918.8329;;15;1181;1202;1144;1203;1198;1154;1182;1143;1241;1243;1245;1247;1562;1831;1839;Additional Lights Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1122;-4256.003,1925.97;Inherit;False;1907.708;1406.145;;33;1859;1812;439;1842;1124;1840;1819;1793;699;1809;1665;1843;1808;1805;1811;1125;1127;1123;1806;1818;1804;1810;1814;1815;1816;1817;1129;1841;1813;1126;1769;1132;1807;Specular UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1054;-2223.868,5274.705;Inherit;False;2863.306;1438.541;;32;1294;1282;486;1296;1293;1047;1051;1295;1292;1050;1049;488;1287;1279;1277;1288;1278;1285;1280;1661;1297;1281;1056;1048;478;1792;1803;1848;1849;1850;1851;1771;Overlay UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;704;-5208.26,-1619.413;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;503;-739.7486,3528.276;Inherit;False;Property;_MaxScaleDependingOnCamera;Max Scale Depends On Camera;59;0;Create;False;0;0;0;False;0;False;1;10;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1064;-1271.18,3066.587;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1785;1204.024,4122.485;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1121;-1894.876,3059.795;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RadiansOpNode;1293;-1884.177,5702.985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1462;70.23511,4215.303;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;742;-4929.782,-979.2021;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;747;-4221.33,-1130.967;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;753;-4022.024,-1112.54;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;537;-5553.339,-2129.544;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1469;-2124.462,1991.161;Inherit;False;Property;_IndirectLightAffectOnHatch;Indirect Light Affect On Hatch;94;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;456;-3328.673,-1943.599;Inherit;False;Property;_RimColor;Rim Color;24;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleRemainderNode;1279;-1361.783,6562.875;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;486;-1021.761,5627.649;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1647;-3081.29,-1845.09;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;1287;-1934.243,5579.327;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;732;-3842.393,-2106.448;Inherit;False;Property;_UseBacklight;Rim As Backlight & Side Shine;49;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;766;-4508.814,-1059.413;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1119;-2110.699,3001.061;Inherit;False;460;RimLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1644;-3384.427,-1727.481;Inherit;False;1554;BNDiffuseNoAdditionalLights;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;763;-4473.098,-1179.416;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;1280;-1119.363,6563.279;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1460;-2123.598,3276.599;Inherit;False;243;BNspecularFinalColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;756;-4390.643,-2051.666;Inherit;False;Property;_BacklightIntensity;Backlight Intensity;48;0;Create;True;0;0;0;False;0;False;1;0;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;764;-4385.098,-962.4158;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1225;1121.372,4201.733;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotatorNode;1047;265.414,5342.625;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1292;-2168.176,5749.985;Inherit;False;Property;_UVSrcrollAngle;UV Scroll Angle;82;0;Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1351;-1334.522,4431.36;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1774;1302.066,4170.942;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1297;-2195.499,5524.506;Inherit;False;Property;_UVScrollSpeed;UV Scroll Speed;85;0;Create;False;0;0;0;False;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;765;-4935.098,-1114.416;Inherit;False;Property;_SideShineAmount;Side Shine Amount;51;0;Create;True;0;0;0;False;0;False;0.2717647;0;0;0.7;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;457;-5604.985,-1951.608;Inherit;False;Property;_RimPower;Rim Power;26;0;Create;True;0;0;0;False;0;False;2;1;1;12;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1234;945.2336,4200.764;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1040;-870.4089,4520.315;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1790;-1930.129,2107.977;Inherit;False;Property;_PaperTilling;Paper Tiling;110;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;715;-4897.933,-1752.754;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;1648;-3179.809,-1580.625;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1294;-1610.177,5701.985;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;481;-2169.376,2599.59;Inherit;True;Property;_Hatch1;Hatch Texture Darker;58;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SmoothstepOpNode;726;-4473.432,-1651.73;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1463;-254.7649,4329.303;Inherit;False;Property;_HalftoneToonAffect;Toon Affect;93;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;966;-2080.122,4293.563;Inherit;False;965;CompleteDiffuseLight;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;1556;-1463.134,1409.336;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1288;-1701.243,5524.449;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1222;882.5724,4445.615;Inherit;False;364;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GrabScreenPosition;1792;-1105.316,5895.347;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;463;-5589.063,-1858.052;Inherit;False;Property;_RimSmoothness;Rim Smoothness;27;0;Create;True;0;0;0;False;0;False;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-2118.361,3093.842;Inherit;False;391;BNDiffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;749;-4727.254,-1316.1;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;1278;-1622.947,6548.255;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1650;-2916.809,-1650.625;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;751;-4342.025,-1243.54;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1216;329.6536,4330.798;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;1277;-848.9819,6513.585;Inherit;False;Property;_OverlayMode;Overlay Mode;64;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;None;Haftone;Hatching;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;739;-4064.607,-2121.655;Inherit;False;738;FresnelValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1235;682.1721,4361.406;Inherit;False;1144;AdditionalLightsDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;526;-2025.089,3992.125;Inherit;False;Property;_HalftoneEdgeOffset;Halftone Edge Offset;54;0;Create;True;0;0;0;False;0;False;0.1;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1851;-1741.02,6074.539;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1022;1575.399,4670.469;Inherit;False;Halftone;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1270;-1801.1,1520.373;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;745;-4734.447,-933.9886;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;740;-3898.379,-869.0395;Inherit;False;738;FresnelValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1642;-2620.888,-1895.353;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1465;1276.373,4608.949;Inherit;False;1269;IndirectDiffuseLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;762;-3586.962,-1110.771;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1803;-622.5078,6419.029;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1055;-2013.269,4645.898;Inherit;False;1051;OverlayUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;721;-5280.376,-1336.585;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;1045;-648.0934,4367.319;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;760;-3797.018,-773.5529;Inherit;False;Property;_SideShineHardness;Side Shine Hardness;11;0;Create;False;0;0;0;False;0;False;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;718;-4161.13,-1952.12;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;460;-3139.282,-2089.385;Inherit;False;RimLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;1296;-1754.177,5772.985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;1855;-1917.826,2214.864;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CosOpNode;1295;-1741.177,5674.985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1265;-315.796,2787.393;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1067;-1745.472,3174.743;Inherit;False;Property;_Darken;Darken;68;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;516;-1063.541,4249.853;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1771;-1081.583,5455.181;Inherit;False;StaticScreenSpaceUV;-1;;203;1e9a29825d5b8df43882e5bd6744aaf5;0;1;7;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LightColorNode;1552;-250.2906,4059.738;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;712;-5459.111,-1548.884;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;498;-774.9536,3369.153;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1066;-1840.345,3338.422;Inherit;False;Property;_Lighten;Lighten;69;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1646;-2813.069,-1788.761;Inherit;False;Property;_RimSplitColor;Rim Split Color;102;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;NoSplit;MultiplyWithDiffuse;UseSecondColor;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;748;-5005.625,-1315.216;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1187;-1529.354,2768.867;Inherit;False;MaxFromVector3;-1;;204;92f2539b674dd3042b132cfbdf18809e;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1281;-986.9837,6560.881;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;755;-4295.264,-1794.453;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;488;-224.0378,5324.21;Inherit;False;Property;_UseScreenUvs;Screen Uvs;66;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;705;-5018.649,-1616.99;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;-0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;1049;275.5697,5587.871;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1236;591.3068,4597.426;Inherit;False;HalftoneDiffuseShadowMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;462;-4830.462,-2072.169;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;492;-1058.644,3358.441;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;491;-985.7573,2994.764;Inherit;False;	float log2_dist = log2(_dist)-0.2@$	$	float2 floored_log_dist = floor( (log2_dist + float2(0.0, 1.0) ) * 0.5) *2.0 - float2(0.0, 1.0)@				$	float2 uv_scale = min(_MaxScaleDependingOnCamera, pow(2.0, floored_log_dist))@$	$	float uv_blend = abs(frac(log2_dist * 0.5) * 2.0 - 1.0)@$	$	float2 scaledUVA = _uv / uv_scale.x@ // 16$	float2 scaledUVB = _uv / uv_scale.y@ // 8 $$	float3 hatch0A = tex2D(_Hatch0, scaledUVA).rgb@$	float3 hatch1A = tex2D(_Hatch1, scaledUVA).rgb@$$	float3 hatch0B = tex2D(_Hatch0, scaledUVB).rgb@$	float3 hatch1B = tex2D(_Hatch1, scaledUVB).rgb@$$	float3 hatch0 = lerp(hatch0A, hatch0B, uv_blend)@$	float3 hatch1 = lerp(hatch1A, hatch1B, uv_blend)@$$	float3 overbright = max(0, _intensity - 1.0)@$$	float3 weightsA = saturate((_intensity * 6.0) + float3(-0, -1, -2))@$	float3 weightsB = saturate((_intensity * 6.0) + float3(-3, -4, -5))@$$	weightsA.xy -= weightsA.yz@$	weightsA.z -= weightsB.x@$	weightsB.xy -= weightsB.yz@$$	hatch0 = hatch0 * weightsA@$	hatch1 = hatch1 * weightsB@$$	float3 hatching = overbright + hatch0.r +$		hatch0.g + hatch0.b +$		hatch1.r + hatch1.g +$		hatch1.b@$$	return hatching@;3;Create;6;False;_uv;FLOAT2;0,0;In;;Inherit;False;False;_intensity;FLOAT;0;In;;Inherit;False;False;_Hatch0;SAMPLER2D;;In;;Inherit;False;False;_Hatch1;SAMPLER2D;;In;;Inherit;False;False;_dist;FLOAT;0;In;;Inherit;False;True;_MaxScaleDependingOnCamera;FLOAT;0;In;;Inherit;False;HatchingConstantScale;True;False;0;;False;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;SAMPLER2D;;False;3;SAMPLER2D;;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;727;-4815.87,-1539.749;Inherit;False;Property;_BacklightHardness;Backlight Hardness;12;0;Create;False;0;0;0;False;0;False;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;716;-4654.227,-1670.615;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;708;-5591.349,-1353.171;Inherit;False;Property;_BacklightAmount;Backlight Amount;46;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1111;-1538.438,3340.503;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;527;-2016.089,4125.125;Inherit;False;Property;_HalftoneSmoothness;Halftone Smoothness;53;0;Create;True;0;0;0;False;0;False;0.3;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;1048;38.08137,5400.067;Inherit;False;Constant;_Vector0;Vector 0;87;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;466;-5242.708,-1910.779;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;737;-3593.576,-958.1137;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;528;-1696.994,4115.875;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;467;-5058.828,-1971.528;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1257;-1332.921,1677.669;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;529;-1604.635,3962.274;Inherit;False;Property;_HalftoneThreshold;Halftone Threshold;55;0;Create;True;0;0;0;False;0;False;0.1;0;0;0.15;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;741;-5019.831,-824.9588;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;1645;-3222.753,-1464.377;Inherit;False;Property;_RimShadowColor;Rim Shadow Color;101;0;Create;False;0;0;0;False;0;False;0,0.05551431,0.9622642,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1041;-1020.704,4572.356;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;738;-4643.759,-2057.498;Inherit;False;FresnelValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;731;-3942.954,-1892.481;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;702;-5514.83,-1667.682;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;1467;-2134.365,1863.206;Inherit;False;1466;IndirectHatching;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;757;-3940.847,-1706.104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1661;-729.9348,5462.572;Inherit;False;Property;_UseAdaptiveScreenUvs;Adaptive Screen Uvs;106;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;1217;75.86629,3963.918;Inherit;False;Property;_HalftoneColor;Halftone Color;56;0;Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;758;-4246.149,-1623.295;Inherit;False;Property;_SideShineIntensity;Side Shine Intensity;50;0;Create;False;0;0;0;False;0;False;1;0;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1046;-1312.338,4731.281;Inherit;False;Property;_ShapeSmoothness;Transition Smoothness;62;0;Create;False;0;0;0;False;0;False;0.2;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;458;-5597.563,-2045.219;Inherit;False;Property;_RimThickness;Rim Thickness;25;0;Create;True;0;0;0;False;0;False;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1069;-1437.051,3185.468;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1354;-1429.461,4606.334;Inherit;False;Property;_Inverse;Inverse;88;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;517;-1231.262,4129.005;Inherit;False;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1186;-1771.505,4300.659;Inherit;False;MaxFromVector3;-1;;209;92f2539b674dd3042b132cfbdf18809e;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1050;-7.669638,5671.659;Inherit;False;Property;_OverlayRotation;UV Rotation;63;0;Create;False;0;0;0;False;0;False;0;0;0;180;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;476;-1077.271,2633.342;Inherit;False;float intensity = color@$$    float3 hatch0 = tex2D(_Hatch0, _uv).rgb@$    float3 hatch1 = tex2D(_Hatch1, _uv).rgb@$$    float3 overbright = max(0, intensity - 1.0)@$$    float3 weightsA = saturate((intensity * 6.0) + float3(-0, -1, -2))@$    float3 weightsB = saturate((intensity * 6.0) + float3(-3, -4, -5))@$$    weightsA.xy -= weightsA.yz@$    weightsA.z -= weightsB.x@$    weightsB.xy -= weightsB.yz@$$    hatch0 = hatch0 * weightsA@$    hatch1 = hatch1 * weightsB@$$    float3 hatching = overbright + hatch0.r +$        hatch0.g + hatch0.b +$        hatch1.r + hatch1.g +$        hatch1.b@$$    return hatching@$    return hatching@;3;Create;4;False;_uv;FLOAT2;0,0;In;;Inherit;False;True;color;FLOAT;0;In;;Inherit;False;False;_Hatch0;SAMPLER2D;;In;;Inherit;False;False;_Hatch1;SAMPLER2D;;In;;Inherit;False;Hatching;True;False;0;;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;SAMPLER2D;;False;3;SAMPLER2D;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1043;-805.9669,4710.431;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;482;-2170.969,2780.633;Inherit;True;Property;_Hatch2;Hatch Texture Brighter;57;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FresnelNode;454;-5305.858,-2120.365;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;743;-5123.541,-933.7499;Inherit;False;Constant;_Float2;Float 2;62;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;759;-3432.88,-1129.533;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1782;537.9628,4803.693;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;525;-1451.088,4118.125;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1285;-1906.924,6578.094;Inherit;False;Property;_UVAnimationSpeed;UV Animation Speed;80;0;Create;False;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;744;-5181.189,-1107.282;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;1070;-1403.74,3305.438;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1226;1529.925,4309.969;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1784;591.0415,4015.491;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;719;-5142.072,-1356.492;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1253;-2070.124,1585.938;Inherit;False;Property;_HatchingColor;Hatching Color;76;0;Create;False;0;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;1254;-1553.623,1562.387;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1856;-1534.746,2176.987;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1783;1170.956,4503.854;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;767;-4633.815,-1088.413;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;499;-979.4488,3531.412;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;478;-874.71,5302.008;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1056;-1820.309,5313.773;Inherit;False;Property;_OverlayUVTilling;UV Tiling;65;0;Create;False;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1850;-1612.5,6012.844;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1025;-267.1698,2626.978;Inherit;False;Hatching;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1042;-977.7531,4746.639;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;531;-811.8291,4229.577;Inherit;False;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;508;-1782.492,4485.812;Inherit;True;Property;_HalftoneTexture;Halftone Texture;52;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;1468;-1880.071,1840.766;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1220;-286.4756,4226.19;Inherit;False;1554;BNDiffuseNoAdditionalLights;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1053;-1393.442,2619.551;Inherit;False;1051;OverlayUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenParams;1848;-1976.309,6057.35;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;1858;-1669.666,2175.111;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1256;-1518.766,1779.329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1849;-1462.324,5970.229;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1282;-304.562,5491.295;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;1795;-974.3113,1902.741;Inherit;True;Property;_PaperTexture;Paper Texture;111;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1120;-2101.053,3178.53;Inherit;False;680;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1789;-1220.61,2037.258;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GrabScreenPosition;1791;-1492.132,1926.313;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;1857;-1387.452,2162.439;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1555;-1762.134,1299.336;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;1637;-878.1372,1225.523;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1264;-1482.546,1247.387;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1249;-688.2852,1269.027;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1643;-1137.734,830.2725;Inherit;False;1642;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;1636;-1215.137,709.5232;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;282;-438.3608,945.2823;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1260;-1209.246,1245.788;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;-1063.669,1038.62;Inherit;False;460;RimLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;681;-773.323,1053.889;Inherit;False;680;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1635;-822.1129,860.0081;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;490;-719.8448,2736.505;Inherit;False;Property;_UseHatchingConstantScale;Hatching Constant Scale;60;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;530;-1778.019,976.3893;Inherit;False;274;BNBlinnPhongLightning;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1868;810.7261,969.3201;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1869;810.7261,969.3201;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1870;810.7261,969.3201;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1871;810.7261,969.3201;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1872;810.7261,969.3201;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1873;810.7261,969.3201;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1874;810.7261,969.3201;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1875;810.7261,969.3201;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1867;723.2704,934.1802;Float;False;True;-1;2;StylizedToonEditor;0;13;Stylized Toon;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;0;0;  Blend;0;0;Two Sided;1;638589572018328612;Forward Only;0;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;638589494758366159;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;True;False;False;False;False;False;True;False;False;;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;1026;-1958.094,1282.58;Inherit;False;1025;Hatching;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1051;446.9252,5330.698;Inherit;False;OverlayUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;1376;3070.242,2480.237;Inherit;False;Property;_SpecColor;Specular Value;4;0;Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;1024;-145.8171,935.0305;Inherit;False;Property;_OverlayMode;Overlay Mode;78;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;None;Haftone;Hatching;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;373;-344.1882,1303.675;Inherit;False;Property;_RampDiffuseTextureLoaded;RampDiffuseTextureLoaded;15;1;[HideInInspector];Create;True;0;0;0;True;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1388;3298.263,2538.456;Inherit;False;SpecularColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;1818;-2990.821,2908.427;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RadiansOpNode;1127;-2975.369,2138.291;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1125;-2681.029,2018.868;Inherit;False;SpecularUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;274;-2689.04,-38.75474;Inherit;False;BNBlinnPhongLightning;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;259;-2902.172,-32.26303;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1819;-2975.042,2436.494;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RotatorNode;1124;-2939.488,1939.858;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;1812;-2962.782,3086.823;Inherit;False;Property;_OverlayMode1;Overlay Mode;61;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;None;Haftone;Hatching;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1269;-2870.856,1334.759;Inherit;False;IndirectDiffuseLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1466;-2940.593,1499.446;Inherit;False;IndirectHatching;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;263;-2951.979,1067.371;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;239;-2695.14,1038.715;Float;True;BNFinalDiffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1096;-8377.232,5623.042;Inherit;False;Property;_SmoothnessMultiplier;Main Specular Size;71;0;Create;False;0;0;0;True;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;1807;-3729.702,2903.758;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;627;-5394.909,4345.134;Inherit;False;Property;_UseSpecular;UseSpecular Highlights;3;0;Create;False;0;0;0;True;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1241;-7415.964,3284.039;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1400;-6722.154,4876.748;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;1604;-4873.588,2536.984;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1087;-4539.418,1880.996;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1098;-7047.781,4339.153;Inherit;False;Property;_AdditionalLightsIntesity;Additional Lights Intensity;72;0;Create;False;0;0;0;True;0;False;1;0;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;1561;-5320.076,3300.247;Inherit;False;Property;_StepHalftoneTexture;Step Halftone Texture;99;0;Create;False;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;651;-8314.96,5460.639;Float;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1502;-8332.669,2285.535;Inherit;False;233;BNNDotL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1682;-4893.994,3481.547;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1576;-8054.367,4128.461;Inherit;False;Constant;_Vector6;Vector 6;125;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;619;-6537.613,5153.784;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;1412;-8338.117,-62.14065;Inherit;False;$    #if SHADOWS_SCREEN$        half4 clipPos = TransformWorldToHClip(WorldPos)@$        half4 shadowCoord = ComputeScreenPos(clipPos)@$    #else$        half4 shadowCoord = TransformWorldToShadowCoord(WorldPos)@$    #endif$$    Light mainLight = GetMainLight(shadowCoord)@$    DistanceAtten = mainLight.distanceAttenuation@$    ShadowAtten = mainLight.shadowAttenuation@$;7;Create;3;True;WorldPos;FLOAT3;0,0,0;In;;Inherit;False;True;DistanceAtten;FLOAT;0;Out;;Inherit;False;True;ShadowAtten;FLOAT;0;Out;;Inherit;False;Light Attenuation;True;False;0;;False;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1276;-6998.562,1786.971;Inherit;False;Constant;_Float4;Float 4;101;0;Create;True;0;0;0;False;0;False;0.98;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1531;-7616.207,1027.153;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1356;-6461.743,2105.301;Inherit;False;Property;_DiffusePosterizePower;Posterize Power;89;0;Create;False;0;0;0;True;0;False;1;0.5;0.5;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1132;-3483.504,1987.187;Inherit;False;Property;_UseScreenUvsSpecular;Screen Uvs;67;0;Create;False;0;0;0;True;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;264;-7984.623,1884.971;Float;False;Constant;_Vector3;Vector 3;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;358;-6812.518,1662.798;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.02,0.02;False;2;FLOAT2;0.98,0.98;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;696;-4066.367,523.9318;Inherit;False;Property;_SpecularShadowMask;Specular Shadow Mask;43;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;694;-3362.859,210.1362;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1102;-8090.97,5562.357;Inherit;False;2;0;FLOAT;2;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1486;-5285.156,2421.452;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;391;-4497.999,1668.445;Inherit;False;BNDiffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1366;-3087.229,205.437;Inherit;False;1364;IndirectSpecular;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1500;-7762.621,2299.762;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;379;-6460.639,884.1407;Inherit;False;Property;_WarpStrength;Warp Strength;19;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1769;-3909.042,2441.284;Inherit;False;StaticScreenSpaceUV;-1;;210;1e9a29825d5b8df43882e5bd6744aaf5;0;1;7;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1416;-5977.533,2348.847;Inherit;False;1415;ShadowAtten;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1397;-5915.733,4876.659;Inherit;False;638;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;583;-7689.869,5010.036;Inherit;False;Property;_SpecularPosterizeSteps;Specular Posterize Steps;31;0;Create;True;0;0;0;True;0;False;0;0;0;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;406;-6880.468,4660.085;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.Vector3Node;1504;-8302.158,2398.808;Float;False;Constant;_Vector2;Vector 2;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1097;-6717.725,4304.438;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1554;-4582.443,1547.87;Inherit;False;BNDiffuseNoAdditionalLights;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;1231;-3747.302,-51.16261;Inherit;False;Property;_OverlayMode;Overlay Mode;74;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;None;Haftone;Hatching;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;1470;-5436.448,2246.361;Inherit;False;Property;_UseDiffuseWarpAsOverlay;Impact Shadows;95;0;Create;False;0;0;0;True;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;1126;-3112.491,1993.089;Inherit;False;Constant;_Vector5;Vector 5;87;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;1144;-6909.256,2926.699;Inherit;False;AdditionalLightsDiffuse;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;-8537.758,1988.879;Inherit;False;250;BNLightWarpVector;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1483;-5721.615,2453.412;Inherit;False;250;BNLightWarpVector;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1622;-5769.778,1518.934;Inherit;True;Property;_LightRampTexture;Light Ramp Texture;10;2;[NoScaleOffset];[SingleLineTexture];Fetch;True;0;0;0;False;1;;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1680;-5819.193,1706.619;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1626;-5157.425,1718.297;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;-7364.917,-65.63436;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotatorNode;1489;-6790.699,457.5547;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-5664.419,4727.238;Inherit;False;4;4;0;FLOAT3;1,1,1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1813;-4035.723,3151.332;Inherit;False;Property;_UVAnimationSpeedSpec;UV Animation Speed;79;0;Create;False;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1331;-6064.048,2063.613;Inherit;False;return  floor(In / (1 / Steps)) * (1 / Steps)@;1;Create;2;True;In;FLOAT;0;In;;Inherit;False;True;Steps;FLOAT;0;In;;Inherit;False;Posterize;True;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1094;-8001.043,4500.372;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1841;-3901.609,2017.47;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1129;-3775.143,2213.889;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1817;-3115.783,3134.118;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;236;-5737.849,81.31095;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FloorOpNode;1816;-3248.162,3136.517;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleRemainderNode;1815;-3490.582,3136.112;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1496;-6931.165,864.9157;Inherit;False;Property;_WarpTextureRotation;UV Rotation;44;0;Create;False;0;0;0;True;0;False;0;83.96;0;180;0;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;1488;-6745.527,683.3247;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1417;-7719.575,2012.745;Inherit;False;1415;ShadowAtten;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1542;-6645.193,-74.01072;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;1814;-3751.746,3121.492;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1810;-3546.768,2725.22;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1358;-6816.543,2211.502;Inherit;False;Property;_DiffusePosterizeOffset;Posterize Offset;90;0;Create;False;0;0;0;True;0;False;0;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1157;-4610.538,2062.201;Inherit;False;1144;AdditionalLightsDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;1804;-3599.702,2973.758;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;644;-6804.428,5268.635;Inherit;False;638;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;233;-6252.867,-41.46098;Float;False;BNNDotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;248;-8371.313,1870.331;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1579;-6513.027,4372.369;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CosOpNode;1806;-3586.702,2875.758;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;805;-8266.64,3990.388;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;267;-8075.988,1741.493;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;240;-7777.448,1879.199;Inherit;False;244;BNAttenuationColor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1123;-3727.248,1938.97;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1238;-4208.404,290.9253;Inherit;False;1236;HalftoneDiffuseShadowMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;1143;-7224.593,2924.665;Inherit;False;Property;_UseAdditionalLightsDiffuse;UseAdditional Lights;73;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;378;-6221.39,723.3884;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;359;-7427.593,1557.338;Inherit;False;Property;_LightRampOffset;Light Ramp Offset;7;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1681;-4849.501,3322.218;Inherit;False;Property;_InverseMask;Inverse Mask;109;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;623;-6444.567,5367.681;Inherit;False;Property;_Strength;Strength;33;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;1811;-3779.768,2780.098;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;250;-6031.233,585.0117;Float;False;BNLightWarpVector;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1805;-4013.701,2950.758;Inherit;False;Property;_UVSrcrollAngleSpec;UV Scroll Angle;81;0;Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1573;-7352.652,4221.119;Inherit;False;float3 Color = 0@$$Smoothness = exp2(10 * Smoothness + 1)@$int numLights = GetAdditionalLightsCount()@$for(int i = 0@ i<numLights@i++)${$	$			#if VERSION_GREATER_EQUAL(10, 1)$			Light light = GetAdditionalLight(i, WorldPosition, half4(1,1,1,1))@$			// see AdditionalLights_float for explanation of this$		#else$			Light light = GetAdditionalLight(i, WorldPosition)@$		#endif$	$	half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation)@$	Color += LightingSpecular(AttLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), Smoothness)@	$}$$float IN = max(Color.b,max(Color.r,Color.g))@$$float minOut = 0.5 * SpecFaloff - 0.005@$float faloff = lerp(IN, smoothstep(minOut, 0.5, IN), SpecFaloff)@$if(Steps < 1)${$    return Color *faloff@$}$else${$    return  Color *floor(faloff / (1 / Steps)) * (1 / Steps)@$}$;3;Create;7;True;WorldPosition;FLOAT3;0,0,0;In;;Float;False;True;WorldNormal;FLOAT3;0,0,0;In;;Float;False;True;WorldView;FLOAT3;0,0,0;In;;Float;False;True;SpecColor;FLOAT3;0,0,0;In;;Float;False;True;Smoothness;FLOAT;0.5;In;;Float;False;True;Steps;FLOAT;0;In;;Inherit;False;True;SpecFaloff;FLOAT;0;In;;Inherit;False;AdditionalLightsSpecularMy;False;False;0;;False;7;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.5;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;621;-5814.826,5212.521;Inherit;False;Property;_UseEnvironmentRefletion;UseEnvironment Reflections;32;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;1808;-3455.702,2902.758;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RoundOpNode;588;-7354.939,4970.186;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;382;-6429.525,438.2201;Inherit;False;Property;_UseDiffuseWarp;UseDiffuse Warp;22;1;[Toggle];Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;-7674.423,1742.472;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;1355;-6295.743,1902.301;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;1330;-6288.236,2193.322;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;262;-7861.623,1720.972;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;375;-6576.618,601.3608;Inherit;True;Property;_DiffuseWarpNoise;Diffuse Warp Noise;16;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1505;-8079.073,2416.526;Inherit;False;244;BNAttenuationColor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1617;-5281.391,1590.111;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;804;-8412.819,4467.384;Inherit;False;638;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;438;-4896.638,3167.078;Inherit;False;Property;_UseSpecularMask;UseSpecular Mask;23;1;[Toggle];Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;653;-8077.96,5406.638;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;441;-5792.356,3235.287;Inherit;True;Property;_SpecularMaskTexture;Specular Mask Texture;17;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;1843;-4030.528,2051.594;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1665;-3598.649,2311.999;Inherit;False;Property;_UseAdaptiveUvsSpecular;Adaptive Screen Uvs;107;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;1625;-5671.335,2043.214;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;903;-5917.572,4774.014;Inherit;False;902;SpecularMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;1618;-6083.81,1769.889;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SmoothstepOpNode;1557;-5522.992,3418.264;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;0.97;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1809;-4041.025,2725.279;Inherit;False;Property;_UVScrollSpeedSpec;UV Scroll Speed;86;0;Create;False;0;0;0;False;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1501;-8124.843,2301.196;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;902;-4520.173,3326.998;Inherit;False;SpecularMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1628;-5203.611,1922.029;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;649;-7901.96,5539.638;Float;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;965;-7140.454,2031.708;Inherit;False;CompleteDiffuseLight;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;389;-8388.974,1718.752;Inherit;False;250;BNLightWarpVector;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1611;-4586.044,2460.219;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1599;-5076.358,2569.555;Inherit;False;1415;ShadowAtten;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;372;-4885.357,1717.434;Inherit;False;Property;_UseLightRamp;Shading Mode;14;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;Step;DiffuseRamp;Posterize;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;237;-5360.315,-0.981535;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;247;-7629.022,-116.7794;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;1523;-7958.361,842.0758;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1362;-6523.511,2195.567;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;699;-3181.384,2269.865;Inherit;False;Property;_SpecularMaskRotation;Specular Mask Rotation;45;0;Create;True;0;0;0;True;0;False;0;83.96;0;180;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1631;-6155.204,3452.761;Inherit;False;Property;_HaltonePatternSize;Halftone Pattern Size;100;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1530;-7425.225,650.645;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;1498;-7443.764,2359.242;Inherit;False;Property;_DiffuseWarpAffectHalftone;Diffuse Warp Affect Halftone;96;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1683;-7218.195,2153.611;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;-4176.827,-57.4335;Inherit;False;239;BNFinalDiffuse;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;1099;-7644.746,5564.603;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1517;-8479.15,936.9966;Inherit;False;Property;_UVSrcrollAngleWarp;UV Scroll Angle;83;0;Create;False;0;0;0;False;0;False;0;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;1519;-8052.147,861.9963;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;618;-6296.083,5177.781;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;1;False;2;FLOAT;0.75;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;1359;-6438.743,1911.401;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;265;-5072.315,-0.981535;Float;False;BNHalfDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;256;-8264.521,5225.708;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;1360;-6030.953,1940.706;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1104;-8035.452,4700.151;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;356;-6985.301,1593.624;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;1619;-5418.753,1849.88;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;1237;-3947.062,194.4302;Inherit;False;Property;_OverlayMode;Overlay Mode;79;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;None;Haftone;Hatching;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1629;-5451.439,2049.562;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;1623;-6019.826,1550.257;Inherit;False;Constant;_Vector7;Vector 7;127;0;Create;True;0;0;0;False;0;False;0.02,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;243;-5371.811,4128.249;Float;False;BNspecularFinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;650;-7767.967,5428.638;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Exp2OpNode;652;-7618.967,5433.638;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;252;-8002.937,5162.043;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;370;-7151.208,2420.132;Inherit;False;Property;_StepOffset;Step Offset;13;0;Create;False;0;0;0;True;0;False;0;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1485;-5452.594,2413.305;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Compare;384;-6183.055,482.7426;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;-7144.707,-98.69603;Float;False;BNAttenuationColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1232;-4123.815,43.39497;Inherit;False;1022;Halftone;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1510;-5574.96,2609.501;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT4;-1,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1103;-8180.91,4565.736;Inherit;False;2;0;FLOAT;2;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1414;-8576.286,-77.44059;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1632;-5677.024,3533.198;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1514;-7311.994,422.4733;Inherit;False;Property;_UseScreenUvsWarp;Screen Uvs;98;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;222;-5536.315,-39.98154;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1364;-5447.247,5274.057;Inherit;False;IndirectSpecular;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;1511;-5744.213,2541.038;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;238;-5232.315,-0.981535;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1274;-7002.562,1708.971;Inherit;False;Constant;_Float3;Float 3;101;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;360;-7120.875,1607.813;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1520;-7921.146,888.9964;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;695;-3507.032,326.3487;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1188;-7341.117,1812.627;Inherit;False;MaxFromVector3;-1;;211;92f2539b674dd3042b132cfbdf18809e;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-7642.113,4800.276;Inherit;False;Property;_SpecularFaloff;Specular Falloff;6;0;Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1418;-7479.19,1965.785;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;1529;-8486.227,1196.88;Inherit;False;Property;_UVAnimationSpeedWarp;UV Animation Speed;78;0;Create;False;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1574;-8232.19,4064.479;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;254;-8250.275,5136.708;Inherit;False;265;BNHalfDirection;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;1521;-8065.148,959.9966;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;437;-4633.83,3219.313;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;444;-6723.819,2054.267;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.495;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;361;-6577.838,1630.986;Inherit;True;Property;_LightRampTexture;Light Ramp Texture;12;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;1;;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;234;-6396.868,-57.46097;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1668;-7894.002,509.1098;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-5242.381,3499.584;Inherit;False;Property;_SpecularMaskStrength;Specular Mask Strength;18;0;Create;True;0;0;0;True;0;False;0.1856417;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1522;-7714.729,820.8349;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;1600;-4900.91,2657.591;Inherit;False;250;BNLightWarpVector;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;371;-6968.663,2262.271;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;1492;-7038.733,503.56;Inherit;False;Constant;_Vector1;Vector 1;87;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;446;-5070.887,3330.016;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;1518;-8195.149,889.9964;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;1528;-7896.942,1146.616;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;223;-8186.535,2050.524;Inherit;False;233;BNNDotL;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1634;-5845.564,3451.939;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;665;-7725.758,5287.896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1527;-7770.942,1060.219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1329;-6775.451,2333.852;Inherit;False;Property;_DiffusePosterizeSteps;Posterize Steps;87;0;Create;False;0;0;0;True;0;False;3;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1578;-6971.983,4959.226;Inherit;False;float minOut = 0.5 * SpecFaloff - 0.005@$float faloff = lerp(IN, smoothstep(minOut, 0.5, IN), SpecFaloff)@$if(Steps < 1)${$    return faloff@$}$else${$    return  floor(faloff / (1 / Steps)) * (1 / Steps)@$};1;Create;3;True;IN;FLOAT;0;In;;Inherit;False;True;SpecFaloff;FLOAT;0;In;;Inherit;False;True;Steps;FLOAT;0;In;;Inherit;False;FaloffPosterize;False;False;0;;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1605;-4710.493,2508.38;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;269;-6462.134,101.6377;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleRemainderNode;1526;-8049.742,1078.213;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;445;-6908.392,2144.705;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.009;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;693;-4173.962,163.8831;Inherit;False;391;BNDiffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1093;-8509.073,4651.37;Inherit;False;Property;_AdditionalLightsSmoothnessMultiplier;Additional Lights Specular Size;70;0;Create;False;0;0;0;True;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1357;-6607.743,1897.1;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;246;-7853.529,5198.708;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;1793;-4077.7,2227.668;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;251;-8202.316,1873.331;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1211;-7756.293,2178.352;Inherit;False;1144;AdditionalLightsDiffuse;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1404;-7092.541,4800.361;Inherit;False;Property;_MainLightIntesity;Main Light Intensity;91;0;Create;False;0;0;0;False;0;False;1;0;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;661;-5965.696,5213.607;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;1451;-5606.5,1727.487;Inherit;False;Property;_ShadowColor;Shadow Color;92;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;1525;-8232.342,1118.616;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1524;-8282.112,770.8133;Inherit;False;Property;_UVScrollSpeedWarp;UV Scroll Speed;84;0;Create;False;0;0;0;False;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1100;-7352.857,5246.325;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1664;-7760.704,598.5131;Inherit;False;Property;_UseAdaptiveScreenUvsWarp;Adaptive Screen Uvs ;108;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1495;-7673.453,420.7914;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1509;-5981.463,2587.955;Inherit;False;Property;_DiffuseWarpBrightnessOffset;Brightness Offset;97;0;Create;False;0;0;0;True;0;False;1.12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1415;-7686.473,65.94994;Inherit;False;ShadowAtten;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PowerNode;401;-7572.419,5237.96;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1577;-8025.121,3989.39;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;1508;-7951.469,2505.875;Inherit;False;1415;ShadowAtten;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenParams;1840;-4235.466,2086.124;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;270;-3714.163,168.6991;Inherit;False;243;BNspecularFinalColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1213;-6127.214,3215.41;Inherit;False;1125;SpecularUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCGrayscale;1797;-3702.485,260.616;Inherit;False;1;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1247;-7875.547,3451.167;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1203;-7773.428,3324.837;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;660;-8359.65,5329.313;Inherit;False;638;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1842;-3906.609,2130.471;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;439;-4164.231,1953.933;Inherit;False;Property;_SpecularMaskScale;Specular Mask Tiling;20;0;Create;False;0;0;0;True;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;-8536.394,429.6596;Inherit;False;Property;_WarpTextureScale;UV Tiling;21;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1770;-8012.953,660.4847;Inherit;False;StaticScreenSpaceUV;-1;;212;1e9a29825d5b8df43882e5bd6744aaf5;0;1;7;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1245;-7574.519,3525.854;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1854;-7896.683,40.65627;Inherit;False;0;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;1847;-8213.575,515.1918;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;1853;-8243.963,82.99063;Inherit;False;Constant;_Vector4;Vector 4;51;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;1859;-3293.502,2467.927;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;1852;-8007.826,-114.2807;Inherit;False;Property;_UseShadows;Use Shadows;47;1;[Toggle];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1562;-8099.194,3454.012;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2;False;4;FLOAT;2.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;1844;-8619.949,649.6171;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;1845;-8495.789,527.8643;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1846;-8360.869,529.7402;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1266;-3794.119,1053.244;Inherit;False;Property;_OverlayMode;Overlay Mode;79;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;None;Haftone;Hatching;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;691;-3666.051,1669.313;Inherit;False;Property;_IndirectLightStrength;Indirect Light Strength;42;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1221;-3344.042,1630.113;Inherit;False;IndirectLightStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;692;-3165.281,1450.535;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1363;-3093.448,1301.393;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;642;-4031.403,1290.082;Inherit;False;364;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;581;-3893.515,1579.101;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;392;-4024.945,1014.83;Inherit;False;391;BNDiffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;276;-3657.158,1537.956;Inherit;False;World;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;229;-3467.616,1084.447;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1403;-5917.553,4967.904;Inherit;False;1388;SpecularColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1684;-7477.962,2177.758;Inherit;False;MaxFromVector3;-1;;213;92f2539b674dd3042b132cfbdf18809e;0;1;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;1794;-8096.626,455.5632;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightPos;226;-5792.314,-16.98151;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;1877;2108.999,1876.416;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;1878;2317.386,2023.4;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;1880;1943.385,1873.4;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;1882;2469.437,2069.176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1885;2740.221,1923.107;Inherit;False;Constant;_Float5;Float 5;113;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1886;3150.299,1920.284;Inherit;False;HeightMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;638;3141.832,2790.409;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;658;2989.125,2770.987;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1876;2839.745,2695.707;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;659;2763.419,2897.589;Inherit;False;Property;_Glossiness;Smoothness;36;0;Create;False;0;0;0;True;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1892;2617.529,2698.331;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1891;2370.094,2874.844;Inherit;False;1886;HeightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1653;3122.177,3484.125;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;204;2812.518,3040.777;Inherit;False;Property;_Color;Color;5;0;Create;True;0;0;0;False;0;False;0.6792453,0.6792453,0.6792453,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;3346.103,3474.748;Inherit;False;MainTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1655;2793.929,3640.516;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1656;2965.391,3617.135;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;1894;2607.909,3130.65;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1895;2601.474,3294.163;Inherit;False;1886;HeightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1652;2775.859,3802.197;Inherit;False;Property;_OcclusionStrength;Occlusion Strength ;105;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1902;2612.936,3620.457;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1903;2577.449,3758.139;Inherit;False;1886;HeightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;677;2870.581,4295.841;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;686;2881.469,4188.51;Inherit;False;Property;_UseEmission;UseEmission;41;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;685;3107.469,4244.508;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;680;3302.124,4250.198;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;679;2601.203,4323.245;Inherit;False;Property;_EmissionColor;Emission Color;38;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;1905;2611.989,4079.234;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1906;2576.503,4216.916;Inherit;False;1886;HeightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1908;2577.118,4699.015;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1909;2541.633,4836.697;Inherit;False;1886;HeightMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1540;2593.988,4528.899;Inherit;False;Constant;_Vector0;Vector 0;44;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;1536;2772.052,4646.21;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;1537;2941.718,4649.332;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;1538;3153.719,4648.332;Float;False;BNCurrentNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1539;2716.712,4783.467;Inherit;False;Property;_NormalMapStrength;Normal Map Strength;30;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1879;2005.385,2083.4;Inherit;False;Property;_PositionY;PositionY;0;0;Create;True;0;0;0;False;0;False;0.5;0;0.5;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;464;-3400.453,-2106.658;Inherit;False;Property;_UseRimLight;UseRim Light;1;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1881;2898.808,1920.985;Inherit;False;Property;_UseHeightMask;UseHeight Mask;2;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1883;2618.954,2019.194;Inherit;False;Property;_HeightMaskSwitch;HeightMaskSwitch;112;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1866;-2502.161,4071.143;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.SamplerNode;636;2252.559,2665.833;Inherit;True;Property;_SpecGlossMap;Specular Map;35;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1890;2251.832,2470.273;Inherit;True;Property;_SpecGlossMap1;Specular Map1;34;2;[NoScaleOffset];[SingleLineTexture];Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1893;2240.385,3035.099;Inherit;True;Property;_MainTex1;Albedo Texture1;8;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;362;2242.899,3235.46;Inherit;True;Property;_MainTex;Albedo Texture;9;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1901;2242.263,3518.884;Inherit;True;Property;_OcclusionMap1;Occlusion Map1;103;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1651;2243.19,3709.368;Inherit;True;Property;_OcclusionMap;Occlusion Map;104;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1904;2207.927,3961.492;Inherit;True;Property;_EmissionMap1;Emission Map1;40;3;[HDR];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;682;2205.726,4160.07;Inherit;True;Property;_EmissionMap;Emission Map;39;3;[HDR];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1541;2189.112,4740.373;Inherit;True;Property;_BumpMap;Normal Map;29;1;[Normal];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1907;2186.039,4522.173;Inherit;True;Property;_BumpMap1;Normal Map1;28;1;[Normal];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1910;2020.713,2679.591;Inherit;False;0;1651;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1669;2020.934,2475.988;Inherit;False;0;1901;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1911;2020.713,3043.591;Inherit;False;0;1901;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1897;2025.306,3245.184;Inherit;False;0;1651;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1898;2029.713,3712.631;Inherit;False;0;1651;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1912;2033.713,3521.591;Inherit;False;0;1901;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1899;1993.943,4161.348;Inherit;False;0;1651;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1913;1995.713,3964.591;Inherit;False;0;1901;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1900;1979.555,4741.177;Inherit;False;0;1651;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1914;1986.713,4525.591;Inherit;False;0;1901;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;1828;-8571.175,2851.528;Inherit;False;SRP Additional Light;-1;;214;6c86746ad131a0a408ca599df5f40861;7,6,0,9,0,23,0,27,0,25,0,24,0,26,0;6;2;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;15;FLOAT3;0,0,0;False;14;FLOAT3;1,1,1;False;18;FLOAT;0.5;False;32;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1182;-8092.509,2997.95;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;1154;-7808.552,2949.031;Inherit;False;1538;BNCurrentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;1181;-7504.824,2995.906;Inherit;False;float3 Color = 0@$$int numLights = GetAdditionalLightsCount()@$for(int i = 0@ i<numLights@i++)${$	$			#if VERSION_GREATER_EQUAL(10, 1)$			Light light = GetAdditionalLight(i, WorldPosition, shadowmask)@$			// see AdditionalLights_float for explanation of this$		#else$			Light light = GetAdditionalLight(i, WorldPosition)@$		#endif$$	$	float3 DotVector = dot(light.direction,WorldNormal)@$	$$	half3 AttLightColor = (light.shadowAttenuation * light.distanceAttenuation)@$	 float3 colout = max(float3(0.f,0.f,0.f),LightWrapVector + (1-LightWrapVector) * DotVector )*AttLightColor*light.color@ $	float maxColor = max(colout.r,max(colout.g,colout.b))@$	float3 outColor = smoothstep(SMin,SMax,maxColor)*light.color@$	 Color += outColor@$	//Color += smoothstep(float3(Faloff,Faloff,Faloff),float3(0.5f,0.5f,0.5f),colout)@$}$$return Color@;3;Create;7;True;WorldPosition;FLOAT3;0,0,0;In;;Float;False;True;WorldNormal;FLOAT3;0,0,0;In;;Float;False;True;LightWrapVector;FLOAT3;0,0,0;In;;Inherit;False;True;SMin;FLOAT;0;In;;Inherit;False;True;SMax;FLOAT;0;In;;Inherit;False;True;Faloff;FLOAT;0;In;;Inherit;False;True;shadowmask;FLOAT4;1,1,1,1;In;;Inherit;False;AdditionalLight;False;False;0;;False;7;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT4;1,1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1198;-7808.096,3062.013;Inherit;False;250;BNLightWarpVector;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1831;-7887.275,3147.631;Inherit;False; float2 lightmapUV@$    OUTPUT_LIGHTMAP_UV(LightmapUV, unity_LightmapST, lightmapUV)@$$return SAMPLE_SHADOWMASK(lightmapUV)@;4;Create;0;Shadowmask;True;False;0;;False;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1839;-7751.419,3142.674;Inherit;False;Shadowmask;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;1202;-8171.289,3364.518;Inherit;False;Property;_AdditionalLightsAmount;Additional Lights Size;74;0;Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1243;-7881.375,3573.093;Inherit;False;Property;_AdditionalLightsFaloff;Additional Lights Falloff;75;0;Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1258;-1192.877,1376.174;Inherit;False;Property;_UsePureSketch;Pure Sketch;77;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;671;134.7584,1074.747;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;670;-48.4021,1078.875;Inherit;False;364;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;1915;286.6831,1095.117;Inherit;False;Property;_UseAorR;UseAorR;113;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;674;423.075,1428.358;Inherit;False;Property;_Cutoff;Alpha Clip Threshold;37;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1916;505.3973,1174.909;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;704;0;712;0
WireConnection;704;1;702;1
WireConnection;1064;3;1069;0
WireConnection;1064;4;1070;0
WireConnection;1785;0;1784;0
WireConnection;1121;0;1119;0
WireConnection;1121;1;275;0
WireConnection;1121;2;1120;0
WireConnection;1121;3;1460;0
WireConnection;1293;0;1292;0
WireConnection;1462;0;1552;0
WireConnection;1462;1;1220;0
WireConnection;1462;2;1463;0
WireConnection;742;0;744;0
WireConnection;742;1;743;0
WireConnection;747;0;751;0
WireConnection;747;1;764;0
WireConnection;753;0;747;0
WireConnection;1279;0;1278;0
WireConnection;486;0;1849;0
WireConnection;486;1;1792;0
WireConnection;1647;0;456;0
WireConnection;1647;1;1644;0
WireConnection;1287;0;1297;0
WireConnection;732;1;739;0
WireConnection;732;0;731;0
WireConnection;766;0;767;0
WireConnection;763;0;749;0
WireConnection;763;1;766;0
WireConnection;1280;0;1279;0
WireConnection;764;0;745;0
WireConnection;764;1;766;0
WireConnection;1225;0;1234;0
WireConnection;1225;1;1222;0
WireConnection;1047;0;488;0
WireConnection;1047;1;1048;0
WireConnection;1047;2;1049;0
WireConnection;1351;0;508;1
WireConnection;1774;0;1785;0
WireConnection;1774;1;1225;0
WireConnection;1774;2;1783;0
WireConnection;1234;0;1462;0
WireConnection;1234;1;1235;0
WireConnection;1040;0;1041;0
WireConnection;715;0;705;0
WireConnection;1648;0;1644;0
WireConnection;1294;0;1295;0
WireConnection;1294;1;1296;0
WireConnection;726;0;716;0
WireConnection;726;1;727;0
WireConnection;1556;0;1555;0
WireConnection;1288;0;1287;0
WireConnection;1288;1;1294;0
WireConnection;749;0;748;0
WireConnection;749;1;741;1
WireConnection;1278;0;1285;0
WireConnection;1650;0;1645;0
WireConnection;1650;1;456;0
WireConnection;1650;2;1648;0
WireConnection;751;0;763;0
WireConnection;1216;0;1217;0
WireConnection;1216;1;1462;0
WireConnection;1216;2;1045;0
WireConnection;1277;0;1281;0
WireConnection;1277;2;1281;0
WireConnection;1851;0;1848;1
WireConnection;1851;1;1848;2
WireConnection;1022;0;1226;0
WireConnection;1270;0;1253;0
WireConnection;1270;1;1468;0
WireConnection;745;0;742;0
WireConnection;745;1;741;1
WireConnection;1642;0;1646;0
WireConnection;762;0;753;0
WireConnection;762;1;740;0
WireConnection;1803;0;1277;0
WireConnection;1803;1;1277;0
WireConnection;721;0;708;0
WireConnection;1045;0;531;0
WireConnection;1045;1;1040;0
WireConnection;1045;2;1043;0
WireConnection;718;0;756;0
WireConnection;718;1;755;0
WireConnection;460;0;464;0
WireConnection;1296;0;1293;0
WireConnection;1295;0;1293;0
WireConnection;1265;0;490;0
WireConnection;516;0;517;0
WireConnection;516;1;1351;0
WireConnection;498;0;492;0
WireConnection;498;1;499;0
WireConnection;1646;1;456;0
WireConnection;1646;0;1647;0
WireConnection;1646;2;1650;0
WireConnection;1281;0;1280;0
WireConnection;755;0;738;0
WireConnection;755;1;726;0
WireConnection;488;1;478;0
WireConnection;488;0;1282;0
WireConnection;705;0;704;0
WireConnection;705;1;719;0
WireConnection;1049;0;1050;0
WireConnection;1236;0;1216;0
WireConnection;462;0;454;0
WireConnection;462;1;467;0
WireConnection;491;0;1053;0
WireConnection;491;1;1064;0
WireConnection;491;2;481;0
WireConnection;491;3;482;0
WireConnection;491;4;498;0
WireConnection;491;5;503;0
WireConnection;716;0;715;0
WireConnection;1111;0;1066;0
WireConnection;466;0;463;0
WireConnection;737;0;753;0
WireConnection;737;1;740;0
WireConnection;528;0;526;0
WireConnection;528;1;527;0
WireConnection;467;0;466;0
WireConnection;1257;0;1254;0
WireConnection;1257;1;1795;0
WireConnection;1257;2;1256;0
WireConnection;1041;0;1046;0
WireConnection;738;0;462;0
WireConnection;731;0;718;0
WireConnection;731;1;757;0
WireConnection;757;0;758;0
WireConnection;757;1;759;0
WireConnection;1661;1;486;0
WireConnection;1069;0;1067;0
WireConnection;517;0;529;0
WireConnection;517;1;525;0
WireConnection;476;0;1053;0
WireConnection;476;1;1064;0
WireConnection;476;2;481;0
WireConnection;476;3;482;0
WireConnection;1043;0;1042;0
WireConnection;454;0;537;0
WireConnection;454;2;458;0
WireConnection;454;3;457;0
WireConnection;759;0;762;0
WireConnection;759;1;760;0
WireConnection;1782;0;1045;0
WireConnection;525;1;526;0
WireConnection;525;2;528;0
WireConnection;1070;0;1111;0
WireConnection;1226;0;1774;0
WireConnection;1226;1;1465;0
WireConnection;1784;0;1225;0
WireConnection;1784;1;1217;0
WireConnection;1784;2;1217;4
WireConnection;719;0;721;0
WireConnection;1254;0;1270;0
WireConnection;1254;1;1795;0
WireConnection;1254;2;1555;0
WireConnection;1856;0;1790;0
WireConnection;1856;1;1858;0
WireConnection;1783;0;1782;0
WireConnection;767;0;765;0
WireConnection;478;0;1056;0
WireConnection;478;1;1288;0
WireConnection;1850;0;1056;0
WireConnection;1850;1;1851;0
WireConnection;1025;0;1265;0
WireConnection;1042;0;1046;0
WireConnection;531;1;516;0
WireConnection;508;1;1055;0
WireConnection;1468;1;1467;0
WireConnection;1468;2;1469;0
WireConnection;1858;0;1855;1
WireConnection;1858;1;1855;2
WireConnection;1256;0;1253;4
WireConnection;1849;0;1850;0
WireConnection;1849;1;1056;0
WireConnection;1282;0;1661;0
WireConnection;1282;1;1803;0
WireConnection;1282;2;1288;0
WireConnection;1795;1;1789;0
WireConnection;1789;0;1791;0
WireConnection;1789;1;1857;0
WireConnection;1857;0;1856;0
WireConnection;1857;1;1790;0
WireConnection;1555;0;1026;0
WireConnection;1637;0;1258;0
WireConnection;1637;1;1643;0
WireConnection;1637;2;461;0
WireConnection;1264;0;530;0
WireConnection;1264;1;1270;0
WireConnection;1264;2;1253;4
WireConnection;1249;0;1637;0
WireConnection;1249;1;681;0
WireConnection;1636;0;530;0
WireConnection;282;0;1635;0
WireConnection;282;1;681;0
WireConnection;1260;0;1264;0
WireConnection;1260;1;530;0
WireConnection;1260;2;1556;0
WireConnection;1635;0;1636;0
WireConnection;1635;1;1643;0
WireConnection;1635;2;461;0
WireConnection;490;1;476;0
WireConnection;490;0;491;0
WireConnection;1867;2;1024;0
WireConnection;1867;3;1915;0
WireConnection;1867;4;674;0
WireConnection;1051;0;1047;0
WireConnection;1024;1;282;0
WireConnection;1024;0;282;0
WireConnection;1024;2;1249;0
WireConnection;1388;0;1376;0
WireConnection;1818;0;1812;0
WireConnection;1818;1;1812;0
WireConnection;1127;0;699;0
WireConnection;1125;0;1124;0
WireConnection;274;0;259;0
WireConnection;259;0;1231;0
WireConnection;259;1;694;0
WireConnection;259;2;1366;0
WireConnection;1819;0;1132;0
WireConnection;1819;1;1810;0
WireConnection;1124;0;1819;0
WireConnection;1124;1;1126;0
WireConnection;1124;2;1127;0
WireConnection;1812;1;1817;0
WireConnection;1812;0;1817;0
WireConnection;1812;2;1817;0
WireConnection;1269;0;1363;0
WireConnection;1466;0;692;0
WireConnection;263;0;229;0
WireConnection;263;1;1269;0
WireConnection;239;0;263;0
WireConnection;1807;0;1805;0
WireConnection;627;0;220;0
WireConnection;1241;0;1245;0
WireConnection;1400;0;406;1
WireConnection;1400;1;1404;0
WireConnection;1400;2;1578;0
WireConnection;1604;0;1599;0
WireConnection;1087;0;372;0
WireConnection;1087;1;1157;0
WireConnection;1561;0;441;1
WireConnection;1561;1;1557;0
WireConnection;1682;0;446;0
WireConnection;1412;1;1414;0
WireConnection;1531;0;1527;0
WireConnection;1531;1;1527;0
WireConnection;1132;1;1123;0
WireConnection;1132;0;1859;0
WireConnection;358;0;356;0
WireConnection;358;1;1274;0
WireConnection;358;2;1276;0
WireConnection;694;0;270;0
WireConnection;694;1;695;0
WireConnection;1102;1;1096;0
WireConnection;1486;0;1485;0
WireConnection;391;0;1087;0
WireConnection;1500;0;1501;0
WireConnection;1500;1;1505;0
WireConnection;1500;2;1508;0
WireConnection;1097;0;1573;0
WireConnection;1097;1;1098;0
WireConnection;1097;2;1104;0
WireConnection;1554;0;372;0
WireConnection;1231;1;271;0
WireConnection;1231;0;1232;0
WireConnection;1231;2;271;0
WireConnection;1470;1;1416;0
WireConnection;1470;0;1486;0
WireConnection;1144;0;1143;0
WireConnection;1622;1;1623;0
WireConnection;1680;0;361;0
WireConnection;1680;1;1618;0
WireConnection;1626;0;1451;0
WireConnection;1626;1;1619;0
WireConnection;1626;2;1470;0
WireConnection;227;0;247;1
WireConnection;227;1;1412;3
WireConnection;1489;0;1514;0
WireConnection;1489;1;1492;0
WireConnection;1489;2;1488;0
WireConnection;220;0;1579;0
WireConnection;220;1;903;0
WireConnection;220;2;1397;0
WireConnection;220;3;1403;0
WireConnection;1331;0;1355;0
WireConnection;1331;1;1330;0
WireConnection;1094;0;804;0
WireConnection;1094;1;1103;0
WireConnection;1841;0;439;0
WireConnection;1841;1;1843;0
WireConnection;1129;0;1842;0
WireConnection;1129;1;1793;0
WireConnection;1817;0;1816;0
WireConnection;1816;0;1815;0
WireConnection;1815;0;1814;0
WireConnection;1488;0;1496;0
WireConnection;1814;0;1813;0
WireConnection;1810;0;1811;0
WireConnection;1810;1;1808;0
WireConnection;1804;0;1807;0
WireConnection;233;0;234;0
WireConnection;248;0;249;0
WireConnection;1579;0;1097;0
WireConnection;1579;1;1400;0
WireConnection;1806;0;1807;0
WireConnection;267;0;389;0
WireConnection;267;1;251;0
WireConnection;1123;0;439;0
WireConnection;1143;0;1181;0
WireConnection;378;0;375;1
WireConnection;378;1;379;0
WireConnection;1681;1;446;0
WireConnection;1681;0;1682;0
WireConnection;1811;0;1809;0
WireConnection;250;0;384;0
WireConnection;1573;0;1577;0
WireConnection;1573;1;805;0
WireConnection;1573;2;1574;0
WireConnection;1573;3;1576;0
WireConnection;1573;4;1094;0
WireConnection;1573;5;588;0
WireConnection;1573;6;207;0
WireConnection;621;0;661;0
WireConnection;1808;0;1806;0
WireConnection;1808;1;1804;0
WireConnection;588;0;583;0
WireConnection;260;0;262;0
WireConnection;260;1;240;0
WireConnection;1355;0;1359;0
WireConnection;1355;1;1356;0
WireConnection;1330;0;1329;0
WireConnection;262;0;267;0
WireConnection;262;1;264;0
WireConnection;375;1;1489;0
WireConnection;1617;0;1622;0
WireConnection;1617;1;1680;0
WireConnection;1617;2;1470;0
WireConnection;653;0;660;0
WireConnection;653;1;651;0
WireConnection;653;2;1102;0
WireConnection;441;1;1213;0
WireConnection;1843;0;1840;1
WireConnection;1843;1;1840;2
WireConnection;1665;1;1129;0
WireConnection;1625;0;1360;0
WireConnection;1557;0;441;1
WireConnection;1557;1;1632;0
WireConnection;1557;2;1634;0
WireConnection;1501;0;1502;0
WireConnection;1501;1;1504;0
WireConnection;902;0;437;0
WireConnection;1628;0;1451;0
WireConnection;1628;1;1629;0
WireConnection;1628;2;1470;0
WireConnection;965;0;1683;0
WireConnection;1611;0;1605;0
WireConnection;372;1;1626;0
WireConnection;372;0;1617;0
WireConnection;372;2;1628;0
WireConnection;237;0;222;0
WireConnection;237;1;236;0
WireConnection;1523;0;1524;0
WireConnection;1362;0;1358;0
WireConnection;1530;0;1664;0
WireConnection;1530;1;1531;0
WireConnection;1530;2;1522;0
WireConnection;1498;1;1500;0
WireConnection;1498;0;1418;0
WireConnection;1683;1;1498;0
WireConnection;1099;0;1096;0
WireConnection;1519;0;1518;0
WireConnection;618;0;619;0
WireConnection;618;1;644;0
WireConnection;1359;0;1357;0
WireConnection;265;0;238;0
WireConnection;1360;0;444;0
WireConnection;1104;0;1093;0
WireConnection;356;0;360;0
WireConnection;1619;0;1451;0
WireConnection;1619;1;1618;0
WireConnection;1619;2;1625;0
WireConnection;1237;1;693;0
WireConnection;1237;0;1238;0
WireConnection;1237;2;693;0
WireConnection;1629;0;1451;0
WireConnection;1629;1;1618;0
WireConnection;1629;2;1331;0
WireConnection;243;0;627;0
WireConnection;650;0;653;0
WireConnection;650;1;649;0
WireConnection;652;0;650;0
WireConnection;252;0;254;0
WireConnection;252;1;256;0
WireConnection;1485;0;1416;0
WireConnection;1485;1;1483;0
WireConnection;1485;2;1510;0
WireConnection;384;0;382;0
WireConnection;384;2;378;0
WireConnection;244;0;227;0
WireConnection;1510;0;1509;0
WireConnection;1510;2;1511;0
WireConnection;1103;1;1093;0
WireConnection;1632;0;1634;0
WireConnection;1514;1;1495;0
WireConnection;1514;0;1530;0
WireConnection;222;0;226;1
WireConnection;1364;0;621;0
WireConnection;1511;0;1416;0
WireConnection;238;0;237;0
WireConnection;360;0;359;0
WireConnection;1520;0;1519;0
WireConnection;1520;1;1521;0
WireConnection;695;1;1797;0
WireConnection;695;2;696;0
WireConnection;1418;0;260;0
WireConnection;1418;1;1417;0
WireConnection;1521;0;1518;0
WireConnection;437;0;438;0
WireConnection;437;2;1681;0
WireConnection;444;1;445;0
WireConnection;444;2;371;0
WireConnection;361;1;358;0
WireConnection;234;0;1542;0
WireConnection;234;1;269;0
WireConnection;1668;0;1794;0
WireConnection;1668;1;1847;0
WireConnection;1522;0;1523;0
WireConnection;1522;1;1520;0
WireConnection;371;0;370;0
WireConnection;446;1;1561;0
WireConnection;446;2;440;0
WireConnection;1518;0;1517;0
WireConnection;1528;0;1526;0
WireConnection;1634;0;1631;0
WireConnection;665;0;652;0
WireConnection;1527;0;1528;0
WireConnection;1578;0;1100;0
WireConnection;1578;1;207;0
WireConnection;1578;2;588;0
WireConnection;1605;0;1604;0
WireConnection;1605;1;1600;0
WireConnection;1526;0;1525;0
WireConnection;445;0;371;0
WireConnection;1357;1;1362;0
WireConnection;246;0;252;0
WireConnection;251;0;248;0
WireConnection;251;1;223;0
WireConnection;661;0;618;0
WireConnection;661;1;623;0
WireConnection;661;2;644;0
WireConnection;1525;0;1529;0
WireConnection;1100;0;401;0
WireConnection;1100;1;1099;0
WireConnection;1664;1;1668;0
WireConnection;1495;0;381;0
WireConnection;1495;1;1522;0
WireConnection;1415;0;1854;0
WireConnection;401;0;246;0
WireConnection;401;1;665;0
WireConnection;1797;0;1237;0
WireConnection;1247;0;1562;0
WireConnection;1203;0;1247;0
WireConnection;1842;0;1841;0
WireConnection;1842;1;439;0
WireConnection;1245;0;1203;0
WireConnection;1245;1;1243;0
WireConnection;1854;1;1852;0
WireConnection;1854;2;1412;4
WireConnection;1854;3;1853;0
WireConnection;1847;0;1846;0
WireConnection;1847;1;381;0
WireConnection;1859;0;1665;0
WireConnection;1859;1;1818;0
WireConnection;1562;0;1202;0
WireConnection;1845;0;1844;1
WireConnection;1845;1;1844;2
WireConnection;1846;0;381;0
WireConnection;1846;1;1845;0
WireConnection;1266;1;392;0
WireConnection;1266;0;392;0
WireConnection;1266;2;392;0
WireConnection;1221;0;691;0
WireConnection;692;1;276;0
WireConnection;692;2;1221;0
WireConnection;1363;0;642;0
WireConnection;1363;1;692;0
WireConnection;276;0;581;0
WireConnection;229;0;1266;0
WireConnection;229;1;642;0
WireConnection;1877;0;1880;0
WireConnection;1878;0;1877;2
WireConnection;1878;1;1879;0
WireConnection;1882;0;1878;0
WireConnection;1886;0;1881;0
WireConnection;638;0;658;0
WireConnection;658;0;1876;0
WireConnection;658;1;659;0
WireConnection;1876;0;1892;0
WireConnection;1892;0;1890;1
WireConnection;1892;1;636;1
WireConnection;1892;2;1891;0
WireConnection;1653;0;204;0
WireConnection;1653;1;1894;0
WireConnection;1653;2;1656;0
WireConnection;364;0;1653;0
WireConnection;1655;1;1902;0
WireConnection;1655;2;1652;0
WireConnection;1656;0;1655;0
WireConnection;1656;1;1655;0
WireConnection;1656;2;1655;0
WireConnection;1894;0;1893;0
WireConnection;1894;1;362;0
WireConnection;1894;2;1895;0
WireConnection;1902;0;1901;1
WireConnection;1902;1;1651;1
WireConnection;1902;2;1903;0
WireConnection;677;0;1905;0
WireConnection;677;1;679;0
WireConnection;685;0;686;0
WireConnection;685;2;677;0
WireConnection;680;0;685;0
WireConnection;1905;0;1904;0
WireConnection;1905;1;682;0
WireConnection;1905;2;1906;0
WireConnection;1908;0;1907;0
WireConnection;1908;1;1541;0
WireConnection;1908;2;1909;0
WireConnection;1536;0;1540;0
WireConnection;1536;1;1908;0
WireConnection;1536;2;1539;0
WireConnection;1537;0;1536;0
WireConnection;1538;0;1537;0
WireConnection;464;0;732;0
WireConnection;1881;1;1885;0
WireConnection;1881;0;1883;0
WireConnection;1883;1;1878;0
WireConnection;1883;0;1882;0
WireConnection;636;1;1910;0
WireConnection;1890;1;1669;0
WireConnection;1893;1;1911;0
WireConnection;362;1;1897;0
WireConnection;1901;1;1912;0
WireConnection;1651;1;1898;0
WireConnection;1904;1;1913;0
WireConnection;682;1;1899;0
WireConnection;1541;1;1900;0
WireConnection;1907;1;1914;0
WireConnection;1181;0;1182;0
WireConnection;1181;1;1154;0
WireConnection;1181;2;1198;0
WireConnection;1181;3;1241;0
WireConnection;1181;4;1203;0
WireConnection;1839;0;1831;0
WireConnection;1258;1;1260;0
WireConnection;1258;0;1257;0
WireConnection;671;0;670;0
WireConnection;1915;1;671;0
WireConnection;1915;0;671;3
WireConnection;1916;0;1915;0
ASEEND*/
//CHKSM=79F280E8AB33654503B6DEF66AAB5BD83747D969