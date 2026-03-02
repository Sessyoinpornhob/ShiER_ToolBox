// --------------------------------
// 一个基础的 Unlit Shader 模板，支持XR项目，主要支持的功能如下
// - XR平台的渲染：URP VisionPro Metal only
// - 不透明物体 + alphaClip
// - hifi 科幻效果 
// - 全用位置计算 UV实在太乱
// --------------------------------

Shader "ShiERTest/ShaderLab/005_XR_HiFi_Grid"
{
    Properties
    {
        _CharacterMap               ("CharacterMap", 2D)   = "white" {}
        _TillingOffset_C            ("_TillingOffset_C", Vector) = (1,1,0,0)
        _MaskMap                    ("MaskMap", 2D)   = "white" {}
        _TillingOffset_M            ("_TillingOffset_M", Vector) = (1,1,0,0)
        
        [HDR] _BaseColorL1            ("Base Color L1", Color) = (1,1,1,1)
        [HDR] _BaseColorL2            ("Base Color L2", Color) = (1,1,1,1)

        [Toggle(_ALPHATEST_ON)] _AlphaClip ("Alpha Clip", Float) = 0
        _Cutoff                 ("Alpha Cutoff", Range(0, 1)) = 0.5
        _AlphaL1                ("_AlphaL1", Range(0, 1)) = 0.5
        _AlphaL2                ("_AlphaL2", Range(0, 1)) = 0.5
        
        [Header(Grid Effect)] [space(10)]
        _GridDensity_X          ("GridDensity_X", Range(0, 50)) = 0.5
        _GridDensity_Y          ("GridDensity_Y", Range(0, 50)) = 0.5
        _GridSpeed_X            ("GridSpeed_X", Range(-10, 10)) = 0.5
        _GridSpeed_Y            ("GridSpeed_Y", Range(-10, 10)) = 0.5
        _LineWidth              ("LineWidth", Range(0, 0.1)) = 0.1
        _PointRadius            ("PointRadius", Range(0, 0.1)) = 0.1
        
        [Header(Grid Effect)] [space(10)]
        _FresnelPow             ("FresnelPow", Range(0, 5)) = 0.1
        _FXIntensity            ("FXIntensity", Range(0, 1)) = 0.1
    }

    SubShader
    {
        
        Tags
        {
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
            "Queue" = "Transparent"
        }
        LOD 0
        
        Cull Off
        ZWrite On
        ZTest LEqual
        Blend One Zero     // 纯不透明
        
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

        // ---------- Per-Material 常量（SRP Batcher） ----------
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseColorL1;
            float4 _BaseColorL2;
            float4 _BaseMap_ST;
            float4 _TillingOffset_C;
            float4 _TillingOffset_M;
        
            float  _Cutoff;
            half _AlphaL1;
            half _AlphaL2;

            half _GridDensity_X;
            half _GridDensity_Y;
            half _GridSpeed_X;
            half _GridSpeed_Y;
            half _LineWidth;
            half _PointRadius;

            half _FresnelPow;
            half _FXIntensity;
        CBUFFER_END

        TEXTURE2D(_CharacterMap);       SAMPLER(sampler_CharacterMap);
        TEXTURE2D(_MaskMap);            SAMPLER(sampler_MaskMap);

        ENDHLSL

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            ZWrite On
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 4.0

            // --- 编译选项 ---
            #pragma vertex   vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #define _NORMALMAP 1
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

            
            struct Attributes
            {
                float3 positionOS               : POSITION;
                float3 normalOS                 : NORMAL;
                float4 tangentOS                : TANGENT;
                float2 uv                       : TEXCOORD0;
                float3 barycentricChannel       : COLOR;      // 若 barycentricChannel = Color
                // 或者 float3 bary : TEXCOORD1; // 若写入到 UV2
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS               : SV_POSITION;
                float2 uv                       : TEXCOORD0;
                float3 positionWS               : TEXCOORD1;
                float3 normalWS                 : TEXCOORD2;
                float4 tangentWS                : TEXCOORD3;
                float3 ViewDirWS                : TEXCOORD4;
                float3 bitangentWS              : TEXCOORD5;
                float3 barycentricChannel       : TEXCOORD6;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // 基于一个平面的 2D 坐标，算：grid线 + 点阵 + 字符贴图遮罩
            void EvaluatePlane(
                float2 baseUV,
                out half lineMask,
                out half dotMask,
                out half4 maskCharacter)
            {
                // 1) 网格的坐标（密度 + 流动）
                half2 p;
                p.x = baseUV.x * _GridDensity_X + _GridSpeed_X * _Time.y;
                p.y = baseUV.y * _GridDensity_Y + _GridSpeed_Y * _Time.y;

                // 2) 文字/Mask 的 UV（TilingOffset + 流动）
                half2 uv_p_C;
                uv_p_C.x = baseUV.x * _TillingOffset_C.x + _TillingOffset_C.z * _Time.y;
                uv_p_C.y = baseUV.y * _TillingOffset_C.y + _TillingOffset_C.w * _Time.y;

                half2 uv_p_M;
                uv_p_M.x = baseUV.x * _TillingOffset_M.x + _TillingOffset_M.z * _Time.y;
                uv_p_M.y = baseUV.y * _TillingOffset_M.y + _TillingOffset_M.w * _Time.y;

                half4 CharacterMapVal = SAMPLE_TEXTURE2D(_CharacterMap, sampler_CharacterMap, uv_p_C);
                half4 MaskMapVal      = SAMPLE_TEXTURE2D(_MaskMap,      sampler_MaskMap,  uv_p_M);
                maskCharacter = CharacterMapVal * MaskMapVal;

                // 3) 网格线
                half2 cell       = frac(p);
                half2 distToEdge = min(cell, 1 - cell);
                half lineVals    = step(distToEdge.x, _LineWidth) + step(distToEdge.y, _LineWidth);
                lineMask         = saturate(lineVals);

                // 4) 点阵
                half  distToCenter = length(cell - half2(0.5h, 0.5h));
                dotMask            = step(distToCenter, _PointRadius);
            }
            
            Varyings vert (Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.normalWS = normalize(normalInput.normalWS);
                
                real sign = input.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
                output.tangentWS = tangentWS;
                output.bitangentWS = normalInput.bitangentWS;
                
                float3 ViewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
                output.ViewDirWS = ViewDirWS;

                output.positionWS = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                
                output.uv                   = TRANSFORM_TEX(input.uv, _BaseMap);
                output.barycentricChannel   = input.barycentricChannel;

                return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                
                // ----------------- 1. 采样纹理 -----------------
                // half4 BaseMapVal = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColorL1;

                // ----------------- 2. 准备向量 -----------------
                float3 positionWS = input.positionWS;
                float3 normalWS = input.normalWS;
                
                
                // ----------------- 3. 直接光（主光 + 额外灯光） -----------------
                Light mainLight = GetMainLight();
                float3 L = mainLight.direction;
                
                half NdotL = max(dot(input.normalWS, L), 0.0f);
                NdotL = Remap(0,1,0.1,0.9,NdotL);
                half4 halfLambert = NdotL * _BaseColorL1;

                half VdotL = dot(input.ViewDirWS, input.normalWS);
                half fresnelColor = _FXIntensity * pow(saturate(1-VdotL), _FresnelPow);

                // ----------------- 4. 计算基于位置的效果（Triplanar） -----------------

                float3 nWS  = normalize(normalWS);
                float3 anWS = abs(nWS);
                anWS /= max(anWS.x + anWS.y + anWS.z, 1e-5);   // 归一化，作为三个平面的权重

                // 三个投影平面：
                //  - normal 朝 Z → 用 XY 平面（正面）
                //  - normal 朝 Y → 用 XZ 平面（地面/顶面）
                //  - normal 朝 X → 用 ZY 平面（侧面）
                float2 uvXY = positionWS.xy;
                float2 uvXZ = positionWS.xz;
                float2 uvZY = positionWS.zy;

                // 对三个平面分别计算：grid + 点 + 字符遮罩
                half  lineXY, dotXY;
                half4 maskCharXY;
                EvaluatePlane(uvXY, lineXY, dotXY, maskCharXY);

                half  lineXZ, dotXZ;
                half4 maskCharXZ;
                EvaluatePlane(uvXZ, lineXZ, dotXZ, maskCharXZ);

                half  lineZY, dotZY;
                half4 maskCharZY;
                EvaluatePlane(uvZY, lineZY, dotZY, maskCharZY);

                // 按法线的绝对值权重进行混合（Triplanar blend）
                half  lineMask  = lineXY * anWS.z + lineXZ * anWS.y + lineZY * anWS.x;
                half  dotMask   = dotXY  * anWS.z + dotXZ  * anWS.y + dotZY  * anWS.x;
                half4 MaskCharacter = maskCharXY * anWS.z + maskCharXZ * anWS.y + maskCharZY * anWS.x;


                // ----------------- 5. 后续混合 -----------------
                half maskL2 = lineMask + dotMask;
                half3 colorL1 = _BaseColorL1;
                half3 colorL2 = _BaseColorL2;
                half4 layer1Color = half4(colorL1, _AlphaL1);               // l1 半透明纹理部分
                half4 layer2Color = half4(colorL2, _AlphaL2);               // l2 不透明部分

                half4 layer1C = half4(fresnelColor * colorL1, _AlphaL1);

                half4 finalColor = lerp(layer1Color * MaskCharacter + layer1C, layer2Color, maskL2);

                #if defined(_ALPHATEST_ON)
                    clip(mask - 0.01);
                    // 将 col.a = 1 注释掉就能观察到透出现象
                #endif
                
                return finalColor;
            }

            ENDHLSL
        }
    }

    FallBack Off
}
