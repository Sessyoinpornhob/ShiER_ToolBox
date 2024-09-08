#if UNITY_EDITOR

using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class GradientGUIM : ShaderGUI
{
    [GradientUsageAttribute(true)]
    public Gradient Gradient = new Gradient();
    List<string> HideInspectorList = new List<string>();
    GUIContent Label = new GUIContent();
    GUILayoutOption[] options;
    
    #region Utilities

    static GUIStyle boxScopeStyle;
    public static GUIStyle BoxScopeStyle
    {
        get
        {
            if (boxScopeStyle == null)
            {
                boxScopeStyle = new GUIStyle(EditorStyles.helpBox);
                var p = boxScopeStyle.padding;
                p.right += 6;
                p.top += 1;
                p.left += 3;
            }
            return boxScopeStyle;
        }
    }

    static GUIStyle toonLabelStyle;
    public static GUIStyle ToonLabelStyle
    {
        get
        {
            if (toonLabelStyle == null)
            {
                toonLabelStyle = new GUIStyle(EditorStyles.whiteLargeLabel);
                var p = toonLabelStyle.fontStyle = FontStyle.Bold;
            }
            return toonLabelStyle;
        }
    }
    #endregion

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        HideInspectorList.Clear(); //初始化隐藏列表
        HideInspectorList.Add("_QueueOffset");
        HideInspectorList.Add("_QueueControl");
        HideInspectorList.Add("unity_Lightmaps");
        HideInspectorList.Add("unity_LightmapsInd");
        HideInspectorList.Add("unity_ShadowMasks");

        GradientEditor(materialEditor, properties);
        
        // 把 render queue 写进去了 这个想办法避免一下
        EditorGUILayout.Space(10);
        materialEditor.RenderQueueField();
        materialEditor.EnableInstancingField();
        materialEditor.DoubleSidedGIField();
    }

    /// <summary>
    /// 在材质面板上绘制渐变
    /// </summary>
    /// <param name="materialEditor"></param>
    /// <param name="properties"></param>
    public void GradientEditor(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        GUILayout.Label("Gradient",ToonLabelStyle);
        
        //Gradient = EditorGUILayout.GradientField(ShaderGUI.FindProperty("Color0", properties).displayName, Gradient);
        Label.text = ShaderGUI.FindProperty("Color0", properties).displayName; // 渐变属性名称
        Gradient = EditorGUILayout.GradientField(Label, Gradient, true, options);

        // 检查Gradient的初始状态，判断它是否是一个默认的、尚未修改的渐变
        if(
        Gradient.mode == GradientMode.Blend
        && Gradient.colorKeys.Length == 2
        && Gradient.colorKeys[0].color == new Color(1, 1, 1, 1)
        && Gradient.colorKeys[0].time == 0
        && Gradient.colorKeys[1].color == new Color(1, 1, 1, 1)
        && Gradient.colorKeys[1].time == 1
        && Gradient.alphaKeys.Length == 2 
        && Gradient.alphaKeys[0].alpha == 1
        && Gradient.alphaKeys[0].time == 0
        && Gradient.alphaKeys[1].alpha == 1
        && Gradient.alphaKeys[1].time == 1
        )
        {
            //获取材质的值
            GradientColorKey[] colorKeys = new GradientColorKey[(int)ShaderGUI.FindProperty("colorsLength", properties).floatValue];
            GradientAlphaKey[] alphakeys = new GradientAlphaKey[(int)ShaderGUI.FindProperty("alphasLength", properties).floatValue];
            Gradient.mode = ShaderGUI.FindProperty("type", properties).floatValue == 0 ? GradientMode.Blend : GradientMode.Fixed;
            
            for (int i = 0; i < colorKeys.Length; i++)
            {
                //Debug.Log(ShaderGUI.FindProperty("Color" + i.ToString(), properties).colorValue);
                colorKeys[i].color = ShaderGUI.FindProperty("Color" + i.ToString(), properties).colorValue;
                colorKeys[i].time = ShaderGUI.FindProperty("Color" + i.ToString(), properties).colorValue.a;
            }

            for (int i = 0; i < alphakeys.Length; i++)
            {
                alphakeys[i].alpha = ShaderGUI.FindProperty("Alpha" + i.ToString(), properties).vectorValue.x;
                alphakeys[i].time = ShaderGUI.FindProperty("Alpha" + i.ToString(), properties).vectorValue.y;
            }

            Gradient.SetKeys(colorKeys, alphakeys);
        }


        // 更新渐变数据
        MaterialProperty type = ShaderGUI.FindProperty("type", properties);
        HideInspectorList.Add("type");
        type.floatValue = (int)Gradient.mode;
        
        MaterialProperty colorsLength = ShaderGUI.FindProperty("colorsLength", properties);
        HideInspectorList.Add("colorsLength");
        colorsLength.floatValue = Gradient.colorKeys.Length;

        MaterialProperty alphasLength = ShaderGUI.FindProperty("alphasLength", properties);
        HideInspectorList.Add("alphasLength");
        alphasLength.floatValue = Gradient.alphaKeys.Length;

        for (int i = 0; i < Gradient.colorKeys.Length; i++)
        {
            MaterialProperty DrawColor = ShaderGUI.FindProperty("Color" + i.ToString(), properties);
            DrawColor.colorValue = new Vector4(Gradient.colorKeys[i].color.r, Gradient.colorKeys[i].color.g, Gradient.colorKeys[i].color.b, Gradient.colorKeys[i].time);
        }

        for (int i = 0; i < Gradient.alphaKeys.Length; i++)
        {
            MaterialProperty DrawAlpha = ShaderGUI.FindProperty("Alpha" + i.ToString(), properties);
            DrawAlpha.vectorValue = new Vector2(Gradient.alphaKeys[i].alpha, Gradient.alphaKeys[i].time);
        }

        // 添加隐藏的数据 这些数据将在材质面板中隐藏
        for (int i = 0; i < 8; i++)
        {
            HideInspectorList.Add("Color" + i.ToString());
            HideInspectorList.Add("Alpha" + i.ToString());
        }

        foreach (MaterialProperty property in properties)
        {
            bool HideTarget = false;
            foreach (var item in HideInspectorList)
            {
                if(property.name == item)
                {
                    HideTarget = true; // 如果为 true 则不会在 Inspector 中显示
                    break;
                }
            }
            if(!HideTarget)
            {
                materialEditor.ShaderProperty(property, property.displayName);
            }
        }
    }
    
}

#endif