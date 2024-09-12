Shader "USB/SDFBlend"
{
	Properties
	{
		_Position ("Circle Position", Range(0, 1)) = 0.5
		_Smooth ("Circle Smooth", Range(0.0, 0.1)) = 0.01
		_k ("K", Range(0.0, 0.5)) = 0.1
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Unlit" }

		Cull Back
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		#pragma only_renderers metal // ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		//---------------------------面板变量------------------------------
		CBUFFER_START(UnityPerMaterial)
		float _Position;
	    float _Smooth;
        float _k;
		CBUFFER_END
		//---------------------------面板变量------------------------------


		#ifndef SDF_Functions
		#define SDF_Functions
		
		float Circle (float2 p, float r)
		{
			float d = length(p) - r;
			d = clamp(0,1,d);
			return d;
		}

		float smin (float a, float b, float k)
		{
			float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
			return lerp(b, a, k) - k * h * (1.0 - h);
		}
		
		#endif
		
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 uv : TEXCOORD2;
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				float4 uv : TEXCOORD2;
			};
			
			VertexOutput vert ( VertexInput v )
			{
				VertexOutput o = (VertexOutput)0;
				o.normalWS = TransformObjectToWorldNormal(v.ase_normal);
				o.clipPos = TransformObjectToHClip( v.vertex.xyz );
				o.positionWS = TransformObjectToWorld(v.vertex.xyz);
				o.uv = v.uv;

				return o;
			}

			half4 frag ( VertexOutput IN) : SV_Target
			{
				float3 ase_normalWS = normalize(IN.normalWS);
				float NDotL = max(0, dot(ase_normalWS, _MainLightPosition.xyz));

				float a = Circle(IN.uv, 0.5);
				float b = Circle(IN.uv - _Position, 0.2);
				float s = 0; // smin(a, b, _k);
				s = max(0, abs(a) * abs(b));
				// s = smin(a, b, _k);

				// float render = smoothstep(a+b - _Smooth, a+b + _Smooth, 0.0);
				float render = smoothstep(s - _Smooth, s + _Smooth, 0);
				return half4(render.xxx, 1);
			}
			ENDHLSL
		}

	
	}
	
	// CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}