// ShiER_KajiyaKay_HairData.hlsl
// - 记录来自 "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 的函数
// - 进行了一些修改
#ifndef ShiER_KAJIYAKAY_HAIRDATA_INCLUDED
#define ShiER_KAJIYAKAY_HAIRDATA_INCLUDED

    struct KajiyaKay_HairData
    {
        float3 t;                           // bitangentWS or tangentWS
        float3 normalWS;                    // 世界法线方向
        float3 lightDirWS;                  // 世界光照方向
        float3 viewDirWS;                   // 世界相机方向
        half shiftTexVal;                   // 光照横移贴图
        half ShiftOffset_01;                // 高光横移偏移01
        half ShiftOffset_02;                // 高光横移偏移02
        half SpecularWidth;                 // 高光宽度
        half exponent;                      // 高光范围大小
        half3 SpecularColor;                // 高光颜色
    };


#endif