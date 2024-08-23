using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
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
            boidsTests[i].numPerceivedFlockmates = 0;
            boidsTests[i].avgFlockHeading = Vector3.zero;
            boidsTests[i].centreOfFlockmates = Vector3.zero;
            boidsTests[i].avgAvoidanceHeading = Vector3.zero;
        }


            
        // 需要计算：群体中心 对齐 聚合 分离
        // numFlockmates
        for (int i = 0; i < boidsTests.Length; i++) {
            for (int j = 0; j < boidsTests.Length; j++) {
                
                Vector3 offset = boidsTests[i].position - boidsTests[j].position;
                float sqrDst = offset.x * offset.x + offset.y * offset.y + offset.z * offset.z;
                // 如果找到范围内部的boids
                if (sqrDst < boidsTestSettings.viewRadius * boidsTestSettings.viewRadius) {
                    boidsTests[i].numPerceivedFlockmates += 1;                      // 范围内鸟群数量
                    boidsTests[i].avgFlockHeading += boidsTests[j].forward;         // 群体平均方向
                    boidsTests[i].centreOfFlockmates += boidsTests[j].position;     // 群体中心

                    if (sqrDst < boidsTestSettings.avoidRadius * boidsTestSettings.avoidRadius) {
                        boidsTests[i].avgAvoidanceHeading -= offset / sqrDst;       // 群体离开方向
                    }
                }
            }
            
            boidsTests[i].UpdateBoids();
        }
    }
}
