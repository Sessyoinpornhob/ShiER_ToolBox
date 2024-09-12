Shader "USB/SphereTracing"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		_InsideTex("Inside Texture",2D) = "white" {}
		_Edge ("Edge", Range(-0.5, 0.5)) = 0.0
		_EdgeA("EdgeA", Range(0,5)) = 1.0
		_EdgeB("EdgeB", Range(-1,0)) = -1.0
		
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
		float4 _MainColor;
		sampler2D _InsideTex;
		float4 _InsideTex_ST;
		float _Edge;
		float _EdgeA;
		float _EdgeB;
		CBUFFER_END
		//----------------------------------------------------------------

		#ifndef Sphere_Trace_Functions
		#define Sphere_Trace_Functions
		
		//	本质上是全局静态变量。
		// maximum of steps to determine the surface intersection
		#define MAX_MARCHING_STEPS 50
		// maximum distance to find the surface intersection
		#define MAX_DISTANCE 10.0
		// surface distance
		#define SURFACE_DISTANCE 0.01
		
		// 生成SDF
		float SphereSDF(float3 p, float radius)
		{
			float sphere = length(p) - radius;
			return sphere;
		}

		// declare the function for the plane
		float planeSDF(float3 ray_position)
		{
			// subtract the edg	e to the “Y” ray position to increase
			// or decrease the plane position
			float plane = ray_position.y - _Edge;
			return plane;
		}

		// 步进球型投影的过程
		float sphereCasting(float3 ray_origin, float3 ray_direction)
		{
			float distance_origin = 0;
			for(int i = 0; i < MAX_MARCHING_STEPS; i++)
			{
				float3 ray_position = ray_origin + ray_direction * distance_origin;
				float distance_scene = planeSDF(ray_position);
				distance_origin += distance_scene;

				// 在这两个条件下，停止步进，结束生成
				if(distance_scene < SURFACE_DISTANCE || distance_origin > MAX_MARCHING_STEPS)
					break;
			}
			return distance_origin;
		}
		
		#endif	// Sphere_Trace_Functions
		
		
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Cull Off
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1

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
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				float3 hitPos : TEXCOORD2;
			};
			
			VertexOutput vert ( VertexInput v )
			{
				VertexOutput o = (VertexOutput)0;
				o.normalWS = TransformObjectToWorldNormal(v.ase_normal);
				o.clipPos = TransformObjectToHClip( v.vertex.xyz );
				o.positionWS = TransformObjectToWorld(v.vertex.xyz);
				o.hitPos = v.vertex;
				return o;
			}

			half4 frag
			(
				VertexOutput IN,
				bool face : SV_isFrontFace
				) : SV_Target
			{
				// halfLambert
				float3 ase_normalWS = normalize(IN.normalWS);
				float halfLambert = (dot(ase_normalWS, _MainLightPosition.xyz) + 1) / 2;

				// float sdf = SphereSDF(IN.position,1);
				// sdf = max(0, sdf);
				
				float3 Color = halfLambert * _MainColor.rgb;
				float Alpha = 1;

				// transform the camera to local-space
				float3 ray_origin = TransformWorldToObject(_WorldSpaceCameraPos);
				// float3 ray_origin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
				
				// calculate the ray direction
				float3 ray_direction = normalize(IN.hitPos - ray_origin);
				
				// use the values in the ray casting function
				float t = sphereCasting(ray_origin, ray_direction);
				
				float4 planeCol = 0;
				if( t < MAX_DISTANCE )
				{
					float3 p = ray_origin + ray_direction * t;
					float2 uv_p = p.xz;
					float l = pow(_Edge, 2) * -1 * _EdgeA + _EdgeB;

					planeCol = tex2D( _InsideTex, uv_p * l * _InsideTex_ST.xy + _InsideTex_ST.zw );
					// planeCol = tex2D( _InsideTex, uv_p * (1 - abs(pow(_Edge * l, 2)) - 0.5) * _InsideTex_ST.xy + _InsideTex_ST.zw );
				}

				// 计算切割表面的位置
				float3 positionOS = TransformWorldToObject(IN.positionWS);
				if (positionOS.y > _Edge)
					discard;
				
				return face ? half4( Color, Alpha ) : planeCol;
			}
			ENDHLSL
		}

	
	}
	
	// CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}