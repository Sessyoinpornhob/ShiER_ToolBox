

void TestFunc
(
    sampler2D In0,
    SamplerState In1,
    float2 In2
)
{
    TEXTURE2D In0_Tex = TEXTURE2D(In0);
    return SAMPLE_TEXTURE2D(In0_Tex, In1, In2);
}

