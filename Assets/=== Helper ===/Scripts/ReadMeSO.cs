using UnityEngine;

[CreateAssetMenu(fileName = "-README-", menuName = "ShiERTools/README", order = 120)]
public class ReadMeSO : ScriptableObject
{
    public string name;
    
    [TextArea(5, 20)]
    public string description;
    
    public string lastUpdated;
}