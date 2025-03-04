Shader "ALab/RopeShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _Point1 ("Start Point", Vector) = (0,0,0,0)
        _Point2 ("End Point", Vector) = (1,0,0,0)
        _GravityFactor ("Gravity Strength", Float) = 0.5
    }
    
    SubShader
    {
        Cull Off
        
        HLSLINCLUDE
		#pragma target 4.0
		#pragma prefer_hlslcc gles
        #pragma only_renderers d3d11 metal // ensure rendering platforms toggle list is visible
		ENDHLSL
        
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;  // 这里的 uv.x 作为索引值
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float4 _BaseColor;
            float4 _Point1;
            float4 _Point2;
            float _GravityFactor;

            v2f vert(appdata v)
            {
                v2f o;

                float t = v.uv.x; // 使用 UV.x 作为索引

                // 计算绳索的方向向量
                float3 ropeDir = normalize(_Point2.xyz - _Point1.xyz);  // 从端点 1 指向端点 2 的方向
                float ropeLength = distance(_Point1.xyz, _Point2.xyz);  // 计算绳索长度
                float3 baseWorldPos = _Point1.xyz + ropeDir * (t * ropeLength);  // 计算绳索线性插值位置

                // 计算绳索的“右方向”（宽度方向）
                float3 upDir = float3(0, 1, 0);  // 假设世界 Y 轴为上
                float3 ropeRight = normalize(cross(upDir, ropeDir));  // 计算右方向（横向宽度方向）

                // 计算局部偏移
                float3 localOffset = v.position.x * ropeRight + v.position.y * upDir;  // 保持横向 & 垂直偏移

                // 计算最终世界坐标
                float3 worldPos = baseWorldPos + localOffset;

                // 计算重力形变
                float midPointFactor = sin(t * 3.14159);  // 形成中间下垂形态
                worldPos.y -= _GravityFactor * midPointFactor;  // 仅影响 Y 轴

                // 转换到裁剪空间
                o.position = TransformWorldToHClip(worldPos);
                o.uv = v.uv;
                return o;
            }
            
            half4 frag(v2f i) : SV_Target
            {
                return _BaseColor;
            }
            ENDHLSL
        }
    }
}
