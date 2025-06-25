Shader "ShiER/Test/URPExampleShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)  // 属性面板中暴露的颜色
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex Vert             // 顶点着色器入口
            #pragma fragment Frag           // 片段着色器入口
            #include "Example.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // Uniforms
            float4 _BaseColor;

            // Input structure for the vertex shader
            struct Attributes
            {
                float4 positionOS : POSITION;   // Object Space 中的位置
                float2 uv : TEXCOORD0;          // UV 坐标
            };

            // Output structure from the vertex shader to the fragment shader
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;   // Homogeneous Clip Space 中的位置
                float2 uv : TEXCOORD0;              // UV 坐标
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);   // 转换为 Homogeneous Clip Space 坐标
                OUT.uv = IN.uv;  // 传递 UV 坐标
                return OUT;
            }

            half4 Frag(Varyings IN) : SV_Target
            {
                // 应用颜色
                // ExampleFunction 是一个自定义的函数，需要在 Example.cginc 头文件中实现
                // 而 URP shader 可以自由使用 .cginc 文件。目前看来，builtin 和 urp 其实之间没有差得太远
                return half4(ExampleFunction(_BaseColor).rgb, 1.0);
            }

            ENDHLSL
        }
    }

    FallBack "Hidden/InternalErrorShader"
}
