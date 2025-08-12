// Fabric_BSDF.hlsl
#ifndef Fabric_BSDF_INCLUDED
#define Fabric_BSDF_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// Computes the scalar specular term for Minimalist CookTorrance BRDF
// NOTE: needs to be multiplied with reflectance f0, i.e. specular color to complete
half ALab_Fabric_DirectBRDFSpecular(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    float3 lightDirectionWSFloat3 = float3(lightDirectionWS);
    float3 halfDir = SafeNormalize(lightDirectionWSFloat3 + float3(viewDirectionWS));

    float NoH = saturate(dot(float3(normalWS), halfDir));
    half LoH = half(saturate(dot(lightDirectionWSFloat3, halfDir)));

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // BRDFspec = (D * V * F) / 4.0
    // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
    // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155

    // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
    // We further optimize a few light invariant terms
    // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
    float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;

    half LoH2 = LoH * LoH;
    half specularTerm = brdfData.roughness2 / ((d * d) * max(0.1h, LoH2) * brdfData.normalizationTerm);

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
#if REAL_IS_HALF
    specularTerm = specularTerm - HALF_MIN;
    // Update: Conservative bump from 100.0 to 1000.0 to better match the full float specular look.
    // Roughly 65504.0 / 32*2 == 1023.5,
    // or HALF_MAX / ((mobile) MAX_VISIBLE_LIGHTS * 2),
    // to reserve half of the per light range for specular and half for diffuse + indirect + emissive.
    specularTerm = clamp(specularTerm, 0.0, 1000.0); // Prevent FP16 overflow on mobiles
#endif

    return specularTerm;
}

// 合并
half3 ALab_Fabric_BRDF_AnisotropicGGX(
	BRDFData brdfData, half3 lightDirWS, half3 viewDirWS,
	half3 normalWS, half3 tangentWS, half3 bitangentWS, 
     half anisotropy, half3 F0 )
{
    // 计算半程向量
    float3 halfDir = SafeNormalize(lightDirWS + viewDirWS);

    // 计算各向异性参数
    float at = max(brdfData.roughness * (1.0 + anisotropy), 0.001);
    float ab = max(brdfData.roughness * (1.0 - anisotropy), 0.001);

    // 计算各向异性半程向量的切线 & 副切线分量
    float ToH = dot(tangentWS, halfDir);
    float BoH = dot(bitangentWS, halfDir);
    float NoH = saturate(dot(normalWS, halfDir));

    // *** 1. 法线分布函数 D_GGX_Anisotropic ***
    float a2 = at * ab;
    float3 v = float3(ab * ToH, at * BoH, a2 * NoH);
    float v2 = dot(v, v);
    float w2 = a2 / max(v2, 0.001); // 避免过小的值
    float D = a2 * w2 * w2 * (1.0 / PI); // GGX 各向异性分布

    // 计算视角 & 光照方向的相关参数
    float ToV = dot(tangentWS, viewDirWS);
    float BoV = dot(bitangentWS, viewDirWS);
    float NoV = saturate(dot(normalWS, viewDirWS));

    float ToL = dot(tangentWS, lightDirWS);
    float BoL = dot(bitangentWS, lightDirWS);
    float NoL = saturate(dot(normalWS, lightDirWS));

    // *** 2. Smith 相关遮蔽函数 V_SmithGGXCorrelated_Anisotropic ***
    float lambdaV = NoL * length(float3(at * ToV, ab * BoV, NoV));
    float lambdaL = NoV * length(float3(at * ToL, ab * BoL, NoL));
	// 这一行删除会导致反光区域出现白边 避免过小的值
    float V = 0.5 / max(lambdaV + lambdaL, 0.001);	

    // *** 3. 菲涅耳反射 F_Schlick ***
    float3 F = F0 + (1.0 - F0) * pow(1.0 - saturate(dot(viewDirWS, halfDir)), 5.0);
	// float3 F = 1;

    // 计算最终的各向异性 GGX 镜面反射
    half3 specular = (D * V) * F;

    return specular;
}

half3 ALab_Fabric_CalculateLightContribution(
    BRDFData brdfData, 
    float anisotropyVal, 
    Light light,
    half3 normalWS, 
    half3 viewDirWS, 
    half3 tangentWS, 
    half3 bitangentWS, 
    half3 F0 )
{
    half3 lightDirWS = normalize(light.direction);
    half3 radiance = light.color * light.distanceAttenuation * light.shadowAttenuation;

    // 计算各向异性高光
    half3 specular = ALab_Fabric_BRDF_AnisotropicGGX(brdfData, lightDirWS, viewDirWS, normalWS, tangentWS, bitangentWS, anisotropyVal, F0);

    // 计算漫反射 (Lambert)
    half NdotL = saturate(dot(normalWS, lightDirWS));
    half3 diffuse = brdfData.diffuse * NdotL;

    return (diffuse + specular) * radiance;
}


half3 ALab_Fabric_LightingPhysicallyBased(
	BRDFData brdfData, float anisotropyVal, Light light,
    half3 normalWS, half3 viewDirectionWS, float3 tangent,
    float3 bitangent, bool specularHighlightsOff, float f0,
    half3 specularColor)
{
	float lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;
	half3 lightColor = light.color;
	half3 lightDirectionWS = light.direction;
	
    half NdotL = saturate(dot(normalWS, lightDirectionWS));
    half3 radiance = lightColor * (lightAttenuation * NdotL);

    half3 brdf = brdfData.diffuse;
    [branch] if (!specularHighlightsOff)
    {
	    // 只有这里有BRDF相关的代码 后续只需要调整这个函数中的D项目，就能够做出各向异性的效果了。
	    // brdfData.specular * 
	    brdf += brdfData.specular * specularColor * ALab_Fabric_BRDF_AnisotropicGGX(brdfData, lightDirectionWS, viewDirectionWS, normalWS, tangent, bitangent, anisotropyVal, f0);
    }
    return brdf * radiance;
}


half4 ALab_Fabric_UniversalFragmentPBR(
	InputData inputData, SurfaceData surfaceData, float anisotropyVal,
	float3 tangent, float3 bitangent, float f0, half3 specularColor)
{
    bool specularHighlightsOff = false;
    BRDFData brdfData;
	// brdfData.specular = surfaceData.specular;

    // NOTE: can modify "surfaceData"...
    InitializeBRDFData(surfaceData, brdfData);

    // Clear-coat calculation...	
    BRDFData brdfDataClearCoat = CreateClearCoatBRDFData(surfaceData, brdfData);
    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);

    // NOTE: We don't apply AO to the GI here because it's done in the lighting calculation below...
    // MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    LightingData lightingData = CreateLightingData(inputData, surfaceData);

    lightingData.giColor = GlobalIllumination(brdfData, brdfDataClearCoat, surfaceData.clearCoatMask,
                                              inputData.bakedGI, aoFactor.indirectAmbientOcclusion, inputData.positionWS,
                                              inputData.normalWS, inputData.viewDirectionWS, inputData.normalizedScreenSpaceUV);
	
	
    // lightingData.mainLightColor = half4(0, 0, 0, 1);
    lightingData.mainLightColor = ALab_Fabric_LightingPhysicallyBased(brdfData, anisotropyVal, mainLight,
                                                          inputData.normalWS, inputData.viewDirectionWS,
                                                          tangent, bitangent, specularHighlightsOff, f0, specularColor);

	// 在此处加入多光源相关代码 调整函数 URP_FP_DIRECTIONAL_LIGHTS_COUNT -> 2
	uint pixelLightCount = GetAdditionalLightsCount();
    [loop] for (uint lightIndex = 0; lightIndex < min(2, MAX_VISIBLE_LIGHTS); lightIndex++)
    {
        FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
        {
            // lightingData.additionalLightsColor += LightingPhysicallyBased(brdfData, brdfDataClearCoat, light,
            //                                                               inputData.normalWS, inputData.viewDirectionWS,
            //                                                               surfaceData.clearCoatMask, specularHighlightsOff);
	        lightingData.additionalLightsColor += ALab_Fabric_LightingPhysicallyBased(brdfData, anisotropyVal, light,
                                                          inputData.normalWS, inputData.viewDirectionWS,
                                                          tangent, bitangent, specularHighlightsOff, f0, specularColor);
        }
    }

    LIGHT_LOOP_BEGIN(pixelLightCount)
	    Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
        {
            lightingData.additionalLightsColor += ALab_Fabric_LightingPhysicallyBased(brdfData, anisotropyVal, light,
                                                          inputData.normalWS, inputData.viewDirectionWS,
                                                          tangent, bitangent, specularHighlightsOff, f0, specularColor);
        }
	LIGHT_LOOP_END
	
	return min(CalculateFinalColor(lightingData, surfaceData.alpha), HALF_MAX);
}

#endif