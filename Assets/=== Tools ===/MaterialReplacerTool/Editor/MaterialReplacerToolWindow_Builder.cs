using System.Text;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;
using UnityEditor.UIElements;
using UnityEngine.SceneManagement;
using System.Collections.Generic;

public class MaterialReplacerToolWindow_Builder : EditorWindow
{
    [SerializeField] private VisualTreeAsset _uxml;

    // 需要替换的目标shader
    private ObjectField _targetShaderField;
    // 资源shader
    private ObjectField _resourceShaderField;
    
    // private Button _scanBtn;
    private Button _runBtn;
    private Button _clearBtn;
    private TextField _logField;
    
    // 关键字
    private const string str_ReceiveShadow = "_ReceiveShadows";
    private const string str_CastShadow = "_NoShadowCast";
    

    [MenuItem("Tools/ShiER/Material Replacer Tool")]
    public static void Open()
    {
        var wnd = GetWindow<MaterialReplacerToolWindow_Builder>();
        wnd.titleContent = new GUIContent("Material Replacer Tool");
        wnd.minSize = new Vector2(520, 360);
    }

    private void CreateGUI()
    {
        if (_uxml == null)
        {
            rootVisualElement.Add(new Label("UXML is null. Select this window and assign a VisualTreeAsset in Inspector."));
            return;
        }
        _uxml.CloneTree(rootVisualElement);
        
        // 寻找相关的UI元素 用作按钮或者其他需求
        _clearBtn               = rootVisualElement.Q<Button>("clearBtn");
        _runBtn                 = rootVisualElement.Q<Button>("runReplaceBtn");
        _targetShaderField      = rootVisualElement.Q<ObjectField>("targetShader");
        _resourceShaderField    = rootVisualElement.Q<ObjectField>("resourceShader");
        
        // 绑定函数
        _clearBtn.clicked += OnClearClicked;
        _runBtn.clicked += OnRunClicked;
    }
    
    private void OnClearClicked()
    {
        Debug.Log("无事发生");
    }
    
    /// <summary>
    /// 将某个shader的材质替换成另一个shader的材质 目前的测试结果对 Prefab 也生效
    /// </summary>
    private void OnRunClicked()
    {
        if (_targetShaderField.value == null)
        {
            Debug.LogError("请指定需要替换的目标Shader");
            return;
        }

        if (_resourceShaderField.value == null)
        {
            Debug.LogError("请指定资源Shader");
            return;
        }
        
        var targetShader = _targetShaderField.value as Shader;
        var resourceShader = _resourceShaderField.value as Shader;
        int count = 0;
        
        // Debug.Log($"将 { targetShader.name } 替换为 { resourceShader.name }");
        
        // 当前激活场景
        Scene activeScene = SceneManager.GetActiveScene();
        if (!activeScene.isLoaded)
        {
            Debug.LogError("当前没有已加载的场景。请先打开一个场景再执行。");
            return;
        }
        
        // 获取场景中的所有根对象
        GameObject[] rootObjects = activeScene.GetRootGameObjects();
        if (rootObjects == null || rootObjects.Length == 0)
        {
            Debug.LogWarning($"场景 '{activeScene.name}' 为空。");
            return;
        }

        foreach (GameObject gameObject in rootObjects)
        {
            Renderer[] renderers = gameObject.GetComponentsInChildren<Renderer>(true);
            foreach (Renderer renderer in renderers)
            {
                if (renderer == null)
                    continue;
                
                Material[] sharedMats = renderer.sharedMaterials;
                if (sharedMats == null)
                    continue;
                
                foreach (Material mat in sharedMats)
                {
                    if (mat == null || mat.shader == null)
                        continue;

                    if (mat.shader.name == targetShader.name)
                    {
                        mat.shader = resourceShader;
                        count++;
                    }
                }
            }
        }
        Debug.Log($"替换完成！共替换了 {count} 个材质。");
    }

    /// <summary>
    /// 修改指定的关键字
    /// </summary>
    private void ChangeKeyWords()
    {
        // 输入：
        // shader
        // 关键字列表/目前使用的是字符串常量
        
        // 当前激活场景
        Scene activeScene = SceneManager.GetActiveScene();
        if (!activeScene.isLoaded)
        {
            Debug.LogError("当前没有已加载的场景。请先打开一个场景再执行。");
            return;
        }
        
        // 获取场景中的所有根对象
        GameObject[] rootObjects = activeScene.GetRootGameObjects();
        if (rootObjects == null || rootObjects.Length == 0)
        {
            Debug.LogWarning($"场景 '{activeScene.name}' 为空。");
            return;
        }
        
        foreach (GameObject gameObject in rootObjects)
        {
            Renderer[] renderers = gameObject.GetComponentsInChildren<Renderer>(true);
            foreach (Renderer renderer in renderers)
            {
                if (renderer == null)
                    continue;
                
                Material[] sharedMats = renderer.sharedMaterials;
                if (sharedMats == null)
                    continue;
                
                foreach (Material mat in sharedMats)
                {
                    if (mat == null || mat.shader == null)
                        continue;

                    // if (mat.shader.name == resourceShader.name)
                    // {
                    //     mat.shader = resourceShader;
                    //     count++;
                    // }
                }
            }
        }
        
        // mat.SetFloat(str_ReceiveShadow, 0);
        // mat.SetFloat(str_CastShadow, 0);
    }
}
