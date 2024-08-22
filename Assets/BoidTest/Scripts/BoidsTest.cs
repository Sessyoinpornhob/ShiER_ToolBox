using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


// 这是一个在2d范围的Boids 作为移植到VP上的测试
public class BoidsTest : MonoBehaviour
{
    // Boid的设定参数，比如速度，权重等
    BoidsTestSettings _testSettings;
    
    // 状态
    [HideInInspector] // 在Inspector中隐藏该变量
    public Vector3 position; // Boid 的当前位置
    [HideInInspector]
    public Vector3 forward; // Boid 当前的前进方向
    Vector3 velocity; // Boid 的当前速度
    
    // 缓存变量
    Transform cachedTransform;
    
    private void Awake()
    {
        cachedTransform = transform; // 缓存Transform
    }

    public void Initialize(BoidsTestSettings m_testSettings, Transform target)
    {
        _testSettings = m_testSettings; // 传入设定参数
        position = cachedTransform.position; // 初始化位置
        forward = cachedTransform.forward; // 初始化方向

        float startSpeed = (m_testSettings.minSpeed + m_testSettings.maxSpeed) / 2; // 初始速度为最小速度和最大速度的中间值
        velocity = transform.forward * startSpeed; // 初始化速度
    }
    
    public void UpdateBoids()
    {
        Vector3 acceleration = Vector3.zero; // 初始化加速度
        
        // 更新速度和方向
        velocity += acceleration * Time.deltaTime; // 加速度更新速度
        float speed = velocity.magnitude;
        Vector3 dir = velocity / speed;
        speed = Mathf.Clamp(speed, _testSettings.minSpeed, _testSettings.maxSpeed); // 限制速度在最小和最大值之间
        velocity = dir * speed;

        // 更新位置和前进方向
        cachedTransform.position += velocity * Time.deltaTime;
        cachedTransform.forward = dir;
        position = cachedTransform.position;
        forward = dir;
    }
}
