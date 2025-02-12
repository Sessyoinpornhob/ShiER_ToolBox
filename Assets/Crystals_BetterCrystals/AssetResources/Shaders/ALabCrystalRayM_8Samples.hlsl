	float2 ALabCrystalRayM_8Samples( float3 ViewDirection,
									float3 Position,
									float Refraction,
									float3 NormalVector,
									float StepLength,
									sampler2D CustomVolumeNoise,
									SamplerState samplerState,
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
									float3 LinearMaskVectorWorldOffset
									)
	{
		float step = 0.0;
		float final = 0.0;
		float final2 = 0.0;
		float3 sampledPosition;
		


		for (int i = 0; i < 8; i++)
			{
				sampledPosition = Position + refract(normalize(ViewDirection), NormalVector, saturate(1-(1.0/Refraction * RefractionSurfaceNoise))) * step;
			
				float2 sampledCustomNoise = SAMPLE_TEXTURE2D(CustomVolumeNoise, samplerState, sampledPosition.xy * VolumeNoiseScale).rgb * SAMPLE_TEXTURE2D(CustomVolumeNoise, samplerState, sampledPosition.zy * VolumeNoiseScale + float2(144.23, 5444.12)).rgb;
			
				sampledCustomNoise *= SAMPLE_TEXTURE2D(CustomVolumeNoise, samplerState, sampledPosition.xz * VolumeNoiseScale + float2(3127.11, 1522.12));

				float linearMask = saturate(saturate((dot(sampledPosition - LinearMaskVectorWorldOffset, LinearMaskVector) + LinearMaskOffset) * LinearMaskScale) + LinearMaskNegate);

				final += pow(saturate((pow(sampledCustomNoise.x, NoisePow) * NoiseStrength * 1.45)), 1.25) * saturate(1.0-(i/20.0)) * linearMask;
				final2 += pow(sampledCustomNoise.y, VolumeNoise2Exp * 0.95) * VolumeNoise2Multiply * 2.00 * linearMask;

				step += (StepLength/8.0);
			}

		float2 outputpom;
		outputpom.x = final;
		outputpom.y = final2;
		return outputpom;
}
	