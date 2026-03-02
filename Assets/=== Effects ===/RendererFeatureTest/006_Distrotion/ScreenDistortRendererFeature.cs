using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;

public class ScreenDistortRendererFeature : ScriptableRendererFeature
{
    [Serializable]
    public class Settings
    {
        public Material material;
        [Tooltip("通常选 BeforeRenderingPostProcessing 或 AfterRenderingPostProcessing")]
        public RenderPassEvent passEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        [Tooltip("用来选择 shader pass index")]
        public int materialPassIndex = 0;
    }

    [SerializeField] private Settings settings = new Settings();
    private ScreenDistortPass pass;

    public override void Create()
    {
        pass = new ScreenDistortPass(settings);
        pass.renderPassEvent = settings.passEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.material == null)
            return;

        renderer.EnqueuePass(pass);
    }

    private class ScreenDistortPass : ScriptableRenderPass
    {
        private readonly Settings settings;
        private static readonly string k_PassName = "Screen Distort (RenderGraph Blit)";

        public ScreenDistortPass(Settings settings)
        {
            this.settings = settings;
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            var resourceData = frameData.Get<UniversalResourceData>();

            // 避免从 backbuffer 读（官方示例也这样防护）
            if (resourceData.isActiveTargetBackBuffer)
                return;

            TextureHandle src = resourceData.activeColorTexture;

            var desc = src.GetDescriptor(renderGraph);
            desc.name = "_ScreenDistortTmp";
            desc.depthBufferBits = 0;

            TextureHandle dst = renderGraph.CreateTexture(desc);

            // 注意构造顺序：source, destination, material, passIndex
            var para = new RenderGraphUtils.BlitMaterialParameters(src, dst, settings.material, settings.materialPassIndex);
            renderGraph.AddBlitPass(para, "Screen Distort");

            // 关键：更新 cameraColor（URP 的资源表里这是 settable）
            resourceData.cameraColor = dst;
        }

    }
}
