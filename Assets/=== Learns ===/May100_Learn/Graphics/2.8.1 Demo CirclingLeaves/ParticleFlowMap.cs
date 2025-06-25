using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]


public class ParticleFlowMap : MonoBehaviour
{
    public Texture2D flowMap;

    public Vector3 Size = Vector3.one * 10;
    public float Strength = 5;
    public bool Boundary = false;
    public bool Reverse = false;
    private ParticleSystem ps;
    private ParticleSystem.Particle[] particles;

    private void OnEnable()
    {
        ps = GetComponent<ParticleSystem>();
        particles = new ParticleSystem.Particle[ps.main.maxParticles];
    }
    private void LateUpdate()
    {
        int count = ps.GetParticles(particles);
        //Debug.Log(count);
        bool isLocalSpace = ps.main.simulationSpace == ParticleSystemSimulationSpace.Local;
        if (Strength >= 0.0f)
        {
            for (int i = 0; i < count; i++)
            {
                bool inside;

                Vector3 pos = particles[i].position;

                if (isLocalSpace)
                {
                    pos = ps.transform.localToWorldMatrix.MultiplyPoint(pos);
                }

                Vector3 direction = GetDirection(pos, out inside) * Strength;

                if (isLocalSpace)
                {
                    direction = ps.transform.worldToLocalMatrix.MultiplyVector(direction);
                }
                if (inside)
                {
                    particles[i].velocity = direction;
                }
                else if (Boundary)
                {
                    //particles[i].velocity = (direction*-1+ particles[i].velocity)*0.5f;
                    particles[i].remainingLifetime = 0;
                }
                //particles[i].startColor = new Color(direction.x, direction.y, direction.z);
            }
        }
            
        ps.SetParticles(particles);
    }
    /// <summary>
    /// 获取方向
    /// </summary>
    /// <param name="pos"></param>
    public Vector3 GetDirection(Vector3 pos, out bool inside)
    {
        //Vector3 tempPos = transform.localToWorldMatrix.MultiplyPoint(pos) + Size * 0.5f;
        Vector3 tempPos = pos + Size * 0.5f-transform.position;
        inside = true;
        //映射到0~1
        float x = tempPos.x / Size.x;
        float y = tempPos.y / Size.y;
        float z = tempPos.z / Size.z;

        if (x < 0 || x > 1 || z < 0 || z > 1)
        {
            inside = false;
        }
        
        x = Mathf.Clamp01(x);
        y = Mathf.Clamp01(y);
        z = Mathf.Clamp01(z);

        int pixelX = (int)(x * flowMap.width);
        int pixelY = (int)(z * flowMap.height);

        Color col = flowMap.GetPixel(pixelX, pixelY);

        int reverse = Reverse ? -1 : 1;
        Vector3 direction = new Vector3(col.r * 2 - 1, 0, col.g * 2 - 1)* reverse;

        return direction;
    }

    public Vector3 Limit(Vector3 pos)
    {
        return Vector3.zero;
    }
    
    
}
