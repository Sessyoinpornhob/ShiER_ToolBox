// ShiER_Lighting.hlsl
// - 记录来自 "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 的函数
// - 进行了一些修改
#ifndef ShiER_LIGHTING_INCLUDED
#define ShiER_LIGHTING_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_BRDF.hlsl"
    #include "Assets/Art/MaterialLibrary/CustomHLSL/ShiER_KajiyaKay_HairData.hlsl"

    half3 LightingPhysicallyBased_ShiER_Base(BRDFData brdfData, BRDFData brdfDataClearCoat,
    half3 lightColor, half3 lightDirectionWS, float lightAttenuation,
    half3 normalWS, half3 viewDirectionWS,
    half clearCoatMask, bool specularHighlightsOff)
    {
        half NdotL = saturate(dot(normalWS, lightDirectionWS));
        half3 radiance = lightColor * (lightAttenuation * NdotL);

        half3 brdf = brdfData.diffuse;
        #ifndef _SPECULARHIGHLIGHTS_OFF
        [branch] if (!specularHighlightsOff)
        {
            brdf += brdfData.specular * DirectBRDFSpecular_ShiER(brdfData, normalWS, lightDirectionWS, viewDirectionWS);

            #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
            // Clear coat evaluates the specular a second timw and has some common terms with the base specular.
            // We rely on the compiler to merge these and compute them only once.
            half brdfCoat = kDielectricSpec.r * DirectBRDFSpecular(brdfDataClearCoat, normalWS, lightDirectionWS, viewDirectionWS);

            // Mix clear coat and base layer using khronos glTF recommended formula
            // https://github.com/KhronosGroup/glTF/blob/master/extensions/2.0/Khronos/KHR_materials_clearcoat/README.md
            // Use NoV for direct too instead of LoH as an optimization (NoV is light invariant).
            half NoV = saturate(dot(normalWS, viewDirectionWS));
            // Use slightly simpler fresnelTerm (Pow4 vs Pow5) as a small optimization.
            // It is matching fresnel used in the GI/Env, so should produce a consistent clear coat blend (env vs. direct)
            half coatFresnel = kDielectricSpec.x + kDielectricSpec.a * Pow4(1.0 - NoV);

            brdf = brdf * (1.0 - clearCoatMask * coatFresnel) + brdfCoat * clearCoatMask;
            #endif // _CLEARCOAT
        }
        #endif // _SPECULARHIGHLIGHTS_OFF

        return brdf * radiance;
    }

    half3 LightingPhysicallyBased_ShiER_Hair(
        BRDFData brdfData,
        KajiyaKay_HairData kajiya_kay_hair_data,
    half3 lightColor, half3 lightDirectionWS, float lightAttenuation,
    half3 normalWS, half3 viewDirectionWS, bool specularHighlightsOff)
    {
        half NdotL = saturate(dot(normalWS, lightDirectionWS));
        half3 radiance = lightColor * (lightAttenuation * NdotL);

        half3 brdf = brdfData.diffuse;
        #ifndef _SPECULARHIGHLIGHTS_OFF
        [branch] if (!specularHighlightsOff)
        {
            brdf += brdfData.specular *
                DirectBRDFSpecular_ShiER_Hair(
                    brdfData, kajiya_kay_hair_data,
                    normalWS, lightDirectionWS, viewDirectionWS);
        }
        #endif // _SPECULARHIGHLIGHTS_OFF

        return brdf * radiance;
    }


    half3 LightingPhysicallyBased_ShiER_Base(BRDFData brdfData, BRDFData brdfDataClearCoat, Light light, half3 normalWS, half3 viewDirectionWS, half clearCoatMask, bool specularHighlightsOff)
    {
        return LightingPhysicallyBased_ShiER_Base(brdfData, brdfDataClearCoat, light.color, light.direction, light.distanceAttenuation * light.shadowAttenuation, normalWS, viewDirectionWS, clearCoatMask, specularHighlightsOff);
    }

    half3 LightingPhysicallyBased_ShiER_Hair(
        BRDFData brdfData, KajiyaKay_HairData kajiya_kay_hair_data, Light light,
        half3 normalWS, half3 viewDirectionWS,
        bool specularHighlightsOff)
    {
        return LightingPhysicallyBased_ShiER_Hair(
            brdfData, kajiya_kay_hair_data, light.color, light.direction,
            light.distanceAttenuation * light.shadowAttenuation,
            normalWS, viewDirectionWS, specularHighlightsOff);
    }

    // 修改项：
    // - 可以使用 Specular Color
    half4 UniversalFragmentPBR_ShiER_Base(InputData inputData, SurfaceData surfaceData)
    {
        #if defined(_SPECULARHIGHLIGHTS_OFF)
        bool specularHighlightsOff = true;
        #else
        bool specularHighlightsOff = false;
        #endif
        BRDFData brdfData;

        // NOTE: can modify "surfaceData"...
        InitializeBRDFData_ShiER(surfaceData, brdfData);

        // Clear-coat calculation...
        BRDFData brdfDataClearCoat = CreateClearCoatBRDFData(surfaceData, brdfData);
        half4 shadowMask = CalculateShadowMask(inputData);
        AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
        uint meshRenderingLayers = GetMeshRenderingLayer();
        Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);

        // NOTE: We don't apply AO to the GI here because it's done in the lighting calculation below...
        MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

        LightingData lightingData = CreateLightingData(inputData, surfaceData);

        lightingData.giColor = GlobalIllumination(brdfData, brdfDataClearCoat, surfaceData.clearCoatMask,
                                                  inputData.bakedGI, aoFactor.indirectAmbientOcclusion, inputData.positionWS,
                                                  inputData.normalWS, inputData.viewDirectionWS, inputData.normalizedScreenSpaceUV);
    #ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    #endif
        {
            lightingData.mainLightColor = LightingPhysicallyBased_ShiER_Base(brdfData, brdfDataClearCoat,
                                                                  mainLight,
                                                                  inputData.normalWS, inputData.viewDirectionWS,
                                                                  surfaceData.clearCoatMask, specularHighlightsOff);
        }

        #if defined(_ADDITIONAL_LIGHTS)
        uint pixelLightCount = GetAdditionalLightsCount();

        #if USE_FORWARD_PLUS
        [loop] for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
        {
            FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

            Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

    #ifdef _LIGHT_LAYERS
            if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
    #endif
            {
                lightingData.additionalLightsColor += LightingPhysicallyBased_ShiER(brdfData, brdfDataClearCoat, light,
                                                                              inputData.normalWS, inputData.viewDirectionWS,
                                                                              surfaceData.clearCoatMask, specularHighlightsOff);
            }
        }
        #endif

        LIGHT_LOOP_BEGIN(pixelLightCount)
            Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

    #ifdef _LIGHT_LAYERS
            if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
    #endif
            {
                lightingData.additionalLightsColor += LightingPhysicallyBased_ShiER_Base(brdfData, brdfDataClearCoat, light,
                                                                              inputData.normalWS, inputData.viewDirectionWS,
                                                                              surfaceData.clearCoatMask, specularHighlightsOff);
            }
        LIGHT_LOOP_END
        #endif

        #if defined(_ADDITIONAL_LIGHTS_VERTEX)
        lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
        #endif

    #if REAL_IS_HALF
        // Clamp any half.inf+ to HALF_MAX
        return min(CalculateFinalColor(lightingData, surfaceData.alpha), HALF_MAX);
    #else
        return CalculateFinalColor(lightingData, surfaceData.alpha);
    #endif
    }

    // 修改项：
    // - 可以使用 Specular Color
    // - kajiya-kay 模型的头发高光
    half4 UniversalFragmentPBR_ShiER_Hair(InputData inputData, SurfaceData surfaceData, KajiyaKay_HairData hair_data)
    {
        #if defined(_SPECULARHIGHLIGHTS_OFF)
        bool specularHighlightsOff = true;
        #else
        bool specularHighlightsOff = false;
        #endif
        BRDFData brdfData;

        // NOTE: can modify "surfaceData"...
        InitializeBRDFData_ShiER(surfaceData, brdfData);

        // Clear-coat calculation...
        BRDFData brdfDataClearCoat = CreateClearCoatBRDFData(surfaceData, brdfData);
        half4 shadowMask = CalculateShadowMask(inputData);
        AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
        Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);

        // NOTE: We don't apply AO to the GI here because it's done in the lighting calculation below...
        MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

        LightingData lightingData = CreateLightingData(inputData, surfaceData);

        lightingData.giColor = GlobalIllumination(brdfData, brdfDataClearCoat, surfaceData.clearCoatMask,
                                                  inputData.bakedGI, aoFactor.indirectAmbientOcclusion, inputData.positionWS,
                                                  inputData.normalWS, inputData.viewDirectionWS, inputData.normalizedScreenSpaceUV);
        lightingData.mainLightColor = LightingPhysicallyBased_ShiER_Hair(brdfData, hair_data, mainLight,
                                                              inputData.normalWS, inputData.viewDirectionWS,
                                                              specularHighlightsOff);
        #if defined(_ADDITIONAL_LIGHTS)
        uint pixelLightCount = GetAdditionalLightsCount();
        LIGHT_LOOP_BEGIN(pixelLightCount)
            Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
            lightingData.additionalLightsColor += LightingPhysicallyBased_ShiER_Base(brdfData, brdfDataClearCoat, light,
                                                                          inputData.normalWS, inputData.viewDirectionWS,
                                                                          surfaceData.clearCoatMask, specularHighlightsOff);
        LIGHT_LOOP_END
        #endif

        #if defined(_ADDITIONAL_LIGHTS_VERTEX)
        lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
        #endif

    #if REAL_IS_HALF
        // Clamp any half.inf+ to HALF_MAX
        return min(CalculateFinalColor(lightingData, surfaceData.alpha), HALF_MAX);
    #else
        return CalculateFinalColor(lightingData, surfaceData.alpha);
    #endif
    }


#endif