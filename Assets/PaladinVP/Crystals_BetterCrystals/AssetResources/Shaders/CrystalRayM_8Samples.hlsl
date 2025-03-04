	void MyCustomRaymarching_float( float3 ViewDirection,
									float3 Position,
									float Refraction,
									float3 NormalVector,
									float StepLength,
									UnityTexture2D CustomVolumeNoise,
									UnitySamplerState CustomVolumeNoiseSampler,
									float VolumeNoiseScale,
									float NoiseStrength,
									float NoisePow,
									float RefractionSurfaceNoise,
									float VolumeNoise2Exp,
									float VolumeNoise2Multiply,
									float LinearMaskScale,
									float LinearMaskNegate,
									float LinearMaskOffset,
									float3 LinearMaskVector,
									float3 LinearMaskVectorWorldOffset,
									out float2 outputpom 
									)
	{
		float step = 0.0;
		float final = 0.0;
		float final2 = 0.0;
		float3 sampledPosition;

		for (int i = 0; i < 8; i++)
			{
				sampledPosition = Position + refract(normalize(ViewDirection), NormalVector, saturate(1-(1.0/Refraction * RefractionSurfaceNoise))) * step;
				
				float2 sampledCustomNoise =SAMPLE_TEXTURE2D(CustomVolumeNoise, CustomVolumeNoiseSampler, sampledPosition.xy * VolumeNoiseScale) * SAMPLE_TEXTURE2D(CustomVolumeNoise, CustomVolumeNoiseSampler, sampledPosition.zy * VolumeNoiseScale + float2(144.23, 5444.12));
				sampledCustomNoise *= SAMPLE_TEXTURE2D(CustomVolumeNoise, CustomVolumeNoiseSampler, sampledPosition.xz * VolumeNoiseScale + float2(3127.11, 1522.12));

				float linearMask = saturate(saturate((dot(sampledPosition - LinearMaskVectorWorldOffset, LinearMaskVector) + LinearMaskOffset) * LinearMaskScale) + LinearMaskNegate);

				final += pow(saturate((pow(sampledCustomNoise.x, NoisePow) * NoiseStrength * 1.45)), 1.25) * saturate(1.0-(i/20.0)) * linearMask;
				final2 += pow(sampledCustomNoise.y, VolumeNoise2Exp * 0.95) * VolumeNoise2Multiply * 2.00 * linearMask;

				step += (StepLength/8.0);
			}

		outputpom.x = final;
		outputpom.y = final2;
	}