// ShiER_BRDF
// - 来自 "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"

#ifndef ShiER_BRDF_INCLUDED
#define ShiER_BRDF_INCLUDED

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/BSDF.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Deprecated.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"

    // 试试搞个自己的 struct
    // 这里不行 很多函数跟这个结构体相关
    struct BRDFData_ShiER
    {
        half3 albedo;
        half3 diffuse;
        half3 specular;
        half reflectivity;
        half perceptualRoughness;
        half roughness;
        half roughness2;
        half grazingTerm;

        // We save some light invariant BRDF terms so we don't have to recompute
        // them in the light loop. Take a look at DirectBRDF function for detailed explaination.
        half normalizationTerm;     // roughness * 4.0 + 2.0
        half roughness2MinusOne;    // roughness^2 - 1.0
    };

    // 允许在 metallic 流程中使用高光颜色
    // Initialize BRDFData for material, managing both specular and metallic setup using shader keyword _SPECULAR_SETUP.
    inline void InitializeBRDFData_ShiER(half3 albedo, half metallic, half3 specular, half smoothness, inout half alpha, out BRDFData outBRDFData)
    {
        // specular 流程
        // half reflectivity = ReflectivitySpecular(specular);
        // half oneMinusReflectivity = half(1.0) - reflectivity;
        // half3 brdfDiffuse = albedo * oneMinusReflectivity;
        // half3 brdfSpecular = specular;

        // metallic 流程
        half oneMinusReflectivity = OneMinusReflectivityMetallic(metallic);
        half reflectivity = half(1.0) - oneMinusReflectivity;
        half3 brdfDiffuse = albedo * oneMinusReflectivity;
        // half3 brdfSpecular = lerp(kDielectricSpec.rgb, albedo, metallic);
        half3 brdfSpecular = specular;
        
        InitializeBRDFDataDirect(albedo, brdfDiffuse, brdfSpecular, reflectivity, oneMinusReflectivity, smoothness, alpha, outBRDFData);
    }

    inline void InitializeBRDFData_ShiER(inout SurfaceData surfaceData, out BRDFData brdfData)
    {
        InitializeBRDFData_ShiER(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);
    }

    // Computes the scalar specular term for Minimalist CookTorrance BRDF
    // NOTE: needs to be multiplied with reflectance f0, i.e. specular color to complete
    half DirectBRDFSpecular_ShiER(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
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

#endif