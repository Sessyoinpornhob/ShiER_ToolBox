using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RendererUtils;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

/// <summary>
/// XR/SPI-safe (VP仙剑项目): draw objects using THEIR OWN material pass that matches a given LightMode (ShaderTagId).
/// - No XRPass Start/Stop
/// - No manual viewport/scissor
/// - No camera matrix override
/// - Bind activeColor + activeDepth (URP-like framebuffer shape)
/// - Compute yFlip INSIDE render function (RG registry is valid there)
/// </summary>
public class XRLightModeDrawFeature : ScriptableRendererFeature
{
    [Serializable]
    public class Settings
    {
        [Header("When")]
        public RenderPassEvent injectionPoint = RenderPassEvent.AfterRenderingOpaques;

        [Header("What to draw")]
        [Tooltip("Shader pass LightMode tag, e.g. HairOITDepth / UniversalForward / DepthOnly ...")]
        public string lightModeTag = "HairOITDepth";

        public RenderQueueType queueType = RenderQueueType.Opaque;
        public LayerMask layerMask = ~0;

        [Header("Depth state override (optional)")]
        public bool overrideDepthState = false;
        public bool depthWrite = true;
        public CompareFunction depthCompare = CompareFunction.LessEqual;

        [Header("RenderGraph")]
        public bool keepPass = true;

        [Header("URP-like globals (recommended if you use screen/flip-related helpers)")]
        [Tooltip("Sets _ScaleBiasRt, _DrawObjectPassData, _AlphaToMaskAvailable like URP DrawObjectsPass.")]
        public bool setURPGlobalsLikeDrawObjectsPass = true;
    }

    public Settings settings = new Settings();

    XRLightModeDrawPass _pass;

    public override void Create()
    {
        _pass = new XRLightModeDrawPass(settings)
        {
            renderPassEvent = settings.injectionPoint
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (_pass == null)
            _pass = new XRLightModeDrawPass(settings);

        _pass.UpdateSettings(settings);
        renderer.EnqueuePass(_pass);
    }

    class XRLightModeDrawPass : ScriptableRenderPass
    {
        Settings _s;
        ShaderTagId _tag;
        FilteringSettings _filtering;
        RenderStateBlock _renderStateBlock;

        // Match URP's global naming
        static readonly int _ScaleBiasRtId         = Shader.PropertyToID("_ScaleBiasRt");
        static readonly int _DrawObjectPassDataId  = Shader.PropertyToID("_DrawObjectPassData");
        static readonly int _AlphaToMaskAvailableId= Shader.PropertyToID("_AlphaToMaskAvailable");

        class PassData
        {
            public UniversalCameraData cameraData; // store cameraData like URP does
            public TextureHandle color;            // store activeColor handle; yFlip computed inside pass
            public RendererListHandle rendererList;

            public bool isOpaque;
            public float alphaToMaskAvailable;
            public bool setGlobals;
        }

        public XRLightModeDrawPass(Settings s)
        {
            UpdateSettings(s);
            profilingSampler = new ProfilingSampler("XRLightModeDrawPass");
        }

        public void UpdateSettings(Settings s)
        {
            _s = s ?? new Settings();
            _tag = new ShaderTagId(string.IsNullOrEmpty(_s.lightModeTag) ? "UniversalForward" : _s.lightModeTag);

            var range = (_s.queueType == RenderQueueType.Transparent) ? RenderQueueRange.transparent : RenderQueueRange.opaque;
            _filtering = new FilteringSettings(range, _s.layerMask);

            _renderStateBlock = new RenderStateBlock(RenderStateMask.Nothing);
            if (_s.overrideDepthState)
            {
                _renderStateBlock.mask |= RenderStateMask.Depth;
                _renderStateBlock.depthState = new DepthState(_s.depthWrite, _s.depthCompare);
            }
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            var resources     = frameData.Get<UniversalResourceData>();
            var renderingData = frameData.Get<UniversalRenderingData>();
            var cameraData    = frameData.Get<UniversalCameraData>();

            // Must have valid active color & depth (URP-like)
            if (!resources.activeColorTexture.IsValid() || !resources.activeDepthTexture.IsValid())
                return;

            // Avoid overlay cameras unless you explicitly want them
            if (cameraData.renderType != CameraRenderType.Base)
                return;

            var activeColor = resources.activeColorTexture;
            var activeDepth = resources.activeDepthTexture;

            bool isOpaque = (_s.queueType != RenderQueueType.Transparent);
            float alphaToMaskAvailable = ((cameraData.cameraTargetDescriptor.msaaSamples > 1) && isOpaque) ? 1.0f : 0.0f;

            using (var builder = renderGraph.AddRasterRenderPass<PassData>(
                       $"Draw LightMode({_s.lightModeTag})", out var passData, profilingSampler))
            {
                // Store handles + cameraData, and only resolve flip inside pass execution
                passData.cameraData = cameraData;
                passData.color = activeColor;

                passData.isOpaque = isOpaque;
                passData.alphaToMaskAvailable = alphaToMaskAvailable;
                passData.setGlobals = _s.setURPGlobalsLikeDrawObjectsPass;

                // Bind active framebuffer (XR/Metal-stable shape)
                builder.SetRenderAttachment(activeColor, 0, AccessFlags.Write);
                builder.SetRenderAttachmentDepth(activeDepth, AccessFlags.Write);

                // If we will set globals, RG must allow it
                if (passData.setGlobals)
                    builder.AllowGlobalStateModification(true);

                if (_s.keepPass)
                    builder.AllowPassCulling(false);

                // 是这句吗？是这句
                // Let URP control foveation if applicable (safe no-op otherwise)
                builder.EnableFoveatedRasterization(cameraData.xr.supportsFoveatedRendering);

                // Build RendererList (ticket = LightMode tag)
                var sorting = isOpaque ? SortingCriteria.CommonOpaque : SortingCriteria.CommonTransparent;

                var rld = new RendererListDesc(_tag, renderingData.cullResults, cameraData.camera)
                {
                    sortingCriteria  = sorting,
                    renderQueueRange = _filtering.renderQueueRange,
                    layerMask        = _s.layerMask,
                };

                passData.rendererList = renderGraph.CreateRendererList(rld);
                builder.UseRendererList(passData.rendererList);

                builder.SetRenderFunc((PassData data, RasterGraphContext ctx) =>
                {
                    // Renderers must already have this LightMode pass in THEIR OWN material,
                    // or the renderer won't even be in the list (ticket mechanism).
                    ctx.cmd.DrawRendererList(data.rendererList);
                });
            }
        }
    }
}
