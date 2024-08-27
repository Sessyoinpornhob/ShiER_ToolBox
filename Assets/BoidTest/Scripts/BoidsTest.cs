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
    
    // 更新变量
    public int numPerceivedFlockmates;  // 感知数量
    public Vector3 avgFlockHeading; // 群体中的平均朝向
    public Vector3 centreOfFlockmates; // 群体中其他个体的中心位置
    public Vector3 avgAvoidanceHeading; // 群体中的平均避让方向
    
    // 缓存变量
    Transform cachedTransform;
    Transform target; // 目标位置
    
    private void Awake()
    {
        cachedTransform = transform; // 缓存Transform
    }

    public void Initialize(BoidsTestSettings m_testSettings, Transform target)
    {
        this.target = target;
        _testSettings = m_testSettings; // 传入设定参数
        
        position = cachedTransform.position; // 初始化位置
        forward = cachedTransform.forward; // 初始化方向

        float startSpeed = (m_testSettings.minSpeed + m_testSettings.maxSpeed) / 2; // 初始速度为最小速度和最大速度的中间值
        velocity = transform.forward * startSpeed; // 初始化速度
    }
    
    public void UpdateBoids()
    {
        Vector3 acceleration = Vector3.zero; // 初始化加速度
        
        // 如果有目标，计算指向目标的加速度
        if (target != null) {
            Vector3 offsetToTarget = (target.position - position);
            acceleration = SteerTowards(offsetToTarget) * _testSettings.targetWeight; // 根据目标权重调整加速度
        }
        
        // 如果感知到了其他群体成员，计算对齐、聚合和分离的加速度
        if (numPerceivedFlockmates != 0) {
            centreOfFlockmates /= numPerceivedFlockmates; // 计算群体中心
        
            Vector3 offsetToFlockmatesCentre = (centreOfFlockmates - position); // 计算到群体中心的方向

            var alignmentForce = SteerTowards(avgFlockHeading)* _testSettings.alignWeight; // 对齐
            var cohesionForce = SteerTowards(offsetToFlockmatesCentre)* _testSettings.cohesionWeight; // 聚合
            var seperationForce = SteerTowards(avgAvoidanceHeading) * _testSettings.seperateWeight; // 分离
        
            acceleration += alignmentForce;
            acceleration += cohesionForce;
            acceleration += seperationForce;
        }
        
        // 如果有碰撞风险，计算避让的加速度
        if (IsHeadingForCollision ()) {
            Vector3 collisionAvoidDir = ObstacleRays().normalized; // 找到避让方向
            Vector3 collisionAvoidForce = SteerTowards(collisionAvoidDir) * _testSettings.avoidCollisionWeight; // 根据避让权重调整加速度
            acceleration += collisionAvoidForce;
        }
        
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

    void DrawGizmos () {

        Gizmos.color = new Color (1, 1, 1, 0.3f);
        Gizmos.DrawSphere (transform.position, _testSettings.collisionAvoidDst);
    }

    // 计算指向某个方向的加速度
    Vector3 SteerTowards (Vector3 vector) {
        Vector3 v = vector.normalized * _testSettings.maxSpeed - velocity;
        return Vector3.ClampMagnitude(v, _testSettings.maxSteerForce); // 限制转向力的大小
    }
    
    // 判断Boid是否朝向会发生碰撞的方向
    bool IsHeadingForCollision () {
        RaycastHit hit;
        // 使用球形射线检测前方是否有障碍物
        if (Physics.SphereCast(position, _testSettings.boundsRadius, 
                            forward, out hit, _testSettings.collisionAvoidDst, _testSettings.obstacleMask)) 
        {
            // Debug.Log(hit.collider.gameObject.name);    // 撞到wall了
            return true;
        } else {
            return false;
        }
    }
    
    // 找到避让的方向
    Vector3 ObstacleRays () {
        
        // Vector3[] rayDirections = _testSettings.presetDirections; // 预定义的多个射线方向
        List<Vector2> rayDirections = CirclePointsGenerator.GetPointsOnUnitCircle(180, 1f);
        
        // Debug.Log("ObstacleRays is working");
        // 检测各个方向是否安全
        for (int i = 0; i < rayDirections.Count; i++) {
            Vector3 dir = cachedTransform.TransformDirection(rayDirections[i]);
            Ray ray = new Ray(position, dir);
            if (!Physics.SphereCast(ray, _testSettings.boundsRadius, 
                            _testSettings.collisionAvoidDst, _testSettings.obstacleMask)) {
                return dir; // 如果找到安全方向，则返回该方向
            }
        }
        Debug.Log("未能找到安全方向");
        return forward; // 如果没有安全方向，则继续前进
    }
}
