using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    private float speed;
    public float _Speed;

    // Update is called once per frame
    void Update()
    {
        speed += Time.deltaTime * _Speed;
        transform.rotation = Quaternion.Euler(0,speed,0);
        
    }
}
