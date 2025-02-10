//
// SideFx Labs VAT（顶点动画纹理）辅助函数
//

// 使用单位四元数旋转一个向量
float3 VAT_RotateVector(float3 v, float4 q)
{
    // 通过四元数计算旋转后的向量
    return v + cross(2 * q.xyz, cross(q.xyz, v) + q.w * v);
}

// 计算给定顶点的纹理采样点
int3 VAT_GetSamplePoint(Texture2D map, float2 uv, float current, float total)
{
    int t_w, t_h;
    // 获取纹理的宽度和高度 hlsl方法
    map.GetDimensions(t_w, t_h);
    // t_w->width t_h->height

    // 确保当前帧在有效范围内
    int frame = clamp(current, 0, total - 1); 
    // 计算每一帧的步长
    int stride = t_h / total;

    // 根据 UV 坐标、当前帧和步长计算采样点
    return int3(uv.x * t_w, uv.y * t_h - frame * stride, 0);
}

// 坐标系转换（右手 Z-up -> 左手 Y-up）
float3 VAT_ConvertSpace(float3 v)
{
    // 将 Z-up 转换为 Y-up（改变 x、y 和 z 的顺序）
    return v.xzy * float3(-1, 1, 1);
}

// 解码一个 alpha 打包的 3D 向量
float3 VAT_UnpackAlpha(float a)
{
    // 获取 alpha 的高 5 位和低 5 位
    float a_hi = floor(a * 32);
    float a_lo = a * 32 * 32 - a_hi * 32;

    // 根据高低位计算归一化的向量
    float2 n2 = float2(a_hi, a_lo) / 31.5 * 4 - 2;
    float n2_n2 = dot(n2, n2);
    float3 n3 = float3(sqrt(1 - n2_n2 / 4) * n2, 1 - n2_n2 / 2);

    // 返回解码后的 3D 向量并限制在 -1 到 1 之间
    return clamp(n3, -1, 1);
}

// 用于软体 VAT 的顶点函数
void SoftVAT_float(
    float3 position,             // 当前顶点位置
    float2 uv1,                  // 当前顶点的 UV 坐标
    Texture2D positionMap,       // 位置贴图（顶点动画）
    Texture2D normalMap,         // 法线贴图
    float2 bounds,               // 位置范围（用于插值）
    float totalFrame,            // 总帧数
    float currentFrame,          // 当前帧数
    out float3 outPosition,      // 输出的顶点位置
    out float3 outNormal         // 输出的法线
)
{
    // 获取纹理采样点
    int3 tsp = VAT_GetSamplePoint(positionMap, uv1, currentFrame, totalFrame);
    // 从位置贴图中加载当前位置数据
    float4 p = positionMap.Load(tsp);

    // 通过插值计算出新位置，并应用坐标系转换
    outPosition = position + VAT_ConvertSpace(lerp(bounds.x, bounds.y, p.xyz));

#ifdef _PACKED_NORMAL_ON
    // 如果启用了打包法线，则从 alpha 值中解包法线
    outNormal = VAT_ConvertSpace(VAT_UnpackAlpha(p.w));
#else
    // 否则从法线贴图加载法线
    outNormal = VAT_ConvertSpace(normalMap.Load(tsp).xyz);
#endif
}

// 用于流体 VAT 的顶点函数
void FluidVAT_float(
    float2 uv0,                  // 当前顶点的 UV 坐标
    Texture2D positionMap,       // 位置贴图
    Texture2D normalMap,         // 法线贴图
    float2 bounds,               // 位置范围（用于插值）
    float totalFrame,            // 总帧数
    float currentFrame,          // 当前帧数
    out float3 outPosition,      // 输出的顶点位置
    out float3 outNormal         // 输出的法线
)
{
    // 获取纹理采样点
    int3 tsp = VAT_GetSamplePoint(positionMap, uv0, currentFrame, totalFrame);
    // 从位置贴图中加载当前位置数据
    float4 p = positionMap.Load(tsp);

    // 通过插值计算出新位置，并应用坐标系转换
    outPosition = VAT_ConvertSpace(lerp(bounds.x, bounds.y, p.xyz));

#ifdef _PACKED_NORMAL_ON
    // 如果启用了打包法线，则从 alpha 值中解包法线
    outNormal = VAT_ConvertSpace(VAT_UnpackAlpha(p.w));
#else
    // 否则从法线贴图加载法线
    outNormal = VAT_ConvertSpace(normalMap.Load(tsp).xyz);
#endif
}

// 用于刚体 VAT 的顶点函数
void RigidVAT_float(
    float3 position,             // 当前顶点位置
    float3 normal,               // 当前顶点法线
    float3 color,                // 当前顶点颜色（用来计算旋转枢轴）
    float2 uv1,                  // 当前顶点的 UV 坐标
    Texture2D positionMap,       // 位置贴图
    Texture2D rotationMap,       // 旋转贴图
    float4 bounds,               // 位置和旋转范围（用于插值）
    float totalFrame,            // 总帧数
    float currentFrame,          // 当前帧数
    out float3 outPosition,      // 输出的顶点位置
    out float3 outNormal         // 输出的法线
)
{
    // 获取纹理采样点
    int3 tsp = VAT_GetSamplePoint(positionMap, uv1, currentFrame, totalFrame);
    // 从位置贴图加载位置数据
    float4 p = positionMap.Load(tsp);
    // 从旋转贴图加载旋转数据
    float4 r = rotationMap.Load(tsp);

    // 计算位置偏移
    float3 offs = VAT_ConvertSpace(lerp(bounds.x, bounds.y, p.xyz));

    // 计算旋转枢轴点（从顶点颜色计算）
    float3 pivot = VAT_ConvertSpace(lerp(bounds.z, bounds.w, color));

    // 计算旋转四元数（旋转值从纹理中获取）
    float4 rot = (r * 2 - 1).xzyw * float4(-1, 1, 1, 1);

    // 输出旋转后的顶点位置和法线
    outPosition = VAT_RotateVector(position - pivot, rot) + pivot + offs;
    outNormal = VAT_RotateVector(normal, rot);
}
