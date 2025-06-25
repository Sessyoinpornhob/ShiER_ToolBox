// Example.cginc

// 常量定义


static const float PI = 3.14159265359;
// 共享函数示例
float4 ExampleFunction(float4 color)
{
    return color * 0.5;
}
// 宏定义示例
#define MULTIPLY_COLOR(color, factor) (color * factor)
