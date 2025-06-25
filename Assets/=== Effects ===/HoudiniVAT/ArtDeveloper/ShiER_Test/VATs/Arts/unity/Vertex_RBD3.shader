Shader "ALab/Vertex_RBD3"
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
    	_OccolusionMul("OccolusionMul", Range(0, 1)) = 0
    	
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
        
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
		LOD 0
		
		Tags
		{
			"RenderPipeline"="UniversalPipeline"
			"RenderType"="Opaque"
			"Queue"="Geometry"
			"UniversalMaterialType"="Lit"
		}

		Cull Back
		ZWrite On
		ZTest LEqual
		Offset 0,0
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 4.0
		#pragma prefer_hlslcc gles
		#pragma only_renderers metal // ensure rendering platforms toggle list is visible
		#pragma only_renderers d3d11 metal // ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

        void Decode_Quaternion_float(float3 XYZ, float MaxComponent, out float4 Out_XYZW){
            float w = sqrt(1.0 - pow(XYZ.x, 2) - pow(XYZ.y, 2) - pow(XYZ.z, 2));
            float4 q = float4(0, 0, 0, 1);
            switch(MaxComponent){
                case 0:
                    q = float4(XYZ.x, XYZ.y, XYZ.z, w);
                    break;
                case 1:
                    q = float4(w, XYZ.y, XYZ.z, XYZ.x);
                    break;
                case 2:
                    q = float4(XYZ.x, -w, XYZ.z, -XYZ.y);
                    break;
                case 3:
                    q = float4(XYZ.x, XYZ.y, -w, -XYZ.z);
                    break;
                default:
                    q = float4(XYZ.x, XYZ.y, XYZ.z, w);
                    break;
            }
            Out_XYZW = q;
        }
        
        void RotateByQuaternionV4V3_float(float4 Quaternion, float3 Pivot, out float3 outXYZ){
            outXYZ = float3(0,0,0);
            outXYZ = Pivot + 2.0 * cross(Quaternion.xyz, cross(Quaternion.xyz, Pivot) + Pivot * Quaternion.w);
        }
		
		ENDHLSL

        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
            // Render State
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
        
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma multi_compile_fragment _ALPHATEST_ON
			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#define ASE_VERSION 19801
			#define ASE_SRP_VERSION 170003
            
            #pragma vertex vert
            #pragma fragment frag
            
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

            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1

            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
                #define _FOG_FRAGMENT 1
            
            // Includes
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
            // #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
        
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                float4 uv3 : TEXCOORD3;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct PackedVaryings
			{
            	float4 positionCS : SV_POSITION;
            	
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				float4 normalOS : TEXCOORD2;
				float4 tangentOS : TEXCOORD3;
				float4 bittangentOS : TEXCOORD4;
				float4 shadowCoord : TEXCOORD5;
				float2 dynamicLightmapUV : TEXCOORD6;
				float4 probeOcclusion : TEXCOORD7;
				float4 uv0 : TEXCOORD8;
            	float3 positionOS : TEXCOORD9;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
            
        
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _B_autoPlayback;
                float _displayFrame;
                float4 _posTexture_TexelSize;
                float4 _rotTexture_TexelSize;
                float _playbackSpeed;
                float _frameCount;
                float _boundMaxX;
                float _boundMaxY;
                float _boundMaxZ;
                float _boundMinX;
                float _boundMinY;
                float _boundMinZ;
                float _NormalLerp;
				float _OccolusionMul;
                float4 _BaseColor_Tex_TexelSize;
                float2 _Tiling;
                float2 _Offset;
                float4 _ARM_Tex_TexelSize;
                float4 _Normal_Tex_TexelSize;
                // UNITY_TEXTURE_STREAMING_DEBUG_VARS;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_posTexture);
            SAMPLER(sampler_posTexture);
            TEXTURE2D(_rotTexture);
            SAMPLER(sampler_rotTexture);
            TEXTURE2D(_BaseColor_Tex);
            SAMPLER(sampler_BaseColor_Tex);
            TEXTURE2D(_ARM_Tex);
            SAMPLER(sampler_ARM_Tex);
            TEXTURE2D(_Normal_Tex);
            SAMPLER(sampler_Normal_Tex);
            
            
            // -------------------------- vert ----------------------------------
			PackedVaryings vert ( Attributes input )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				output.uv0 = input.uv0;
            	
            	// ------------------------------- vat cal ----------------------------------------
                UnityTexture2D posTexture = UnityBuildTexture2DStructNoScale(_posTexture);
                float3 temp_minV3 = float3(_boundMinX, _boundMinY, _boundMinZ);
                float temp_onem = 1 - (ceil(float3(10,10,10) * temp_minV3) - float3(10,10,10) * temp_minV3);
                float temp_mul_07 = input.uv1[1] * (1 - (_boundMaxX * -10 - floor(_boundMaxX * -10)));
                float temp_branch_13 = _B_autoPlayback ? frac(_playbackSpeed * _TimeParameters.x) * _frameCount : floor(_displayFrame);
                float temp_mul_15 = (1 - (_boundMaxX * -10 - floor(_boundMaxX * -10))) * 1.0f / 120.0f * temp_branch_13; // 120是纹理的帧数
                float temp_onem_17 = 1 - (temp_mul_07 + temp_mul_15);
                float2 temp_v2 = float2(input.uv1[0] * temp_onem, temp_onem_17);
                float4 posTexLod = SAMPLE_TEXTURE2D_LOD(posTexture.tex, posTexture.samplerstate, posTexture.GetTransformedUV(temp_v2), float(0));
                float3 combineV3_18 = float3(posTexLod.r, posTexLod.g, posTexLod.b);
                
                UnityTexture2D rotTex = UnityBuildTexture2DStructNoScale(_rotTexture);
                float4 rotTexColor = SAMPLE_TEXTURE2D_LOD(rotTex.tex, rotTex.samplerstate, rotTex.GetTransformedUV(temp_v2), float(0));
                float4 outputDecodeV4;
                Decode_Quaternion_float(rotTexColor.xyz, rotTexColor.a, outputDecodeV4);

                float inUV2_X = input.uv2[0];
                inUV2_X *= -1;
                float4 in_UV_3 = input.uv3;
                float _OneMinus_in_uv_3 = 1 - in_UV_3[1];
                float3 v3 = float3(inUV2_X, in_UV_3[0], _OneMinus_in_uv_3);
                float3 subV3 = input.positionOS - v3;
            	
                float3 rotateV3;
                RotateByQuaternionV4V3_float(outputDecodeV4, subV3, rotateV3);
                float3 addV3 = combineV3_18 + rotateV3;
            	
                float3 rotateV3_4;
                RotateByQuaternionV4V3_float(outputDecodeV4, input.normalOS, rotateV3_4);
                rotateV3_4 = normalize(rotateV3_4);
                
                float3 rotateV3_5;
                RotateByQuaternionV4V3_float(outputDecodeV4, input.tangentOS, rotateV3_5);
                rotateV3_5 = normalize(rotateV3_5);
                
                // Position = addV3;
                // Normal = rotateV3_4;
                // Tangent = rotateV3_5;

            	output.positionOS = addV3;
				output.normalOS = float4( rotateV3_4, 0 );
				output.tangentOS = float4( rotateV3_5, 0 );
				output.bittangentOS = float4(normalize(cross(output.normalOS, output.tangentOS)), 0 );
            	
				output.positionCS = TransformObjectToHClip(output.positionOS);
				output.clipPosV = TransformObjectToHClip(output.positionOS);
            	
				OUTPUT_SH( TransformObjectToWorld(output.normalOS).xyz, output.lightmapUVOrVertexSH.xyz);
				OUTPUT_SH4(
					TransformObjectToWorld(output.positionOS),
					TransformObjectToWorld(output.normalOS).xyz,
					GetWorldSpaceNormalizeViewDir( TransformObjectToWorld(output.positionOS) ),
					output.lightmapUVOrVertexSH.xyz,
					output.probeOcclusion
				);
				return output;
			}

			// -------------------------- frag ----------------------------------
			half4 frag ( PackedVaryings input ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				// ------------------------- 归一化TBN 在多个顶点运动的时候提高性能 -----------------------------
				float3 unnormalizedNormalWS = TransformObjectToWorldDir(input.normalOS);
				const float renormFactor = 1.0 / length(unnormalizedNormalWS);
				float3 normalWS_N = renormFactor * TransformObjectToWorldDir(input.normalOS).xyz;
				float3 normalOS_N = normalize(mul(normalWS_N, (float3x3) UNITY_MATRIX_M));
				float3 tangentWS_N = renormFactor * TransformObjectToWorldDir(input.tangentOS).xyz;
				float3 tangentOS_N = TransformWorldToObjectDir(tangentWS_N);
				
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = input.clipPosV;
				float4 ScreenPos = ComputeScreenPos( input.clipPosV );

				// ------------------------- 预计算 -----------------------------
				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = input.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( TransformObjectToWorld(input.positionOS) );
				#endif

				UnityTexture2D baseColorTex = UnityBuildTexture2DStructNoScale(_BaseColor_Tex);
                UnityTexture2D normalTex = UnityBuildTexture2DStructNoScale(_Normal_Tex); 
				float2 _TilingAndOffset = input.uv0.xy * _Tiling + _Offset;
                float4 baseColorTexColor = SAMPLE_TEXTURE2D(baseColorTex.tex, baseColorTex.samplerstate, baseColorTex.GetTransformedUV(_TilingAndOffset) );
                float4 normalTexColor = SAMPLE_TEXTURE2D(normalTex.tex, normalTex.samplerstate, normalTex.GetTransformedUV(_TilingAndOffset) );
                normalTexColor.rgb = UnpackNormal(normalTexColor);
				
				float3 mul = normalOS_N * normalTexColor[2].xxx;
                float3 mul_02 = tangentOS_N * normalTexColor[0].xxx;
                float3 _Add_V3_00 = mul + mul_02;
                float3 _CrossProduct = cross(tangentOS_N, normalOS_N);
				
				float3 bitangentOS_N = normalize( cross( tangentOS_N, normalOS_N ) );
				float3 bitangentWS_N = normalize( TransformObjectToWorld( bitangentOS_N ) );

                float3 mul_03 = _CrossProduct * normalTexColor[1].xxx;
                float3 addNormal = _Add_V3_00 + mul_03;
                addNormal = lerp(float3(0,0,1), addNormal, _NormalLerp);

				// OS
                float3 normal_Normalize = normalize(addNormal);

                UnityTexture2D ARMTex = UnityBuildTexture2DStructNoScale(_ARM_Tex);
                
                float4 ARMTexColor = SAMPLE_TEXTURE2D(ARMTex.tex, ARMTex.samplerstate, ARMTex.GetTransformedUV(_TilingAndOffset));
                float AOColor = ARMTexColor.r;
                float tex_float = ARMTexColor.g;
                float onem = 1 - tex_float;
				
				float3 BaseColor =	baseColorTexColor;
				float3 NormalTS =	TransformObjectToTangent(normal_Normalize, half3x3(tangentWS_N, bitangentWS_N, normalWS_N));	// normal_Normalize;
									// TransformTangentToObject(normal_Normalize, half3x3(tangentOS_N, bitangentOS_N, normalOS_N));
				float3 Emission =	0;
				float3 Specular =	0.5;
				// 
				float Metallic = ARMTexColor.b;
				float Smoothness = onem;
				float Occlusion = AOColor;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				
				// return half4 (NormalTS, 1);		// normal_Normalize 是对的

				// ---------------------- inputData ----------------------
				InputData inputData = (InputData)0;
				inputData.positionWS = TransformObjectToWorld(input.positionOS);
				inputData.positionCS = input.positionCS;
				inputData.normalWS = TransformTangentToWorld(NormalTS, half3x3(tangentWS_N, bitangentWS_N, normalWS_N));
				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					inputData.shadowCoord = ShadowCoords;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				#else
					inputData.shadowCoord = float4(0, 0, 0, 0);
				#endif
				float3 SH = input.lightmapUVOrVertexSH.xyz;
				inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, SH, normalWS_N);
				inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);
				inputData.viewDirectionWS = normalize(_WorldSpaceCameraPos - TransformObjectToWorld(input.positionOS));

				// SamplerState mySampler : register(s0);

				SurfaceData surfaceData;
				surfaceData.albedo              = BaseColor;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness);
				surfaceData.occlusion           = Occlusion * _OccolusionMul; // Remap(0,100,Occlusion,0.1,0.5)
				surfaceData.emission            = Emission;
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = NormalTS;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;
				
				
				half4 color = UniversalFragmentPBR( inputData, surfaceData );

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

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                float4 uv3 : TEXCOORD3;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif
				float3 positionOS : TEXCOORD3;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _B_autoPlayback;
                float _displayFrame;
                float4 _posTexture_TexelSize;
                float4 _rotTexture_TexelSize;
                float _playbackSpeed;
                float _frameCount;
                float _boundMaxX;
                float _boundMaxY;
                float _boundMaxZ;
                float _boundMinX;
                float _boundMinY;
                float _boundMinZ;
                float _NormalLerp;
                float4 _BaseColor_Tex_TexelSize;
                float2 _Tiling;
                float2 _Offset;
                float4 _ARM_Tex_TexelSize;
                float4 _Normal_Tex_TexelSize;
                // UNITY_TEXTURE_STREAMING_DEBUG_VARS;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_posTexture);
            SAMPLER(sampler_posTexture);
            TEXTURE2D(_rotTexture);
            SAMPLER(sampler_rotTexture);
            TEXTURE2D(_BaseColor_Tex);
            SAMPLER(sampler_BaseColor_Tex);
            TEXTURE2D(_ARM_Tex);
            SAMPLER(sampler_ARM_Tex);
            TEXTURE2D(_Normal_Tex);
            SAMPLER(sampler_Normal_Tex);
			
			float3 _LightDirection;
			float3 _LightPosition;

            // -------------------------- vert ----------------------------------
			PackedVaryings vert ( Attributes input )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
            	
            	// ------------------------------- vat cal ----------------------------------------
                UnityTexture2D posTexture = UnityBuildTexture2DStructNoScale(_posTexture);
                float3 temp_minV3 = float3(_boundMinX, _boundMinY, _boundMinZ);
                float temp_onem = 1 - (ceil(float3(10,10,10) * temp_minV3) - float3(10,10,10) * temp_minV3);
                float temp_mul_07 = input.uv1[1] * (1 - (_boundMaxX * -10 - floor(_boundMaxX * -10)));
                float temp_branch_13 = _B_autoPlayback ? frac(_playbackSpeed * _TimeParameters.x) * _frameCount : floor(_displayFrame);
                float temp_mul_15 = (1 - (_boundMaxX * -10 - floor(_boundMaxX * -10))) * 1.0f / 120.0f * temp_branch_13; // 120是纹理的帧数
                float temp_onem_17 = 1 - (temp_mul_07 + temp_mul_15);
                float2 temp_v2 = float2(input.uv1[0] * temp_onem, temp_onem_17);
                float4 posTexLod = SAMPLE_TEXTURE2D_LOD(posTexture.tex, posTexture.samplerstate, posTexture.GetTransformedUV(temp_v2), float(0));
                float3 combineV3_18 = float3(posTexLod.r, posTexLod.g, posTexLod.b);
                
                UnityTexture2D rotTex = UnityBuildTexture2DStructNoScale(_rotTexture);
                float4 rotTexColor = SAMPLE_TEXTURE2D_LOD(rotTex.tex, rotTex.samplerstate, rotTex.GetTransformedUV(temp_v2), float(0));
                float4 outputDecodeV4;
                Decode_Quaternion_float(rotTexColor.xyz, rotTexColor.a, outputDecodeV4);

                float inUV2_X = input.uv2[0];
                inUV2_X *= -1;
                float4 in_UV_3 = input.uv3;
                float _OneMinus_in_uv_3 = 1 - in_UV_3[1];
                float3 v3 = float3(inUV2_X, in_UV_3[0], _OneMinus_in_uv_3);
                float3 subV3 = input.positionOS - v3;
            	
                float3 rotateV3;
                RotateByQuaternionV4V3_float(outputDecodeV4, subV3, rotateV3);
                float3 addV3 = combineV3_18 + rotateV3;
                
                // Position = addV3;
                // Normal = rotateV3_4;
                // Tangent = rotateV3_5;

            	output.positionOS = addV3;
				output.positionWS = TransformObjectToWorld(output.positionOS);
				output.positionCS = TransformObjectToHClip(output.positionOS);
				output.clipPosV = TransformObjectToHClip(output.positionOS);
				
				return output;
			}

			// -------------------------- frag ---------------------------------
			half4 frag(	PackedVaryings input ) : SV_Target
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

				return 0;
			}
			ENDHLSL
		}
        
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}