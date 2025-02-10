Shader "ALab/Vertex_RBD2"
    {
        Properties
        {
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
            
            [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
            [HideInInspector]_QueueControl("_QueueControl", Float) = -1
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"
                "UniversalMaterialType" = "Lit"
                "Queue"="Geometry"
                "DisableBatching"="False"
                // "ShaderGraphShader"="true"
                // "ShaderGraphTargetId"="UniversalLitSubTarget"
            }
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
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.0
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma vertex vert
            #pragma fragment frag
            
            // Keywords
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _FORWARD_PLUS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_OS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define ATTRIBUTES_NEED_TEXCOORD3
            #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SHADOW_COORD
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
                #define _FOG_FRAGMENT 1
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
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
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
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
        
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 tangentWS;
                 float4 texCoord0;
                #if defined(LIGHTMAP_ON)
                 float2 staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                 float2 dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                 float3 sh;
                #endif
                #if defined(USE_APV_PROBE_OCCLUSION)
                 float4 probeOcclusion;
                #endif
                 float4 fogFactorAndVertexLight;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                 float4 shadowCoord;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            struct SurfaceDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 WorldSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 WorldSpaceTangent;
                 float4 uv0;
            };
        
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
                 float4 uv1;
                 float4 uv2;
                 float4 uv3;
                 float3 TimeParameters;
            };
        
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if defined(USE_APV_PROBE_OCCLUSION)
                    float4 probeOcclusion : INTERP3;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord : INTERP4;
                #endif
                float4 tangentWS : INTERP5;
                float4 texCoord0 : INTERP6;
                float4 fogFactorAndVertexLight : INTERP7;
                float3 positionWS : INTERP8;
                float3 normalWS : INTERP9;
                #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
            };

            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if defined(USE_APV_PROBE_OCCLUSION)
                    output.probeOcclusion = input.probeOcclusion;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                #endif
                output.tangentWS.xyzw = input.tangentWS;
                output.texCoord0.xyzw = input.texCoord0;
                output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                output.positionWS.xyz = input.positionWS;
                output.normalWS.xyz = input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }

            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if defined(USE_APV_PROBE_OCCLUSION)
                    output.probeOcclusion = input.probeOcclusion;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                #endif
                output.tangentWS = input.tangentWS.xyzw;
                output.texCoord0 = input.texCoord0.xyzw;
                output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                output.positionWS = input.positionWS.xyz;
                output.normalWS = input.normalWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }

                
            
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
            
            // Graph Functions
                
            // unity-custom-func-begin
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
            // unity-custom-func-end
            
            void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A - B;
            }
            
            // unity-custom-func-begin
            void RotateByQuaternionV4V3_float(float4 Quaternion, float3 Pivot, out float3 outXYZ){
                outXYZ = float3(0,0,0);
                outXYZ = Pivot + 2.0 * cross(Quaternion.xyz, cross(Quaternion.xyz, Pivot) + Pivot * Quaternion.w);
            }
            // unity-custom-func-end
            
            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }
            
            void Unity_Normalize_float3(float3 In, out float3 Out)
            {
                Out = normalize(In);
            }
            
            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }
            
            void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
            {
                Out = cross(A, B);
            }
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
                
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                UnityTexture2D posTexture = UnityBuildTexture2DStructNoScale(_posTexture);
                
                float3 temp_minV3 = float3(_boundMinX, _boundMinY, _boundMinZ);
                
                float temp_onem = 1 - (ceil(float3(10,10,10) * temp_minV3) - float3(10,10,10) * temp_minV3);
                
                float temp_mul_07 = IN.uv1[1] * (1 - (_boundMaxX * -10 - floor(_boundMaxX * -10)));

                float temp_branch_13 = _B_autoPlayback ? frac(_playbackSpeed * IN.TimeParameters.x) * _frameCount : floor(_displayFrame);
                float temp_mul_15 = (1 - (_boundMaxX * -10 - floor(_boundMaxX * -10))) * 1.0f / 120.0f * temp_branch_13; // 120是纹理的帧数
                float temp_onem_17 = 1 - (temp_mul_07 + temp_mul_15);
                float2 temp_v2 = float2(IN.uv1[0] * temp_onem, temp_onem_17);
                
                float4 posTexLod = SAMPLE_TEXTURE2D_LOD(posTexture.tex, posTexture.samplerstate, posTexture.GetTransformedUV(temp_v2), float(0));

                float3 combineV3_18 = float3(posTexLod.r, posTexLod.g, posTexLod.b);
                
                UnityTexture2D rotTex = UnityBuildTexture2DStructNoScale(_rotTexture);
                float4 rotTexColor = SAMPLE_TEXTURE2D_LOD(rotTex.tex, rotTex.samplerstate, rotTex.GetTransformedUV(temp_v2), float(0));
                float4 outputDecodeV4;
                Decode_Quaternion_float(rotTexColor.xyz, rotTexColor.a, outputDecodeV4);

                float inUV2_X = IN.uv2[0];
                inUV2_X *= -1;
                
                float4 in_UV_3 = IN.uv3;
                float _OneMinus_in_uv_3 = 1 - in_UV_3[1];
                
                float3 v3 = float3(inUV2_X, in_UV_3[0], _OneMinus_in_uv_3);

                float3 subV3 = IN.ObjectSpacePosition - v3;
                float3 rotateV3;
                RotateByQuaternionV4V3_float(outputDecodeV4, subV3, rotateV3);
                float3 addV3 = combineV3_18 + rotateV3;

                float3 rotateV3_4;
                RotateByQuaternionV4V3_float(outputDecodeV4, IN.ObjectSpaceNormal, rotateV3_4);
                rotateV3_4 = normalize(rotateV3_4);
                
                float3 rotateV3_5;
                RotateByQuaternionV4V3_float(outputDecodeV4, IN.ObjectSpaceTangent, rotateV3_5);
                rotateV3_5 = normalize(rotateV3_5);
                
                description.Position = addV3;
                description.Normal = rotateV3_4;
                description.Tangent = rotateV3_5;
                return description;
            }
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalOS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
            };
                
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D baseColorTex = UnityBuildTexture2DStructNoScale(_BaseColor_Tex);
                UnityTexture2D normalTex = UnityBuildTexture2DStructNoScale(_Normal_Tex);
                
                float2 _TilingAndOffset = IN.uv0.xy * _Tiling + _Offset;
                float4 baseColorTexColor = SAMPLE_TEXTURE2D(baseColorTex.tex, baseColorTex.samplerstate, baseColorTex.GetTransformedUV(_TilingAndOffset) );
                float4 normalTexColor = SAMPLE_TEXTURE2D(normalTex.tex, normalTex.samplerstate, normalTex.GetTransformedUV(_TilingAndOffset) );
                normalTexColor.rgb = UnpackNormal(normalTexColor);
                
                float3 mul = IN.ObjectSpaceNormal * normalTexColor[2].xxx;
                float3 mul_02 = IN.ObjectSpaceTangent * normalTexColor[0].xxx;
                float3 _Add_V3_00 = mul + mul_02;
                float3 _CrossProduct = cross(IN.ObjectSpaceTangent, IN.ObjectSpaceNormal);
                float3 mul_03 = _CrossProduct * normalTexColor[1].xxx;
                float3 addNormal = _Add_V3_00 + mul_03;
                addNormal = lerp(float3(0,0,1), addNormal, _NormalLerp);
                float3 normal_Normalize = normalize(addNormal);

                UnityTexture2D ARMTex = UnityBuildTexture2DStructNoScale(_ARM_Tex);
                
                float4 ARMTexColor = SAMPLE_TEXTURE2D(ARMTex.tex, ARMTex.samplerstate, ARMTex.GetTransformedUV(_TilingAndOffset));
                float AOColor = ARMTexColor.r;
                float tex_float = ARMTexColor.g;
                float Metallic = ARMTexColor.b;
                float onem = 1 - tex_float;
                
                // surface.BaseColor   =     IN.ObjectSpaceNormal;     // (baseColorTexColor.xyz);
                // surface.NormalOS    =     IN.ObjectSpaceNormal;         // normal_Normalize;
                // surface.Emission    =     float3(0, 0, 0);
                // surface.Metallic    =     0.5f;     // Metallic;
                // surface.Smoothness  =     0.5f;     // onem;
                // surface.Occlusion   =     0.5f;     // AOColor;

                surface.BaseColor   =     (baseColorTexColor.xyz);
                surface.NormalOS    =     normal_Normalize;
                surface.Emission    =     float3(0, 0, 0);
                surface.Metallic    =     Metallic;
                surface.Smoothness  =     onem;
                surface.Occlusion   =     AOColor;
                return surface;
            }
            
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
                output.uv1 =                                        input.uv1;
                output.uv2 =                                        input.uv2;
                output.uv3 =                                        input.uv3;
                output.TimeParameters =                             _TimeParameters.xyz;
            
                return output;
            }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);
            
            
                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;
                output.ObjectSpaceNormal = normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));
                
                output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
                output.ObjectSpaceTangent = TransformWorldToObjectDir(output.WorldSpaceTangent);
                output.uv0 = input.texCoord0;
                
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                return output;
            }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
            
            ENDHLSL
            }

            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
                ColorMask 0
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_OS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define ATTRIBUTES_NEED_TEXCOORD3
            #define GRAPH_VERTEX_USES_TIME_PARAMETERS_INPUT
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
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
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                     float4 uv3 : TEXCOORD3;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float4 uv1;
                     float4 uv2;
                     float4 uv3;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS : INTERP0;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
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
                float4 _BaseColor_Tex_TexelSize;
                float2 _Tiling;
                float2 _Offset;
                float4 _ARM_Tex_TexelSize;
                float4 _Normal_Tex_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
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
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                {
                    RGBA = float4(R, G, B, A);
                    RGB = float3(R, G, B);
                    RG = float2(R, G);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Ceiling_float(float In, out float Out)
                {
                    Out = ceil(In);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Floor_float(float In, out float Out)
                {
                    Out = floor(In);
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_Fraction_float(float In, out float Out)
                {
                    Out = frac(In);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                // unity-custom-func-begin
                void Decode_Quaternion_float(float3 XYZ, float MaxComponent, out float4 Out_XYZW){
                    float w = sqrt(1.0 - pow(XYZ.x, 2) - pow(XYZ.y, 2) - pow(XYZ.z, 2));
                    
                    float4 q = float4(0, 0, 0, 1);
                    
                    
                    
                    switch(MaxComponent)
                    
                    {
                    
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
                // unity-custom-func-end
                
                void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A - B;
                }
                
                // unity-custom-func-begin
                void RotateByQuaternionV4V3_float(float4 Quaternion, float3 Pivot, out float3 outXYZ){
                    outXYZ = float3(0,0,0);
                    outXYZ = Pivot + 2.0 * cross(Quaternion.xyz, cross(Quaternion.xyz, Pivot) + Pivot * Quaternion.w);
                }
                // unity-custom-func-end
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                UnityTexture2D posTexture = UnityBuildTexture2DStructNoScale(_posTexture);
                
                float3 temp_minV3 = float3(_boundMinX, _boundMinY, _boundMinZ);
                
                float temp_onem = 1 - (ceil(float3(10,10,10) * temp_minV3) - float3(10,10,10) * temp_minV3);
                
                float temp_mul_07 = IN.uv1[1] * (1 - (_boundMaxX * -10 - floor(_boundMaxX * -10)));

                float temp_branch_13 = _B_autoPlayback ? frac(_playbackSpeed * IN.TimeParameters.x) * _frameCount : floor(_displayFrame);
                float temp_mul_15 = (1 - (_boundMaxX * -10 - floor(_boundMaxX * -10))) * 1.0f / 120.0f * temp_branch_13; // 120是纹理的帧数
                float temp_onem_17 = 1 - (temp_mul_07 + temp_mul_15);
                float2 temp_v2 = float2(IN.uv1[0] * temp_onem, temp_onem_17);
                
                float4 posTexLod = SAMPLE_TEXTURE2D_LOD(posTexture.tex, posTexture.samplerstate, posTexture.GetTransformedUV(temp_v2), float(0));

                float3 combineV3_18 = float3(posTexLod.r, posTexLod.g, posTexLod.b);
                
                UnityTexture2D rotTex = UnityBuildTexture2DStructNoScale(_rotTexture);
                float4 rotTexColor = SAMPLE_TEXTURE2D_LOD(rotTex.tex, rotTex.samplerstate, rotTex.GetTransformedUV(temp_v2), float(0));
                float4 outputDecodeV4;
                Decode_Quaternion_float(rotTexColor.xyz, rotTexColor.a, outputDecodeV4);

                float inUV2_X = IN.uv2[0];
                inUV2_X *= -1;
                
                float4 in_UV_3 = IN.uv3;
                float _OneMinus_in_uv_3 = 1 - in_UV_3[1];
                
                float3 v3 = float3(inUV2_X, in_UV_3[0], _OneMinus_in_uv_3);

                float3 subV3 = IN.ObjectSpacePosition - v3;
                float3 rotateV3;
                RotateByQuaternionV4V3_float(outputDecodeV4, subV3, rotateV3);
                float3 addV3 = combineV3_18 + rotateV3;

                float3 rotateV3_4;
                RotateByQuaternionV4V3_float(outputDecodeV4, IN.ObjectSpaceNormal, rotateV3_4);
                rotateV3_4 = normalize(rotateV3_4);
                
                float3 rotateV3_5;
                RotateByQuaternionV4V3_float(outputDecodeV4, IN.ObjectSpaceTangent, rotateV3_5);
                rotateV3_5 = normalize(rotateV3_5);
                
                description.Position = addV3;
                description.Normal = rotateV3_4;
                description.Tangent = rotateV3_5;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription{};
                
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.uv1 =                                        input.uv1;
                    output.uv2 =                                        input.uv2;
                    output.uv3 =                                        input.uv3;
                    output.TimeParameters =                             _TimeParameters.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            
        }
        FallBack "Hidden/Shader Graph/FallbackError"
    }