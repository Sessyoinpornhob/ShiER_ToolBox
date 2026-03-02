using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util; // AddBlitPass / BlitMaterialParameters

public class SimpleTintBlitFeature : ScriptableRendererFeature
{
    [Serializable]
    public class Settings
    {
        public RenderPassEvent injectionPoint = RenderPassEvent.AfterRenderingPostProcessing;
        public Material material;

        [Range(0f, 2f)] public float strength = 1f;
        public Color tint = Color.white;
    }

    [SerializeField] private Settings settings = new();

    class Pass : ScriptableRenderPass
    {
        static readonly int TintID = Shader.PropertyToID("_Tint");
        static readonly int StrengthID = Shader.PropertyToID("_Strength");

        readonly string m_PassName;
        readonly Settings m_Settings;

        public Pass(string passName, Settings settings)
        {
            m_PassName = passName;
            m_Settings = settings;
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            if (m_Settings.material == null)
                return;

            // 1) 取 URP 本帧资源
            var cameraData = frameData.Get<UniversalCameraData>();
            var resourceData = frameData.Get<UniversalResourceData>();

            // activeColorTexture：当前前/后缓冲中的“活动颜色”
            var source = resourceData.activeColorTexture;
            if (!source.IsValid())
                return;

            // 2) 准备一张临时目标纹理（和相机 target 同规格，去掉 depth / MSAA）
            var desc = cameraData.cameraTargetDescriptor;
            desc.depthBufferBits = 0;
            desc.msaaSamples = 1;

            var destination = UniversalRenderer.CreateRenderGraphTexture(
                renderGraph, desc, "SimpleTintBlit_TempColor", clear: false);

            // 3) 设置材质参数
            m_Settings.material.SetColor(TintID, m_Settings.tint);
            m_Settings.material.SetFloat(StrengthID, m_Settings.strength);

            // 4) 加一个 blit pass：source -> destination，用自定义材质 pass0
            var blitParams = new RenderGraphUtils.BlitMaterialParameters(
                source, destination ,m_Settings.material, 0);

            renderGraph.AddBlitPass(blitParams, m_PassName);

            // 5) 关键：更新帧数据指向 destination，这样后续就把它当“新的相机颜色”继续用（避免再 blit 回去）
            resourceData.cameraColor = destination;
        }
    }

    Pass m_Pass;

    public override void Create()
    {
        m_Pass = new Pass("Simple Tint Blit (RG)", settings)
        {
            renderPassEvent = settings.injectionPoint
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // RenderGraph 模式下：URP 会调用 RecordRenderGraph（Compatibility Mode Off）
        if (settings.material != null)
            renderer.EnqueuePass(m_Pass);
    }
}
