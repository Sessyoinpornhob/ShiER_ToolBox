using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;


public class BoidsTestManager : MonoBehaviour 
{
    [FormerlySerializedAs("settings")] public BoidsTestSettings boidsTestSettings;
    BoidsTest[] boidsTests;
    
    void Start () 
    {
        boidsTests = FindObjectsOfType<BoidsTest> ();
        foreach (BoidsTest b in boidsTests) 
        {
            b.Initialize (boidsTestSettings, null);
        }
    }

    // 计算所有的 BoidsTest 和相关条件
    // 更新所有 boids
    private void Update()
    {
        for (int i = 0; i < boidsTests.Length; i++)
        {
            boidsTests[i].UpdateBoids();
        }
    }
}
