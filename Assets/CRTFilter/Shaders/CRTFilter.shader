Shader "Hidden/CRTFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			static const half pi = 3.141592653589793238462;

			half2 m_pixSize;

            uniform float m_time;
			uniform fixed m_screenBend;
			uniform fixed m_screenOverscan;
			uniform fixed m_blur;
			uniform fixed m_smidge;
			uniform fixed m_bleedr;
			uniform fixed m_bleedg;
			uniform fixed m_bleedb;
			uniform fixed m_resX;
			uniform fixed m_resY;
			uniform fixed m_scanlinesStrength;
			uniform fixed m_apertureStrength;
			uniform fixed m_shadowlines;			
			uniform fixed m_shadowlinesSpeed;
			uniform fixed m_shadowlinesAlpha;
			uniform fixed m_vignetteSize;
			uniform fixed m_vignetteSmooth;
			uniform fixed m_vignetteRound;
			uniform fixed m_noiseSize;
			uniform fixed m_noiseAlpha;
			uniform fixed m_noiseSpeed;
			uniform fixed m_brightness;
			uniform fixed m_contrast;
			uniform fixed m_gamma;
			uniform fixed m_red;
			uniform fixed m_green;
			uniform fixed m_blue;
			uniform fixed2 m_redOffset;
			uniform fixed2 m_greenOffset;
			uniform fixed2 m_blueOffset;

			half2 pixel_size()
			{
				return half2((_MainTex_TexelSize.z / m_resX) * _MainTex_TexelSize.x, (_MainTex_TexelSize.w / m_resY) * _MainTex_TexelSize.y);				
			}

			half2 pixel_part(half2 uv)
			{
				return half2(floor(fmod(uv.x, m_pixSize.x) * _MainTex_TexelSize.z), floor(fmod(uv.y, m_pixSize.y) * _MainTex_TexelSize.w));
			}
			half pixel_part_x(half uvx)
			{
				return floor(fmod(uvx, m_pixSize.x) * _MainTex_TexelSize.z);
			}
			half pixel_part_y(half uvy)
			{
				return floor(fmod(uvy, m_pixSize.y) * _MainTex_TexelSize.w);
			}

			half2 pixel_frac(half2 uv)
			{
				return half2(fmod(uv.x, m_pixSize.x) * m_resX, fmod(uv.y, m_pixSize.y) * m_resY);
			}
			half pixel_frac_x(half uvx)
			{
				return fmod(uvx, m_pixSize.x) * m_resX;
			}
			half pixel_frac_y(half uvy)
			{
				return fmod(uvy, m_pixSize.y) * m_resY;
			}

			fixed2 pixel_num(half2 uv)
			{
				return fixed2(floor(uv.x / m_pixSize.x), floor(uv.y / m_pixSize.y));
			}
			fixed pixel_num_x(half uvx)
			{
				return floor(uvx / m_pixSize.x);
			}
			fixed pixel_num_y(half uvy)
			{
				return floor(uvy / m_pixSize.y);
			}

            half random (half2 uv)
            {
                return frac(sin(dot(uv,half2(12.4898,78.233)))	* 43758.541987 * sin(m_time * m_noiseSpeed));
            }

			half noise(half2 uv)
			{
				half2 i = floor(uv);
				half2 f = frac(uv);

				half a = random(i);
				half b = random(i + half2(1., 0.));
				half c = random(i + half2(0, 1.));
				half d = random(i + half2(1., 1.));

				half2 u = smoothstep(0., 1., f);

				return lerp(a, b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;
			}

			half vignette(half2 uv)
			{
				uv -= .5;
				uv *= m_vignetteSize;
				half amount = 1. - sqrt(pow(abs(uv.x), m_vignetteRound) + pow(abs(uv.y), m_vignetteRound));				

				return smoothstep(0, m_vignetteSmooth, amount);
			}

			half crt_line(half i, half lines, half speed)
			{
				return sin(i * lines * pi + speed * m_time);
			}

			half2 screen_bend(half2 uv)
			{
				uv -= 0.5;
				uv *= 2.;
				uv.x *= 1. + pow(uv.y / m_screenBend, 2.) - m_screenOverscan;
				uv.y *= 1. + pow(uv.x / m_screenBend, 2.) - m_screenOverscan;
				uv /= 2.;
				return uv + 0.5;
			}

			fixed4 blur (fixed4 col, half2 uv)
            {                
				col += tex2D(_MainTex, uv + half2(m_blur, m_blur));
                col += tex2D(_MainTex, uv + half2(m_blur, -m_blur));
                col += tex2D(_MainTex, uv + half2(-m_blur, m_blur));
                col += tex2D(_MainTex, uv + half2(-m_blur, -m_blur));
                col /= 5.;
                
                return col;
            }

			fixed weight(fixed4 color)
			{
				return max(max(color.r * m_bleedr, color.g * m_bleedg), color.b * m_bleedb);
			}

			fixed4 bleed(fixed4 col, half2 uv)
            {
				fixed side2 = ceil((_MainTex_TexelSize.z / m_resX) / 2.);
				fixed side1 = side2 - 1;

				fixed s = 2.;
				col *= s;

				fixed4 bld = tex2D(_MainTex, uv + half2(_MainTex_TexelSize.x * side1, 0));
				fixed w = weight(bld);
				col += bld * w;
				s += min(w, 1.);

				bld = tex2D(_MainTex, uv + half2(_MainTex_TexelSize.x * side2, 0));
				w = weight(bld);
				col += bld * w;
				s += min(w, 1.);

				bld = tex2D(_MainTex, uv - half2(_MainTex_TexelSize.x * side1, 0));
				w = weight(bld);
				col += bld * w;
				s += min(w, 1.);


				bld = tex2D(_MainTex, uv - half2(_MainTex_TexelSize.x * side2, 0));
				w = weight(bld);
				col += bld * w;
				s += min(w, 1.);

				return col / s;
            }

			fixed4 aperture(fixed4 col, half2 uv)
			{
				half odd = fmod(floor(uv.x * _MainTex_TexelSize.z), 2.);

				col *= 1 - odd * m_apertureStrength;
								
				return col;
			}

			fixed4 scanline(fixed4 col, half2 uv)
			{
				return col * lerp(1, max(0.4, sin(pixel_frac_y(uv.y - _MainTex_TexelSize.y / 2.) * pi)), m_scanlinesStrength);
			}

			fixed4 pixelSmidge(fixed4 col, half2 uv)
			{
				fixed4 smgL = tex2D(_MainTex, uv + half2(-m_pixSize.x / 2, -m_pixSize.y));
				fixed4 smgR = tex2D(_MainTex, uv + half2(m_pixSize.x / 2, -m_pixSize.y));
				
				fixed sL = step(0.4, max(smgL.r, max(smgL.g, smgL.b)));
				fixed sR = step(0.4, max(smgR.r, max(smgR.g, smgR.b)));
				smgL *= sL;
				smgR *= sR;
				
				fixed s = abs(sL - sR) * m_smidge;
				s *= 1 - step(0.10, col.r + col.g + col.b);
				s *= 1 - pixel_frac_y(uv.y);

				return col + (smgL + smgR) * s;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				m_pixSize = pixel_size();

				half2 buv = screen_bend(i.uv);
				
				fixed4 col = tex2D(_MainTex, buv);
				
				col = blur(col, buv);

				col.r += tex2D(_MainTex, buv + m_redOffset).r;
				col.g += tex2D(_MainTex, buv + m_greenOffset).g;
				col.b += tex2D(_MainTex, buv + m_blueOffset).b;
				col.rgb /= 2.0f;

				col = bleed(col, buv);
				col = scanline(col, buv);
				col = aperture(col, buv);
				col = pixelSmidge(col, buv);

				col = pow(col, (1 / m_gamma));
				col = m_contrast * (col - 0.5) + 0.5 + m_brightness;

				col.r *= m_red;
				col.g *= m_green;
				col.b *= m_blue;
				
				col = lerp(col, fixed(noise(buv * m_noiseSize)), m_noiseAlpha);
				col = lerp(col, crt_line(buv.y, m_shadowlines, m_shadowlinesSpeed), m_shadowlinesAlpha * max(0, min(1, m_shadowlines)));
				col = lerp(col, crt_line(buv.x, m_shadowlines, m_shadowlinesSpeed), m_shadowlinesAlpha * max(0, min(1, -m_shadowlines)));

				return col * vignette(i.uv);
			}

            ENDCG
        }
    }
}
