
void CustomGradient_half(
    Gradient Gradient, 
    half Time, 
    half type,
    half colorsLength,
    half alphasLength,
    half4 Color0,
    half4 Color1,
    half4 Color2,
    half4 Color3,
    half4 Color4,
    half4 Color5,
    half4 Color6,
    half4 Color7,
    half2 Alpha0,
    half2 Alpha1,
    half2 Alpha2,
    half2 Alpha3,
    half2 Alpha4,
    half2 Alpha5,
    half2 Alpha6,
    half2 Alpha7,
    out half4 Out)
{
    Gradient = NewGradient(type, colorsLength, alphasLength, Color0,Color1,Color2,Color3,Color4,Color5,Color6,Color7, 
    Alpha0,Alpha1,Alpha2,Alpha3,Alpha4,Alpha5,Alpha6,Alpha7);

    half3 color = Gradient.colors[0].rgb;
    [unroll]
    for (int c = 1; c < colorsLength; c++)
    {
        half colorPos = saturate((Time - Gradient.colors[c-1].w) / (Gradient.colors[c].w - Gradient.colors[c-1].w)) * step(c, Gradient.colorsLength-1);
        color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
    }
    #ifndef UNITY_COLORSPACE_GAMMA
        color = SRGBToLinear(color);
    #endif
    half alpha = Gradient.alphas[0].x;
    [unroll]
    for (int a = 1; a < alphasLength; a++)
    {
        half alphaPos = saturate((Time - Gradient.alphas[a-1].y) / (Gradient.alphas[a].y - Gradient.alphas[a-1].y)) * step(a, Gradient.alphasLength-1);
        alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
    }
    Out = half4(color, alpha);
}