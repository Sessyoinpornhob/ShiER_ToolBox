// URPLitExtGUI.cs — Unity 6000, URP 17.0.4
// Goals
// 1) Modify the default Lit material inspector: REMOVE Workflow Mode UI, keep other Surface Options
// 2) Do NOT draw Surface Inputs & Detail Inputs
// 3) Draw Advanced Options
// 4) Integrate the [ext] tagging scheme (Foldout, if(x), Toggle keyword driving, SingleLineTexture)
//
// Usage
// - Put this file under an Editor folder (e.g., Assets/Editor/URPLitExtGUI.cs)
// - In your Lit-based shader, set:  CustomEditor "URPLitExtGUI"
// - Keep _WorkflowMode in the shader (optionally HideInInspector). This inspector simply hides the dropdown from UI.
// - Use [ext] + tags on properties.

using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using UnityEditor.Rendering; // BaseShaderGUI
using UnityEngine.Rendering;

public class URPLitExtGUI : BaseShaderGUI
{
    private MaterialProperty _SpecularHighlights;
    private MaterialProperty _EnvironmentReflections;
    private MaterialProperty _CastShadows;
    private MaterialProperty _ReceiveShadows;
    private MaterialProperty _AlphaClip;
    private MaterialProperty _Cutoff;
    private MaterialProperty _CullMode;

    public override void FindProperties(MaterialProperty[] properties)
    {
        base.FindProperties(properties);
        _SpecularHighlights = FindProperty("_SpecularHighlights", properties, false);
        _EnvironmentReflections = FindProperty("_EnvironmentReflections", properties, false);
        _CastShadows = FindProperty("_NoShadowCast", properties, false);
        _ReceiveShadows = FindProperty("_ReceiveShadows", properties, false);
        _AlphaClip = FindProperty("_AlphaClip", properties, false);
        _Cutoff = FindProperty("_Cutoff", properties, false);
        _CullMode = FindProperty("_Cull", properties, false);
    }

    public override void OnOpenGUI(Material material, MaterialEditor materialEditor)
    {
        base.OnOpenGUI(material, materialEditor);
    }

    public override void ValidateMaterial(Material material)
    {
        if (material == null) throw new ArgumentNullException(nameof(material));
        if (_SpecularHighlights != null) 
        {
            bool off = Mathf.Approximately(_SpecularHighlights.floatValue, 0f);
            CoreUtils.SetKeyword(material, "_SPECULARHIGHLIGHTS_OFF", off);
        }
        if (_EnvironmentReflections != null) 
        {
            bool off = Mathf.Approximately(_EnvironmentReflections.floatValue, 0f);
            CoreUtils.SetKeyword(material, "_ENVIRONMENTREFLECTIONS_OFF", off);
        }
        if (_CastShadows != null) 
        {
            bool noCast = material.GetFloat("_NoShadowCast") < 0.5f;
            CoreUtils.SetKeyword(material, "_NO_SHADOWCAST", noCast);
        }
        if (_ReceiveShadows != null)
        {
            bool receive = material.GetFloat("_ReceiveShadows") < 0.5f;
            CoreUtils.SetKeyword(material, "_RECEIVE_SHADOWS_OFF", receive);
        }
        if (_AlphaClip != null)
        {
            bool on = _AlphaClip.floatValue > 0.5f;
            CoreUtils.SetKeyword(material, "_ALPHATEST_ON", on);
        }
    }
    
    public void DrawRendererOptions(Material material)
    {
        // Suppress Test Options entirely
        bool rendererFoldout = EditorPrefs.GetBool("URPLitExtGUI_TestOptions_Foldout", true);
        rendererFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(rendererFoldout, "[CustomLit_Base] 渲染相关", EditorStyles.foldoutHeader);
        EditorPrefs.SetBool("URPLitExtGUI_TestOptions_Foldout", rendererFoldout);

        EditorGUI.indentLevel++;
        if (rendererFoldout)
        {
            // materialEditor.ShaderProperty(_SpecularHighlights, EditorGUIUtility.TrTextContent("Specular Highlights DisplayName"));
            DoPopup(Styles.cullingText, _CullMode, Styles.renderFaceNames);
            materialEditor.ShaderProperty(_CastShadows, EditorGUIUtility.TrTextContent("投射阴影"));
            materialEditor.ShaderProperty(_ReceiveShadows, EditorGUIUtility.TrTextContent("接收阴影"));
            materialEditor.ShaderProperty(_AlphaClip, EditorGUIUtility.TrTextContent("启用AlphaClip"));
            if (_AlphaClip.floatValue > 0.5f && _Cutoff != null)
                materialEditor.ShaderProperty(_Cutoff, EditorGUIUtility.TrTextContent("Cutoff"));
        }
        EditorGUI.indentLevel--;
        
        EditorGUILayout.EndFoldoutHeaderGroup();
    }
    
    // ====== [ext] integration ======
    private static readonly Dictionary<string, MaterialProperty> sProp = new Dictionary<string, MaterialProperty>();
    private static readonly List<ExtEntry> sPlan = new List<ExtEntry>();
    private static readonly Dictionary<string, string> sTip = new Dictionary<string, string>();
    private struct ExtEntry { public MaterialProperty prop; public bool indent; }
    private static readonly Regex kFuncWithArgs = new Regex(@"(\w+)\s*\((.*)\)", RegexOptions.Compiled);
    
    // key -> tooltip 文本（中文随便写）
    // 这里是为了解决无法输入中文的问题
    static readonly Dictionary<string, string> kTipTable = new Dictionary<string, string>
    {
        // Common
        { "_BaseColor", "基础颜色" },
        {"_UseSpecularColor", "启用高光颜色 如果选择启用高光颜色 就会走Specular流程" },
        {"_SpecColor", "高光颜色" }
        
        // CustomLit_Base
        // CustomLit_StaticOpaque
        // CustomLit_Character
        // CustomLit_Transparent
    };
    
    /// <summary>
    /// 基础的展开一个shaderGUI面板的方案 这里展开 ext 面板
    /// </summary>
    /// <param name="me"></param>
    /// <param name="properties"></param>
    private void DrawExtFoldout(MaterialEditor me, MaterialProperty[] properties)
    {
        // URPLitExtGUI_ExtendedProperties_Foldout 面板随手取名 持久化保存展开/关闭状态
        bool extFoldout = EditorPrefs.GetBool("URPLitExtGUI_ExtendedProperties_Foldout", true);
        extFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(extFoldout, "[Ext] 扩展属性");
        EditorPrefs.SetBool("URPLitExtGUI_ExtendedProperties_Foldout", extFoldout);

        // 实际的调用
        if (extFoldout) DrawExtBlock(me, properties);
        EditorGUILayout.EndFoldoutHeaderGroup();
    }

    private void DrawExtBlock(MaterialEditor me, MaterialProperty[] properties)
    {
        var mat = me.target as Material;
        if (mat == null) return;

        var shader = mat.shader;
        sProp.Clear();
        sPlan.Clear();
        sTip.Clear();

        for (int i = 0; i < properties.Length; i++)
        {
            var p = properties[i];
            // 这个 attrs 是个str的数组 获取了shader中所有的属性标签
            // ext Foldout ext if(_RenderData) Toggle(_NO_SHADOWCAST)
            var attrs = shader.GetPropertyAttributes(i);
            
            foreach (var a in attrs)
            {
                // 面板的各种标签的情况 ext
                if (a.Contains("ext"))
                {
                    if (!sProp.ContainsKey(p.name))
                    {
                        sProp[p.name] = p;
                        sPlan.Add(new ExtEntry { prop = p, indent = false });
                    }
                }
                // 面板的各种标签的情况 if
                else if (a.StartsWith("if"))
                {
                    var m = kFuncWithArgs.Match(a);
                    if (m.Success)
                    {
                        // m.Groups[0].Value：整个匹配到的字符串 if(_RenderData)
                        // m.Groups[1].Value：第一个捕获组 (\w+) → if
                        // m.Groups[2].Value：第二个捕获组 (.*) → _RenderData
                        var gateName = m.Groups[2].Value.Trim();
                        if (sProp.TryGetValue(gateName, out var gate))
                        {
                            if (gate.floatValue == 0f)
                            {
                                if (sPlan.Count > 0) sPlan.RemoveAt(sPlan.Count - 1);
                            }
                            else
                            {
                                if (sPlan.Count > 0)
                                {
                                    var last = sPlan[sPlan.Count - 1];
                                    last.indent = true;
                                    sPlan[sPlan.Count - 1] = last;
                                }
                            }
                        }
                    }
                }
                // 面板的各种标签的情况 tip 面板解释
                else if (a.StartsWith("tipKey"))
                {
                    var m2 = kFuncWithArgs.Match(a);
                    if (m2.Success)
                    {
                        string key = m2.Groups[2].Value.Trim(); // 这里只会是 ASCII key

                        // 这里基本上算是Editor的debug输出 挺好用
                        // EditorGUILayout.HelpBox($"attr={a}\nkey='{key}'", MessageType.None);
                        
                        if (kTipTable.TryGetValue(key, out var text)) sTip[p.name] = text; // 绑定到“属性名”
                        else sTip[p.name] = $"[Missing tipKey] {text}";
                    }
                }
            }
        }

        // 第二阶段：按 sPlan 绘制 UI
        if (sPlan.Count > 0)
        {
            for (int i = 0; i < sPlan.Count; i++)
            {
                var entry = sPlan[i];
                var prop = entry.prop;
                if ((prop.flags & (MaterialProperty.PropFlags.HideInInspector | MaterialProperty.PropFlags.PerRendererData)) != 0)
                    continue;

                // 取 tooltip（如果没有就给 null）
                sTip.TryGetValue(prop.name, out var tipText);
                
                GUIContent label = string.IsNullOrEmpty(tipText) ? EditorGUIUtility.TrTextContent(prop.displayName) 
                     : new GUIContent(prop.displayName, tipText);

                // 注意：GetPropertyHeight 只能传 string，这里用 label.text
                float h = materialEditor.GetPropertyHeight(prop, label.text);
                var r = EditorGUILayout.GetControlRect(true, h);

                if (entry.indent) EditorGUI.indentLevel++;
                // 使用带 GUIContent 的重载，这样悬浮提示可用
                // 都在这绘制的？目前确认的是 tooltipkey 在这绘制
                materialEditor.ShaderProperty(r, prop, label);
                if (entry.indent) EditorGUI.indentLevel--;
            }
        }   
    }

    internal class FoldoutDrawer : MaterialPropertyDrawer
    {
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            bool open = prop.floatValue > 0.5f;
            open = EditorGUI.Foldout(position, open, label, true);
            prop.floatValue = open ? 1f : 0f;
        }
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return EditorGUIUtility.singleLineHeight;
        }
    }
    
    public class ShiERToggleDrawer : MaterialPropertyDrawer
    {
        // Draw the property inside the given rect
        public override void OnGUI (Rect position, MaterialProperty prop, String label, MaterialEditor editor)
        {
            // Setup
            bool value = (prop.floatValue != 0.0f);

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            // Show the toggle control
            value = EditorGUI.Toggle(position, label, value);

            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                // Set the new value if it has changed
                prop.floatValue = value ? 1.0f : 0.0f;
            }
        }
    }


    public override void OnGUI(MaterialEditor materialEditorIn, MaterialProperty[] props)
    {
        materialEditor = materialEditorIn;
        FindProperties(props);

        EditorGUI.BeginChangeCheck();

        var targets = materialEditor.targets;
        var mat = materialEditor.target as Material;
        
        DrawRendererOptions(mat);
        DrawExtFoldout(materialEditor, props);

        foreach (var o in targets)
        {
            if (o is Material m)
            {
                ValidateMaterial(m);
                EditorUtility.SetDirty(m); // ★ 让 Unity 序列化这些改动
            }
        }
    }
    
    public override void DrawSurfaceOptions(Material material) { }

    public override void DrawSurfaceInputs(Material material) { }

    public override void DrawAdvancedOptions(Material material) { }
}
