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

    public override void FindProperties(MaterialProperty[] properties)
    {
        base.FindProperties(properties);
        _SpecularHighlights = FindProperty("_SpecularHighlights", properties, false);
        _EnvironmentReflections = FindProperty("_EnvironmentReflections", properties, false);
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
    }

    public override void DrawSurfaceOptions(Material material)
    {
        if (material == null) throw new ArgumentNullException(nameof(material));

        bool surfaceFoldout = EditorPrefs.GetBool("URPLitExtGUI_SurfaceOptions_Foldout", true);
        surfaceFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(surfaceFoldout, "Surface Options");
        EditorPrefs.SetBool("URPLitExtGUI_SurfaceOptions_Foldout", surfaceFoldout);

        if (surfaceFoldout)
        {
            EditorGUIUtility.labelWidth = 0f;
            EditorGUI.BeginChangeCheck();
            base.DrawSurfaceOptions(material);
            if (EditorGUI.EndChangeCheck())
            {
                foreach (var obj in materialEditor.targets)
                {
                    if (obj is Material mat) ValidateMaterial(mat);
                }
            }
        }
        EditorGUILayout.EndFoldoutHeaderGroup();
    }

    public override void DrawSurfaceInputs(Material material)
    {
        // Suppress Surface Inputs entirely
    }

    public override void DrawAdvancedOptions(Material material)
    {
        bool advFoldout = EditorPrefs.GetBool("URPLitExtGUI_AdvancedOptions_Foldout", true);
        advFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(advFoldout, "Advanced Options");
        EditorPrefs.SetBool("URPLitExtGUI_AdvancedOptions_Foldout", advFoldout);

        if (advFoldout)
        {
            if (_SpecularHighlights != null)
                materialEditor.ShaderProperty(_SpecularHighlights, EditorGUIUtility.TrTextContent("Specular Highlights"));
            if (_EnvironmentReflections != null)
                materialEditor.ShaderProperty(_EnvironmentReflections, EditorGUIUtility.TrTextContent("Environment Reflections"));

            base.DrawAdvancedOptions(material);
        }
        EditorGUILayout.EndFoldoutHeaderGroup();
    }

    public override void OnGUI(MaterialEditor materialEditorIn, MaterialProperty[] props)
    {
        materialEditor = materialEditorIn;
        FindProperties(props);

        var targets = materialEditor.targets;
        var mat = materialEditor.target as Material;

        DrawSurfaceOptions(mat);
        DrawAdvancedOptions(mat);
        DrawExtFoldout(materialEditor, props);

        foreach (var o in targets)
            if (o is Material m) ValidateMaterial(m);
    }

    // ====== [ext] integration ======
    private static readonly Dictionary<string, MaterialProperty> sProp = new Dictionary<string, MaterialProperty>();
    private static readonly List<ExtEntry> sPlan = new List<ExtEntry>();

    private struct ExtEntry { public MaterialProperty prop; public bool indent; }
    private static readonly Regex kFuncWithArgs = new Regex(@"(\w+)\s*\((.*)\)", RegexOptions.Compiled);

    private void DrawExtFoldout(MaterialEditor me, MaterialProperty[] properties)
    {
        bool extFoldout = EditorPrefs.GetBool("URPLitExtGUI_ExtendedProperties_Foldout", true);
        extFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(extFoldout, "Extended Properties");
        EditorPrefs.SetBool("URPLitExtGUI_ExtendedProperties_Foldout", extFoldout);

        if (extFoldout)
        {
            DrawExtBlock(me, properties);
        }
        EditorGUILayout.EndFoldoutHeaderGroup();
    }

    private void DrawExtBlock(MaterialEditor me, MaterialProperty[] properties)
    {
        var mat = me.target as Material;
        if (mat == null) return;

        var shader = mat.shader;
        sProp.Clear();
        sPlan.Clear();

        for (int i = 0; i < properties.Length; i++)
        {
            var p = properties[i];
            var attrs = shader.GetPropertyAttributes(i);
            foreach (var a in attrs)
            {
                if (a.Contains("ext"))
                {
                    if (!sProp.ContainsKey(p.name))
                    {
                        sProp[p.name] = p;
                        sPlan.Add(new ExtEntry { prop = p, indent = false });
                    }
                }
                else if (a.StartsWith("if"))
                {
                    var m = kFuncWithArgs.Match(a);
                    if (m.Success)
                    {
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
                else if (a.Contains("Toggle"))
                {
                    if (properties[i].type == MaterialProperty.PropType.Float)
                    {
                        string keyword = string.Empty;
                        var m = kFuncWithArgs.Match(a);
                        if (m.Success) keyword = m.Groups[2].Value.Trim();
                        if (string.IsNullOrEmpty(keyword)) keyword = p.name.ToUpperInvariant() + "_ON";

                        foreach (Material t in p.targets)
                        {
                            if (Mathf.Approximately(p.floatValue, 1f)) t.EnableKeyword(keyword);
                            else t.DisableKeyword(keyword);
                        }
                    }
                }
            }
        }

        if (sPlan.Count > 0)
        {
            for (int i = 0; i < sPlan.Count; i++)
            {
                var entry = sPlan[i];
                var prop = entry.prop;
                if ((prop.flags & (MaterialProperty.PropFlags.HideInInspector | MaterialProperty.PropFlags.PerRendererData)) != 0)
                    continue;

                float h = me.GetPropertyHeight(prop, prop.displayName);
                var r = EditorGUILayout.GetControlRect(true, h, EditorStyles.layerMaskField);
                if (entry.indent) EditorGUI.indentLevel++;
                me.ShaderProperty(r, prop, prop.displayName);
                if (entry.indent) EditorGUI.indentLevel--;
            }
        }
    }

    internal class FoldoutDrawer : MaterialPropertyDrawer
    {
        private bool _open;
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _open = EditorGUILayout.Foldout(_open, label, true);
            prop.floatValue = _open ? 1f : 0f;
        }
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) => 0f;
    }

    internal class SingleLineDrawer : MaterialPropertyDrawer
    {
        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            editor.TexturePropertySingleLine(label, prop);
        }
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }
    }
}
