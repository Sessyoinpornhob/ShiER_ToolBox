using UnityEngine;
using UnityEditor;
using System.IO;

public class TextureCombiner : MonoBehaviour
{
    [MenuItem("Tools/ShiERToolBox/VAT/Combine Textures Y-axis")]
    public static void CombineSelectedTextures()
    {
        // 获取选中的Texture2D对象
        Object[] selectedObjects = Selection.objects;
        Texture2D[] textures = new Texture2D[selectedObjects.Length];
        for (int i = 0; i < selectedObjects.Length; i++)
        {
            textures[i] = selectedObjects[i] as Texture2D;
        }

        // 合成纹理并保存
        string folderPath = "Assets/AnimMapBaker/CombinedTextures";
        string newTextureName = "CombinedTexture";
        CombineTexturesY(textures, folderPath, newTextureName);
    }
    
    
    private static void CombineTexturesY(Texture2D[] textures, string folderPath, string newTextureName)
    {
        if (textures == null || textures.Length == 0)
        {
            Debug.LogError("No textures to combine.");
            return;
        }

        // Assuming all textures have the same width and format
        int width = textures[0].width;
        int height = 0;
        TextureFormat format = textures[0].format;

        // Calculate the total height
        foreach (Texture2D tex in textures)
        {
            height += tex.height;
        }

        // Create a new texture with the combined height
        Texture2D combinedTexture = new Texture2D(width, height, format, false);

        // Copy the pixels from the source textures to the new texture
        int offsetY = 0;
        foreach (Texture2D tex in textures)
        {
            Color[] pixels = tex.GetPixels();
            combinedTexture.SetPixels(0, offsetY, tex.width, tex.height, pixels);
            offsetY += tex.height;
        }

        // Apply changes to the new texture
        combinedTexture.Apply();

        // Save the combined texture as an asset
        string path = Path.Combine(folderPath, newTextureName + ".asset");
        AssetDatabase.CreateAsset(combinedTexture, path);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log("Combined texture saved to: " + path);
    }
}