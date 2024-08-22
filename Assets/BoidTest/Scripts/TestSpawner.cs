using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class TestSpawner : MonoBehaviour
{
    public BoidsTest prefab;
    public int spawnCount = 10;
    public float spawnRadius = 10;

    void Awake()
    {
        Vector3 transformPos = transform.position;
        
        for (int i = 0; i < spawnCount; i++)
        {
            Vector3 pos = new Vector3(transformPos.x + Random.insideUnitCircle.x * spawnRadius,
                                        transformPos.y,
                                        transformPos.z + Random.insideUnitCircle.y * spawnRadius);
            Vector3 fwd = new Vector3(Random.insideUnitCircle.x * spawnRadius,
                                        0,
                                        Random.insideUnitCircle.y * spawnRadius);
            BoidsTest boidsTest = Instantiate(prefab);
            boidsTest.transform.position = pos;
            boidsTest.transform.forward = fwd;
        }
    }
}
