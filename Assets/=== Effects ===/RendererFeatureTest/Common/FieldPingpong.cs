// using Animancer;
using UnityEngine;

public class FieldPingpong : MonoBehaviour
{
    const string DISSOLVE = "_Dissolve";

    public float Speed;
    public bool ON = false;
    
    private float pingpongValue = 0f;
    private Renderer _renderer;
    
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        if (transform.gameObject.TryGetComponent(out Renderer renderer))
        {
            // renderer.material.SetFloat(DISSOLVE, 1f);
            _renderer = renderer;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (ON)
        {
            if (_renderer)
            {
                pingpongValue = Mathf.Sin(Time.time * Speed) + 0.5f;
                _renderer.sharedMaterial.SetFloat(DISSOLVE, pingpongValue);
            }
        }
    }
    
}
