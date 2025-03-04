using UnityEngine;


public class RopeController : MonoBehaviour
{
    public Transform point1;
    public Transform point2;
    // public int segmentCount = 10; // 绳索上的点数
    public float gravityStrength = 0.5f;
    private Material ropeMaterial;

    void Start()
    {
        ropeMaterial = GetComponent<Renderer>().sharedMaterial;
    }

    void Update()
    {
        if (ropeMaterial)
        {
            ropeMaterial.SetVector("_Point1", point1.position);
            ropeMaterial.SetVector("_Point2", point2.position);
            ropeMaterial.SetFloat("_GravityFactor", gravityStrength);
        }
    }
}