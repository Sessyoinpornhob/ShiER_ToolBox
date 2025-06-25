Shader "Genshin/GNPR_outline"
{
    Properties
    {
        [Header(BaseColor)]
        [MainTexture] _BaseMap("Base Map", 2D) = "white"{}
        
        [Header(RampTex)]
        _RampMap("RampTex", 2D) = "white"{}
        _RampShadowRange("RampTex取值范围",range(0.4, 1)) = 0.5
        
        [Header(LightMap AO )]
        _LightMap("LightMap", 2D) = "white"{}
        _ShadowRampLerp("AO强度",range(0, 1)) = 0.5
        _RampAOLerp("Ramp和AO强度",range(0, 1)) = 0.5
        _LightThreshold("LightThreshold",range(0, 1)) = 0.5        
        [HideInInspector]_ShadowMultColor("亮部阴影色", Color) = (1, 1, 1, 1)
        _BrightIntensity("亮部强度",range(0, 1)) = 0.5
        [HideInInspector]_DarkShadowMultColor("暗部阴影色", Color) = (1, 1, 1, 1)
        _DarkIntensity("暗部强度",range(0, 1)) = 0.5
        
        [Header(Specular)]
        _StepSpecularWidth1("1-布料高光可见范围",range(0, 1)) = 0.5
        _StepSpecularIntensity1("1-布料高光强度",range(0, 1)) = 0.5
        _StepSpecularWidth2("2-布料边缘高光可见范围",range(0, 1)) = 0.5
        _StepSpecularIntensity2("2-布料边缘高光强度",range(0, 1)) = 0.5
        _StepSpecularWidth3("3-布料填充高光可见范围",range(0, 3)) = 0.5
        _StepSpecularIntensity3("3-布料填充高光强度",range(0, 3)) = 0.5
        _SpecularExp("金属高光范围",range(0, 30)) = 0.5
        _SpecularIntensity("金属高光强度",range(0, 10)) = 0.5
        _StepSpecularWidth4("4-头发高光可见范围",range(0, 3)) = 0.5
        _StepSpecularIntensity4("4-头发高光强度",range(0, 3)) = 0.5
        
        [Header(MetalMap)]
        _MetalMap("Matcap 金属反射贴图", 2D) = "white"{}
        _MetalMapIntensity("Matcap 强度",range(0, 1)) = 0.5
        _MetalMapV("Matcap 金属裁边视⾓光强度",range(0, 1)) = 0.5
        
        [Header(Rimlight)]
        [Toggle]_EnableRim("开启边缘光", Int) = 0
        _RimPow("亮部边缘光范围",range(0, 20)) = 0.5
        _DarkSideRimPow("暗部边缘光范围",range(0, 20)) = 0.5
        _EnableLambert("兰伯特边缘光遮罩",range(0, 1)) = 0.5
        _RimSmooth("亮部双边缘光延展遮罩范围",range(0.005, 0.5)) = 0.5
        _DarkSideRimSmooth("暗部双边缘光延展遮罩范围",range(0.005, 0.5)) = 0.5
        _RimColor("亮部边缘光颜色", Color) = (1, 1, 1, 1)
        _DarkSideRimColor("暗部边缘光颜色", Color) = (1, 1, 1, 1)
        
        [Header(Outline)]
        [Toggle]_ENABLE_ALPHA_TEST("Enable AlphaTest",float)=0
        _Cutoff("Cutoff", Range(0,1)) = 0.5
        _OutlineWidth("OutlineWidth", Range(0, 10)) = 0.4
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        [Toggle]_OLWVWD("OutlineWidth Varies With Distance?", float) = 0
        
        [Header(FaceShadowSDF)]
        _Faceshadow("_Faceshadow", 2D) = "white"{}
        _Faceshadow2("_Faceshadow2", 2D) = "white"{}
        
        [Header(Test)]
        _TestSpecularLayerController("Test属性_高光范围",range(0, 260)) = 0.5
        [KeywordEnum(On,Off)] ENABLE_HAIR_RAMP("是否应用头发高光", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
        
            #pragma multi_compile ENABLE_HAIR_RAMP_ON ENABLE_HAIR_RAMP_OFF
            #pragma shader_feature _EnableRim_ON
            #pragma shader_feature _ENABLE_ALPHA_TEST_ON
            #pragma shader_feature _OLWVWD_ON
        
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _BaseMap_ST;

                float _RampShadowRange;
                float _RampChoice;
                float4 _ShadowMultColor;
                float4 _DarkShadowMultColor;
            
                float _ShadowRampLerp;
                float _RampAOLerp;
                float _LightThreshold;
                float _BrightIntensity;
                float _DarkIntensity;
            
                float _StepSpecularWidth1;
                float _StepSpecularIntensity1;
                float _StepSpecularWidth2;
                float _StepSpecularIntensity2;
                float _StepSpecularWidth3;
                float _StepSpecularIntensity3;
                float _StepSpecularWidth4;
                float _StepSpecularIntensity4;
            
                float _SpecularExp;
                float _SpecularIntensity;
                float _TestSpecularLayerController;

                float _MetalMapIntensity;
                float _MetalMapV;

                float _RimPow;
                float _DarkSideRimPow;
                float _EnableLambert;
                float _RimSmooth;
                float _DarkSideRimSmooth;
                int _EnableRim;
                float4 _RimColor;
                float4 _DarkSideRimColor;

                float _Cutoff;
                float _OutlineWidth;
                float4 _OutlineColor;
                
            CBUFFER_END
        
            // 此宏将 _BaseMap 声明为 Texture2D 对象。
            TEXTURE2D(_BaseMap);        SAMPLER(sampler_BaseMap);
            TEXTURE2D(_RampMap);        SAMPLER(sampler_RampMap);
            TEXTURE2D(_LightMap);       SAMPLER(sampler_LightMap);
            TEXTURE2D(_MetalMap);       SAMPLER(sampler_MetalMap);
            TEXTURE2D(_Faceshadow);     SAMPLER(sampler_Faceshadow);
            TEXTURE2D(_Faceshadow2);     SAMPLER(sampler_Faceshadow2);

            struct VertexInput
            {
                float4 positionOS : POSITION;
                float2 uv :         TEXCOORD0;
                half3 normalOS :    NORMAL;
            };

            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float2 uv :         TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS :   TEXCOORD2;
                float3 viewDirWS :  TEXCOORD3;
            };
        ENDHLSL

        Pass
        {
            Tags{"LightMode" = "UniversalForward"} 
            Cull off
            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            
            // 顶点着色器
            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                // 视线方向
                VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                o.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;
                // 法线方向
                VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normalOS.xyz);                                // input.normalOS, input.tangentOS ?
                o.normalWS = normalInputs.normalWS;
                // 位置信息
                o.positionWS = positionInputs.positionWS;
                o.positionCS = positionInputs.positionCS;
                // uv采样
                o.uv = v.uv;
                return o;
            }

            // 片元着色器
            float4 frag (VertexOutput i) : SV_Target
            {
                float3 normalDirWS = i.normalWS;
                
                // sample the texture
                float4 BaseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                float4 LightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv);
                float4 MetalMap = SAMPLE_TEXTURE2D(_MetalMap,sampler_MetalMap, mul((float3x3)UNITY_MATRIX_V, normalDirWS).xy).r;
                MetalMap = saturate(MetalMap);
                MetalMap = step(_MetalMapV, MetalMap) * _MetalMapIntensity;  

                // 准备向量
                // 光方向
                Light light = GetMainLight();
                float3 lightDirWS = normalize(light.direction);
                float4 LightColor = float4(light.color, 1);
                // 法线方向 见frag函数下第一行，由于采样MetalMap需要normalDirWS，因此提前做了
                
                // 摄像机方向
                float3 viewDirWS = normalize(i.viewDirWS);
                // 半角方向
                float halfDirWS = normalize(viewDirWS + lightDirWS);
                
                float SpecularLayerMask = LightMap.r;       // ⾼光类型Layer
                float ShadowAOMask = LightMap.g;            //ShadowAOMask
                float SpecularIntensityMask = LightMap.b;   //SpecularIntensityMask

                // 中间数据和点乘结果
                float ndotl = dot(normalDirWS, lightDirWS);
                float ndoth = dot(normalDirWS, halfDirWS);
                
                // 光照模型 半兰伯特
                float lambert = max(0.0, ndotl);
                half halfLambert = max(0.0, ndotl) * 0.5 + 0.5;
                // AO
                ShadowAOMask = 1 - smoothstep(saturate(ShadowAOMask), 0.2, 0.6);
                // RampTex采样
                float rampValue = halfLambert  * lerp(0.5, 1.0, ShadowAOMask) * (1.0 / _RampShadowRange);
                half3 ShadowRamp = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(rampValue, _RampChoice)).rgb;     // 更柔和的明暗分界线
                half3 finalRamp = ShadowRamp;       // 最终混合 等后面再加不同材质和昼夜的变化情况

                float3 BaseMapShadowed = lerp(BaseColor.rgb * finalRamp, BaseColor.rgb, ShadowAOMask);
                BaseMapShadowed = lerp(BaseColor.rgb, BaseMapShadowed, _ShadowRampLerp);                                // 纯底图 + AO范围叠加的RampTex色
                float IsBrightSide = ShadowAOMask * step(_LightThreshold, halfLambert);                                 // 亮区

                // 面部SDF
                // 获取计算方向
                float3 qianDir = normalize(TransformObjectToWorld(float3(0.0, 0.0, 1.0)));//拿到模型的向前方向
                float3 rightDir = normalize(TransformObjectToWorld(float3(1.0, 0.0, 0.0)));//拿到模型的向右方向
                float FaceLambert = dot(lightDirWS.xz, qianDir.xz);// * 0.5 + 0.5;//用来得到类似半兰伯特效果的阈值                √
                float FaceLambert2 = dot(lightDirWS.xz, rightDir.xz);//光照方向与x轴正方向点乘，正值为右脸阴影，负值为左脸阴影 cos
                float Faceshadow  = SAMPLE_TEXTURE2D(_Faceshadow, sampler_Faceshadow, i.uv);
                float Faceshadow2  = SAMPLE_TEXTURE2D(_Faceshadow2, sampler_Faceshadow2, i.uv);// 问题出在这行代码 uv的计算出现了问题
                float FinalFaceShadow = lerp(Faceshadow, Faceshadow2, step(FaceLambert2, 0));//判断该采样哪边的阴影       对的，找个采样的阈值就行

                float face = FaceLambert > FinalFaceShadow ? 1.0 : 0.0;
                //float face = FaceLambert > Faceshadow ? 1.0 : 0.0;    //最后将阈值和贴图的值比较 如果只看Faceshadow部分，这段代码是对的
                
                // 输出值
                float3 faceSDF = lerp(lerp(BaseMapShadowed, BaseColor.rgb * finalRamp, _RampAOLerp) * _DarkIntensity, _BrightIntensity * BaseMapShadowed, face);
                // return float4(FaceLambert, FaceLambert, FaceLambert, 1.0);                
                
                half3 diffuse = lerp(
                    lerp(BaseMapShadowed, BaseColor.rgb * finalRamp, _RampAOLerp) * _DarkIntensity,
                    _BrightIntensity * BaseMapShadowed , IsBrightSide * _BrightIntensity);
                // lerp 暗区和亮区 但亮区和暗区的明亮程度不同（_BrightIntensity != _DarkIntensity） 且 emmmm 有点整不会了，后面再看



                
                // 镜面反射部分 Spec
                float SpecRamp = step(0.78, SpecularLayerMask);

                float3 Specular = 0;
                float3 StepSpecular = 0;
                float3 StepSpecular2 = 0;
                float LinearMask = pow(LightMap.r, 1 / 2.2);            //图⽚格式全部去掉勾选SRGB ⾼光类型Layer
                float SpecularLayer = LinearMask * 255;
                float StepSpecularMask = step(200, pow(SpecularIntensityMask, 1 / 2.2) * 255); //高光强度遮罩，加伽马校正
                if (SpecularLayer > 0 && SpecularLayer < 50)//丝袜与包包
                {
                    //step x<=y返回1，否则返回0
                    StepSpecular = step(1 - _StepSpecularWidth1, saturate(dot(normalDirWS, viewDirWS))) * _StepSpecularIntensity1 ; //可做修改* SpecularIntensityMask
                    StepSpecular *= BaseColor;           
                }
                if (SpecularLayer > 50 && SpecularLayer < 150)//布料边缘高光
                {
                    StepSpecular = step(1 - _StepSpecularWidth2, saturate(dot(normalDirWS, viewDirWS))) * 1 * _StepSpecularIntensity2 ;//* SpecularIntensityMask
                    StepSpecular *= BaseColor;           
                }
                if (SpecularLayer > 150 && SpecularLayer < 250)//布料填充高光
                {
                    StepSpecular = step(1 - _StepSpecularWidth3, saturate(dot(normalDirWS, viewDirWS))) * _StepSpecularIntensity3 ;
                    StepSpecular *= BaseColor;
                }
                // ?
                #if ENABLE_HAIR_RAMP_ON  //如果是头发 ，取代高光，如果不是保持
                if (SpecularLayer > 150 && SpecularLayer < 250)//头发高光
                {
                    StepSpecular = step(1 - _StepSpecularWidth3, saturate(dot(normalDirWS, viewDirWS))) * 1 * _StepSpecularIntensity3 ;
                    StepSpecular = lerp(StepSpecular, 0, SpecularIntensityMask);           //反向失去头发高光控制
                    
                    StepSpecular2 = step(1 - _StepSpecularWidth4 * 5, saturate(dot(normalDirWS, viewDirWS))) * SpecularIntensityMask * _StepSpecularIntensity4;
                    StepSpecular2 *= BaseColor;
                    StepSpecular *= BaseColor;

                    // return float4(StepSpecular, 1.0);
                }
                 #endif
                
                if (SpecularLayer >= 250 && SpecularLayer <260)     //金属高光
                {
                    Specular = pow(saturate(ndoth), 1 * _SpecularExp) * SpecularIntensityMask * _SpecularIntensity;
                    Specular = max(0, Specular);
                    Specular += MetalMap;
                    Specular *= BaseColor;
                }

                Specular = lerp(StepSpecular, Specular, LinearMask);
                Specular = lerp(0, Specular, LinearMask);
                Specular = lerp(0, Specular, rampValue);
                // 漫反射和高光输出
                float3 FinalColor = Specular + diffuse;

                // 镜面反射部分测试
                float TestSpecularLayer = step(_TestSpecularLayerController, SpecularLayer);

                
                // Rimlight
                float lambertD = max(0, -lambert);
                float rim = 1 - saturate(dot(viewDirWS, normalDirWS));
                float rimDot = pow(rim, _RimPow);
                rimDot = _EnableLambert * lambert * rimDot + (1 - _EnableLambert) * rimDot;     // 使用兰伯特分离亮暗部
                float rimIntensity = smoothstep(0, _RimSmooth, rimDot);                         // 生成
                half4 Rim = _EnableRim * pow(rimIntensity, 5) * _RimColor * BaseColor;          // 亮面边缘光

                rimDot = pow(rim, _DarkSideRimPow);                                                     //fresnel边缘光延伸
                rimDot = _EnableLambert * lambertD * rimDot + (1 - _EnableLambert) * rimDot;            //阴影面边缘光
                rimIntensity = smoothstep(0, _DarkSideRimSmooth, rimDot);                               //阴影面边缘光平滑
                half4 RimDS = _EnableRim * pow(rimIntensity, 5) * _DarkSideRimColor * BaseColor;
                // Rimlight结果
                half4 RimLight = Rim + RimDS;

                // 光源影响
                Light mainLight = GetMainLight();
                // 最终整合
                FinalColor = Specular + diffuse + RimLight.rgb;
                FinalColor *= mainLight.color;
                
                // 返回结果
                return float4(FinalColor, 1.0);
            }
            ENDHLSL
        }
        Pass
        {
            Name "OutLine"
            Tags{ "LightMode" = "SRPDefaultUnlit" }
	        Cull front
	        HLSLPROGRAM
	        #pragma vertex vert  
	        #pragma fragment frag
	        
	        VertexOutput vert(VertexInput input) {
                float4 scaledScreenParams = GetScaledScreenParams();
                float ScaleX = abs(scaledScreenParams.x / scaledScreenParams.y);//求得X因屏幕比例缩放的倍数
		        VertexOutput output;
		        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
                float3 normalCS = TransformWorldToHClipDir(normalInput.normalWS);//法线转换到裁剪空间
                float2 extendDis = normalize(normalCS.xy) *(_OutlineWidth*0.01);//根据法线和线宽计算偏移量
                extendDis.x /=ScaleX ;//由于屏幕比例可能不是1:1，所以偏移量会被拉伸显示，根据屏幕比例把x进行修正
                output.positionCS = vertexInput.positionCS;
                #if _OLWVWD_ON
                    //屏幕下描边宽度会变
                    output.positionCS.xy +=extendDis;
                #else
                    //屏幕下描边宽度不变，则需要顶点偏移的距离在NDC坐标下为固定值
                    //因为后续会转换成NDC坐标，会除w进行缩放，所以先乘一个w，那么该偏移的距离就不会在NDC下有变换
                    output.positionCS.xy += extendDis * output.positionCS.w ;
                #endif
		        return output;
            }
	        float4 frag(VertexOutput input) : SV_Target {
                 return float4(_OutlineColor.rgb, 1);
	        }
	     ENDHLSL
        }
    }
    Fallback "Universal Render Pipeline/Lit"
}

