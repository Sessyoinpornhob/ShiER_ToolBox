using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RendererUtils;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class HairOITRendererFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        [Tooltip("只绘制带这个 LightMode 的 pass。你的头发 shader pass Tags 必须是 LightMode=HairOIT")]
        public string shaderTag = "HairOIT";

        [Tooltip("合成用 shader：Hidden/HairOITComposite")]
        public Shader compositeShader;

        [Tooltip("可选：只在这些 RenderQueue 范围内筛选。一般透明 2501~5000。")]
        public int renderQueueMin = 2501;
        public int renderQueueMax = 5000;

        [Tooltip("事件点：建议 AfterRenderingOpaques（先有深度），再合成到 CameraColor。")]
        public RenderPassEvent passEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public Settings settings = new Settings();

    class HairOITPass : ScriptableRenderPass
    {
        static readonly int _OITAccumTex = Shader.PropertyToID("_OITAccumTex");
        static readonly int _OITRevealTex = Shader.PropertyToID("_OITRevealTex");

        readonly ShaderTagId _shaderTagId;
        readonly Material _compositeMat;

        readonly RenderQueueRange _queueRange;

        public HairOITPass(string shaderTag, Material compositeMat, int qMin, int qMax)
        {
            _shaderTagId = new ShaderTagId(shaderTag);
            _compositeMat = compositeMat;

            // URP 提供的只有 Opaque/Transparent 两档；这里用手动范围（兼容你想锁定区间）
            _queueRange = new RenderQueueRange
            {
                lowerBound = qMin,
                upperBound = qMax
            };
        }

        class PassData
        {
            public TextureHandle accum;
            public TextureHandle reveal;
            public TextureHandle cameraColor;

            public RendererListHandle rendererList;

            public Material compositeMat;
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            // --- 从 frameData 取 URP 的 resource（cameraColor 等）
            var urpResources = frameData.Get<UniversalResourceData>();
            var renderingData = frameData.Get<UniversalRenderingData>();
            var cameraData = frameData.Get<UniversalCameraData>();
            var lightData = frameData.Get<UniversalLightData>();

            // 没材质就不跑
            if (_compositeMat == null)
                return;

            // cameraColor（RenderGraph 句柄）
            var cameraColor = urpResources.activeColorTexture;

            // XR 处理：TextureDesc 需要正确 dimension/slices
            bool xrEnabled = cameraData.xr.enabled;
            int slices = xrEnabled ? Mathf.Max(1, cameraData.xr.viewCount) : 1;

            // 分配 2RT：Accum(清0) + Reveal(清1)
            // Accum 建议 RGBA16F；Reveal 用 R8/UNorm（这里用 R8_UNorm）
            var descAccum = new TextureDesc(cameraData.cameraTargetDescriptor.width, cameraData.cameraTargetDescriptor.height)
            {
                name = "_HairOIT_Accum",
                colorFormat = GraphicsFormat.R16G16B16A16_SFloat,
                clearBuffer = true,
                clearColor = Color.clear, // 0
                enableRandomWrite = false,
                useMipMap = false,
                msaaSamples = MSAASamples.None,

                dimension = xrEnabled ? TextureDimension.Tex2DArray : TextureDimension.Tex2D,
                slices = slices,
            };

            var descReveal = new TextureDesc(cameraData.cameraTargetDescriptor.width, cameraData.cameraTargetDescriptor.height)
            {
                name = "_HairOIT_Reveal",
                colorFormat = GraphicsFormat.R8_UNorm,
                clearBuffer = true,
                clearColor = Color.white, // 1 ！！！非常关键
                enableRandomWrite = false,
                useMipMap = false,
                msaaSamples = MSAASamples.None,

                dimension = xrEnabled ? TextureDimension.Tex2DArray : TextureDimension.Tex2D,
                slices = slices,
            };

            var accum = renderGraph.CreateTexture(descAccum);
            var reveal = renderGraph.CreateTexture(descReveal);
            
            // --- 0) Hair Depth Prepass：写入相机深度（给头发一个体积遮挡骨架）
            using (var builder = renderGraph.AddRasterRenderPass<PassData>("Hair OIT Depth Prepass", out var passData))
            {
                // 只绑定 depth attachment（写）
                builder.SetRenderAttachmentDepth(urpResources.activeDepthTexture, AccessFlags.Write);

                // 构建 RendererList：LightMode = HairOITDepth
                var sorting = SortingCriteria.CommonOpaque; // 深度预写建议用近到远（更省）
                var depthTag = new ShaderTagId("HairOITDepth");

                var rld = new RendererListDesc(depthTag, renderingData.cullResults, cameraData.camera)
                {
                    sortingCriteria = sorting,
                    renderQueueRange = _queueRange, // 仍然限定透明队列也行；或你单独给头发材质 queue 区间
                };

                passData.rendererList = renderGraph.CreateRendererList(rld);
                builder.UseRendererList(passData.rendererList);

                builder.AllowPassCulling(false);

                builder.SetRenderFunc((PassData data, RasterGraphContext ctx) =>
                {
                    ctx.cmd.DrawRendererList(data.rendererList);
                });
            }


            // --- 1) Accumulate Pass：只画 LightMode = HairOIT 的 renderer
            using (var builder = renderGraph.AddRasterRenderPass<PassData>("Hair OIT Accumulate", out var passData))
            {
                passData.accum = accum;
                passData.reveal = reveal;

                // 写入 MRT
                builder.SetRenderAttachment(accum, 0);
                builder.SetRenderAttachment(reveal, 1);
                builder.SetRenderAttachmentDepth(urpResources.activeDepthTexture, AccessFlags.Read);

                // 构建 RendererList：关键是这里用 ShaderTagId 来筛 LightMode=HairOIT 的 pass
                var sorting = SortingCriteria.CommonTransparent; // 不依赖顺序也没关系；透明常用排序即可

                var rld = new RendererListDesc(_shaderTagId, renderingData.cullResults, cameraData.camera)
                {
                    sortingCriteria = sorting,
                    renderQueueRange = _queueRange,
                    // 如果你后续想加 layerMask / renderingLayerMask，在这里加
                    // layerMask = ...,
                    // renderingLayerMask = ...,
                };

                passData.rendererList = renderGraph.CreateRendererList(rld);
                builder.UseRendererList(passData.rendererList);

                builder.AllowPassCulling(false);

                builder.SetRenderFunc((PassData data, RasterGraphContext ctx) =>
                {
                    // 画头发：只会执行 shader pass Tags { "LightMode"="HairOIT" }
                    ctx.cmd.DrawRendererList(data.rendererList);
                });
            }


            // --- 2) Composite Pass：把 accum/reveal 合成到 CameraColor
            using (var builder = renderGraph.AddRasterRenderPass<PassData>("Hair OIT Composite", out var passData))
            {
                passData.accum = accum;
                passData.reveal = reveal;
                passData.cameraColor = cameraColor;
                passData.compositeMat = _compositeMat;

                // 读 accum/reveal
                builder.UseTexture(accum, AccessFlags.Read);
                builder.UseTexture(reveal, AccessFlags.Read);

                // 写回 cameraColor
                builder.SetRenderAttachment(cameraColor, 0);

                builder.AllowPassCulling(false);

                builder.SetRenderFunc((PassData data, RasterGraphContext ctx) =>
                {
                    var cmd = ctx.cmd;
                    data.compositeMat.SetTexture(_OITAccumTex, data.accum);
                    data.compositeMat.SetTexture(_OITRevealTex, data.reveal);

                    // 全屏合成：这里不再传cameraColor
                    Blitter.BlitTexture(cmd, data.accum, new Vector4(1, 1, 0, 0), data.compositeMat, 0);
                });
            }
        }
    }

    HairOITPass _pass;
    Material _compositeMat;

    public override void Create()
    {
        if (settings.compositeShader != null)
        {
            _compositeMat = CoreUtils.CreateEngineMaterial(settings.compositeShader);
        }
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (_compositeMat == null)
            return;

        _pass ??= new HairOITPass(settings.shaderTag, _compositeMat, settings.renderQueueMin, settings.renderQueueMax);
        _pass.renderPassEvent = settings.passEvent;

        renderer.EnqueuePass(_pass);
    }

    protected override void Dispose(bool disposing)
    {
        CoreUtils.Destroy(_compositeMat);
        _compositeMat = null;
    }
}
