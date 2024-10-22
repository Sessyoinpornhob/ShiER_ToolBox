﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "NewBoidTestSettings", menuName = "Boid/Boid Test Settings")]
public class BoidsTestSettings : ScriptableObject {
    // // Settings
    public float minSpeed = 2;
    public float maxSpeed = 5;
    public float viewRadius = 5;
    public float avoidRadius = 1;
    public float maxSteerForce = 3;
    //
    public float alignWeight = 1;
    public float cohesionWeight = 1;
    public float seperateWeight = 1;
    //
    public float targetWeight = 1;
    
    //
    [Header ("Collisions")]
    public LayerMask obstacleMask;
    public float boundsRadius = .27f;
    public float avoidCollisionWeight = 10;
    public float collisionAvoidDst = 5;
    
    [Header("ObstacleRays")][SerializeField]
    public Vector3[] presetDirections;
    

}