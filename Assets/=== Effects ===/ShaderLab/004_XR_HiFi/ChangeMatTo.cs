using System.Collections.Generic;
// using Sirenix.OdinInspector;
using UnityEngine;

public class ChangeMatTo : MonoBehaviour
{
    public Material targetMat;
    public List<Material> Materials = new List<Material>();

    // [Button]
    public void ChangeMatToThis()
    {
        var renderer = transform.GetComponent<Renderer>();
        for (int i = 0; i < renderer.sharedMaterials.Length; i++)
        {
            Materials.Add(targetMat);
        }
        renderer.SetSharedMaterials(Materials);
        Materials.Clear();
        
    }
}
