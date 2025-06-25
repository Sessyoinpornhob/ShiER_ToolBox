Shader "Unlit/Glass"
{
    Properties
    {
        [Toggle]_Debug("Debug", Int) = 0
        _MainTex ("Texture", 2D) = "white" {}
        _MainTex_Tilling_Offset ("MainTex_Tilling_Offset", Float) = (1,1,1,1)
        _Size ("Size", float) = 1
        _T ("Time", float) = 1
        _Speed ("Speed", float) = 1
        _Distortion ("Distortion", Range(-5, 5)) = 1
        _Blur ("Blur", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_features _DEBUG_ON
            // make fog work
            #pragma multi_compile_fog
            #define S(a,b,t) smoothstep(a,b,t)
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_Tilling_Offset;
            float _Size, _T, _Speed, _Distortion, _Blur;
            int _Debug;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // 一种生成随机数的方案 通过大量乘法返回小数 让结果随机化
            float N21(float2 p)
            {
                p = frac(p * float2(123.34, 345.45));
                p += dot(p, p + 34.345);
                return frac(p.x * p.y);                             // frac() 返回小数
            }

            float3 Layer(float2 UV, float t)
            {
                float2 aspect = float2(2, 1);
                // float2 aspect = float2(1, 2);
                float2 uv = UV * _Size * aspect;
                uv.y += t * 0.25;                                   // 通过移动格子让雨滴有不同的下落速度
                float2 gv = frac(uv) - 0.5;
                float2 id = floor(uv);


                float n = N21(id);                                  // random number from 0 to 1
                t += n * 6.2831;                                    // 偏移每个grid的时间
                
                float w = UV.y * 10;                              // 根据v轴计算偏移
                float x = (n - 0.5) * 0.8;                          // 随机雨滴位置 -0.4->0.4
                x += (0.4 - abs(x)) * sin(3 * w) * pow(sin(w), 6) * 0.45;
                // 另一个神奇的雨滴左右偏移函数 基于雨点在grid的x位置控制左右偏移函数的强度
                // https://www.desmos.com/calculator?lang=zh-CN
                
                float y = - sin(t+sin(t+sin(t) * 0.5)) * 0.45;      // 一个神奇的函数快下慢上
                y -= (gv.x - x) * (gv.x - x);                       // 控制雨滴的形状

                float2 dropPos = (gv - float2(x, y))/aspect;
                float drop = S(0.05, 0.03, length(dropPos));        // length 计算向量长度

                float2 trailPos = (gv - float2(x, t * 0.25))/aspect;
                trailPos.y = (frac(trailPos.y * 8) - 0.5) / 8;      // 计算水珠痕迹
                float trail = S(0.03, 0.01, length(trailPos));      // length 计算向量长度
                float fogTrail = S(-0.05, 0.05, dropPos.y);         // 每个格子其实是 -0.5 -> 0.5
                fogTrail *= S(0.5, y, gv.y);                        // 每个格子从上到下渐显 从0.5->雨滴，根据gv.y的值由黑到白
                trail *= fogTrail;
                fogTrail *= S(0.05, 0.04, abs(dropPos.x));          // 控制fogTrail的宽度
                

                // col += fogTrail * 0.5;
                // col += trail;
                // col += drop;

                float2 offs = drop * dropPos + trail * trailPos;
                // col.rg = gv;
                // if (gv.x > 0.48 || gv.y > 0.49){ col = float4(1,0,0,1); }
                // col *= 0; col += N21(id); // col.rg = id * .1;

                return float3(offs, fogTrail);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = fmod(_Time.y * _Speed + _T, 7200);                   // float 当数值过大的时候会有精度bug 因此每2h重置
                
                float4 col = 0;

                // 多加几层
                float3 drops = Layer(i.uv, t);
                drops += Layer(i.uv * 1.2 + 1.5, t);                        // 随机化
                drops += Layer(i.uv * 1.15 - 0.5, t * 1.1);
                drops += Layer(i.uv * 0.95 + 0.5, t * 0.9);

                float blur = _Blur * 7 * (1 - drops.z);

                // 自己为了换图 加的东西 直接取场景的话建议把这段删掉。
                float2 texuv = i.uv * _MainTex_Tilling_Offset.xy + _MainTex_Tilling_Offset.zw;
                // col = tex2Dlod(_MainTex, float4(texuv + drops.xy * _Distortion, 0, blur));


                if (_Debug)
                {
                    col = tex2Dlod(_MainTex, float4(texuv + drops.xy * _Distortion, 0, blur));
                }
                return col;
            }
            ENDCG
        }
    }
}
