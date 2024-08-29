using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// Boid 类用于模拟群体行为中的一个个体
public class Boid : MonoBehaviour {

    // Boid的设定参数，比如速度，权重等
    BoidRefSettings _refSettings;

    // 状态
    [HideInInspector] // 在Inspector中隐藏该变量
    public Vector3 position; // Boid 的当前位置
    [HideInInspector]
    public Vector3 forward; // Boid 当前的前进方向
    Vector3 velocity; // Boid 的当前速度

    // 更新时用到的变量
    Vector3 acceleration; // 加速度
    [HideInInspector]
    public Vector3 avgFlockHeading; // 群体中的平均朝向
    [HideInInspector]
    public Vector3 avgAvoidanceHeading; // 群体中的平均避让方向
    [HideInInspector]
    public Vector3 centreOfFlockmates; // 群体中其他个体的中心位置
    [HideInInspector]
    public int numPerceivedFlockmates; // 感知到的群体成员数量

    // 缓存的变量
    Material material; // Boid 的材质，用于改变颜色
    Transform cachedTransform; // 缓存的Transform，提高性能
    Transform target; // 目标位置

    // 在对象创建时调用，缓存一些组件和信息
    void Awake () {
        material = transform.GetComponentInChildren<MeshRenderer>().material; // 获取Boid的材质
        cachedTransform = transform; // 缓存Transform
    }

    // 初始化Boid，传入设定和目标
    public void Initialize (BoidRefSettings refSettings, Transform target) {
        this.target = target;
        this._refSettings = refSettings;

        position = cachedTransform.position; // 初始化位置
        forward = cachedTransform.forward; // 初始化方向

        float startSpeed = (refSettings.minSpeed + refSettings.maxSpeed) / 2; // 初始速度为最小速度和最大速度的中间值
        velocity = transform.forward * startSpeed; // 初始化速度
    }

    // 设置Boid的颜色
    public void SetColour (Color col) {
        if (material != null) {
            material.color = col;
        }
    }

    // 更新Boid的状态
    public void UpdateBoid () {
        Vector3 acceleration = Vector3.zero; // 初始化加速度

        // 如果有目标，计算指向目标的加速度
        if (target != null) {
            Vector3 offsetToTarget = (target.position - position);
            acceleration = SteerTowards(offsetToTarget) * _refSettings.targetWeight; // 根据目标权重调整加速度
        }

        // 如果感知到了其他群体成员，计算对齐、聚合和分离的加速度
        if (numPerceivedFlockmates != 0) {
            centreOfFlockmates /= numPerceivedFlockmates; // 计算群体中心

            Vector3 offsetToFlockmatesCentre = (centreOfFlockmates - position); // 计算到群体中心的方向

            var alignmentForce = SteerTowards(avgFlockHeading) * _refSettings.alignWeight; // 对齐
            var cohesionForce = SteerTowards(offsetToFlockmatesCentre) * _refSettings.cohesionWeight; // 聚合
            var seperationForce = SteerTowards(avgAvoidanceHeading) * _refSettings.seperateWeight; // 分离

            acceleration += alignmentForce;
            acceleration += cohesionForce;
            acceleration += seperationForce;
        }

        // 如果有碰撞风险，计算避让的加速度
        if (IsHeadingForCollision ()) {
            Vector3 collisionAvoidDir = ObstacleRays(); // 找到避让方向
            Vector3 collisionAvoidForce = SteerTowards(collisionAvoidDir) * _refSettings.avoidCollisionWeight; // 根据避让权重调整加速度
            acceleration += collisionAvoidForce;
        }

        // 更新速度和方向
        velocity += acceleration * Time.deltaTime; // 加速度更新速度
        float speed = velocity.magnitude;
        Vector3 dir = velocity / speed;
        speed = Mathf.Clamp(speed, _refSettings.minSpeed, _refSettings.maxSpeed); // 限制速度在最小和最大值之间
        velocity = dir * speed;

        // 更新位置和前进方向
        cachedTransform.position += velocity * Time.deltaTime;
        cachedTransform.forward = dir;
        position = cachedTransform.position;
        forward = dir;
    }

    // 判断Boid是否朝向会发生碰撞的方向
    bool IsHeadingForCollision () {
        RaycastHit hit;
        // 使用球形射线检测前方是否有障碍物
        if (Physics.SphereCast(position, _refSettings.boundsRadius, forward, out hit, _refSettings.collisionAvoidDst, _refSettings.obstacleMask)) {
            Debug.Log(hit.collider.transform.name);
            return true;
        } else {
            return false;
        }
    }

    // 找到避开障碍物的方向
    Vector3 ObstacleRays () {
        Vector3[] rayDirections = BoidHelper.directions; // 预定义的多个射线方向

        // 检测各个方向是否安全
        for (int i = 0; i < rayDirections.Length; i++) {
            Vector3 dir = cachedTransform.TransformDirection(rayDirections[i]);
            Ray ray = new Ray(position, dir);
            if (!Physics.SphereCast(ray, _refSettings.boundsRadius, _refSettings.collisionAvoidDst, _refSettings.obstacleMask)) {
                return dir; // 如果找到安全方向，则返回该方向
            }
        }

        return forward; // 如果没有安全方向，则继续前进
    }

    // 计算指向某个方向的加速度
    Vector3 SteerTowards (Vector3 vector) {
        Vector3 v = vector.normalized * _refSettings.maxSpeed - velocity;
        return Vector3.ClampMagnitude(v, _refSettings.maxSteerForce); // 限制转向力的大小
    }

}
