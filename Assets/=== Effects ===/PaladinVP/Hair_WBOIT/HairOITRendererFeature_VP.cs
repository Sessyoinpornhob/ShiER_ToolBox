using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RendererUtils;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

/// <summary>
/// VP-friendly Hair OIT (WBOIT + Hair Depth Prepass) without fullscreen Blit composite.
/// Pipeline (all in one RenderGraph):
/// 0) Copy activeColor -> sceneCopy, expose as global texture (_ShiER_CameraColorCopy by default)
/// 1) Hair depth prepass: draw LightMode=HairOITDepth, write camera depth attachment
/// 2) Hair accumulate: draw LightMode=HairOIT, write MRT (accum/reveal), expose as globals (_OITAccumTex/_OITRevealTex)
/// 3) Hair resolve: draw LightMode=HairOITResolve, write back to cameraColor (no overrideMaterial)
/// 4）当前版本 bug存在，某些地方还有问题；
/// </summary>
public class HairOITRendererFeature_VP : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        [Header("Pass Event")]
        [Tooltip("Recommended: BeforeRenderingTransparents (after opaques are done & depth exists).")]
        public RenderPassEvent passEvent = RenderPassEvent.BeforeRenderingTransparents;
        
        [Header("ShaderTags (LightMode)")]
        public string hairDepthTag = "HairOITDepth";
        public string hairOitTag = "HairOIT";
        public string hairResolveTag = "HairOITResolve";

        [Header("Filtering")]
        [Tooltip("Transparent usually 2501~5000. Ensure hair materials are in this range.")]
        public int renderQueueMin = 2501;
        public int renderQueueMax = 3000;
        
        [Header("OIT Global Names")]
        public string oitAccumGlobalName = "_OITAccumTex";
        public string oitRevealGlobalName = "_OITRevealTex";
    }

    public Settings settings = new Settings();

    class HairOITPass : ScriptableRenderPass
    {
        readonly ShaderTagId _tagDepth;
        readonly ShaderTagId _tagOit;
        readonly ShaderTagId _tagResolve;

        readonly int _sceneCopyGlobalId;
        readonly int _oitAccumGlobalId;
        readonly int _oitRevealGlobalId;
        readonly int _QueueOffset;

        readonly RenderQueueRange _queueRange;

        public HairOITPass(Settings s)
        {
            _tagDepth = new ShaderTagId(s.hairDepthTag);
            _tagOit = new ShaderTagId(s.hairOitTag);
            _tagResolve = new ShaderTagId(s.hairResolveTag);

            _oitAccumGlobalId = Shader.PropertyToID(s.oitAccumGlobalName);
            _oitRevealGlobalId = Shader.PropertyToID(s.oitRevealGlobalName);

            _queueRange = new RenderQueueRange
            {
                lowerBound = s.renderQueueMin,
                upperBound = s.renderQueueMax
            };
        }

        class PassData
        {
            public TextureHandle sceneCopy;
            public TextureHandle accum;
            public TextureHandle reveal;

            public TextureHandle cameraColor;
            public TextureHandle cameraDepth;

            public RendererListHandle rlDepth;
            public RendererListHandle rlOit;
            public RendererListHandle rlResolve;
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            var resources = frameData.Get<UniversalResourceData>();
            var renderingData = frameData.Get<UniversalRenderingData>();
            var cameraData = frameData.Get<UniversalCameraData>();

            // Must have valid active color & depth
            if (!resources.activeColorTexture.IsValid() || !resources.activeDepthTexture.IsValid())
                return;

            var cameraColor = resources.activeColorTexture;
            var cameraDepth = resources.activeDepthTexture;

            // Use activeColor desc as the ground truth (XR/DRS/MSAA)
            var srcDesc = renderGraph.GetTextureDesc(cameraColor);

            // ============================================================
            // Step 1: Hair Depth Prepass (write camera depth attachment)
            // LightMode = HairOITDepth
            // ============================================================
            using (var builder = renderGraph.AddRasterRenderPass<PassData>("HairOIT Depth Prepass", out var passData))
            {
                passData.cameraDepth = cameraDepth;
                passData.cameraColor = cameraColor;

                builder.SetRenderAttachmentDepth(passData.cameraDepth, AccessFlags.Write);
                // write back to camera color
                builder.SetRenderAttachment(passData.cameraColor, 0);
                
                // 注释点渲染 测试
                builder.EnableFoveatedRasterization(cameraData.xr.supportsFoveatedRendering);

                var sorting = SortingCriteria.CommonOpaque;
                var rld = new RendererListDesc(_tagDepth, renderingData.cullResults, cameraData.camera)
                {
                    sortingCriteria = sorting,
                    renderQueueRange = _queueRange,
                };

                passData.rlDepth = renderGraph.CreateRendererList(rld);
                builder.UseRendererList(passData.rlDepth);

                builder.AllowPassCulling(false);

                builder.SetRenderFunc(static (PassData data, RasterGraphContext ctx) =>
                {
                    ctx.cmd.DrawRendererList(data.rlDepth);
                });
            }

            // ============================================================
            // Step 2: Hair OIT Accumulate (MRT accum/reveal) + expose globals
            // LightMode = HairOIT
            // ============================================================
            var accum = renderGraph.CreateTexture(new TextureDesc(srcDesc.width, srcDesc.height)
            {
                name = "HairOIT Accum",
                colorFormat = GraphicsFormat.R16G16B16A16_SFloat,
                clearBuffer = true,
                clearColor = Color.clear,
                msaaSamples = srcDesc.msaaSamples,
                dimension = srcDesc.dimension,
                slices = srcDesc.slices,
            });
            
            var reveal = renderGraph.CreateTexture(new TextureDesc(srcDesc.width, srcDesc.height)
            {
                name = "HairOIT Reveal",
                colorFormat = GraphicsFormat.R8_UNorm,
                clearBuffer = true,
                clearColor = Color.white, // reveal must start at 1
                msaaSamples = srcDesc.msaaSamples,
                dimension = srcDesc.dimension,
                slices = srcDesc.slices,
            });
            
            using (var builder = renderGraph.AddRasterRenderPass<PassData>("HairOIT Accumulate", out var passData))
            {
                passData.accum = accum;
                passData.reveal = reveal;
                passData.cameraDepth = cameraDepth;
            
                builder.SetRenderAttachment(passData.accum, 0);
                builder.SetRenderAttachment(passData.reveal, 1);
            
                // IMPORTANT: bind depth attachment (Read) for ZTest
                builder.SetRenderAttachmentDepth(passData.cameraDepth, AccessFlags.Read);
            
                // Expose OIT RTs as globals for HairOITResolve pass
                builder.SetGlobalTextureAfterPass(passData.accum, _oitAccumGlobalId);
                builder.SetGlobalTextureAfterPass(passData.reveal, _oitRevealGlobalId);
                
                // 注释点渲染 测试
                builder.EnableFoveatedRasterization(cameraData.xr.supportsFoveatedRendering);
            
                var sorting = SortingCriteria.CommonTransparent;
                var rld = new RendererListDesc(_tagOit, renderingData.cullResults, cameraData.camera)
                {
                    sortingCriteria = sorting,
                    renderQueueRange = _queueRange,
                    rendererConfiguration =
                        renderingData.perObjectData
                        | PerObjectData.LightProbe
                        | PerObjectData.LightProbeProxyVolume,
                };
            
                passData.rlOit = renderGraph.CreateRendererList(rld);
                builder.UseRendererList(passData.rlOit);
            
                builder.AllowPassCulling(false);
            
                builder.SetRenderFunc(static (PassData data, RasterGraphContext ctx) =>
                {
                    ctx.cmd.DrawRendererList(data.rlOit);
                });
            }
            
            // ============================================================
            // Step 3: Hair Resolve (draw HairOITResolve pass back into cameraColor)
            // LightMode = HairOITResolve
            // ============================================================
            using (var builder = renderGraph.AddRasterRenderPass<PassData>("HairOIT Resolve", out var passData))
            {
                passData.cameraColor = cameraColor;
                passData.cameraDepth = cameraDepth;
                passData.accum = accum;
                passData.reveal = reveal;
            
                // write back to camera color
                builder.SetRenderAttachment(passData.cameraColor, 0);
            
                // ZTest should still work against camera depth
                builder.SetRenderAttachmentDepth(passData.cameraDepth, AccessFlags.Read);
                
                // 注释点渲染 测试
                builder.EnableFoveatedRasterization(cameraData.xr.supportsFoveatedRendering);
            
                // Build explicit dependencies so RG won't reorder incorrectly
                // builder.UseTexture(passData.sceneCopy, AccessFlags.Read);
                builder.UseTexture(passData.accum, AccessFlags.Read);
                builder.UseTexture(passData.reveal, AccessFlags.Read);
            
                var sorting = SortingCriteria.CommonTransparent;
                var rld = new RendererListDesc(_tagResolve, renderingData.cullResults, cameraData.camera)
                {
                    sortingCriteria = sorting,
                    renderQueueRange = _queueRange,
                };
            
                passData.rlResolve = renderGraph.CreateRendererList(rld);
                builder.UseRendererList(passData.rlResolve);
            
                builder.AllowPassCulling(false);
            
                builder.SetRenderFunc(static (PassData data, RasterGraphContext ctx) =>
                {
                    // No global state modification here; globals were published in Step0/Step2.
                    ctx.cmd.DrawRendererList(data.rlResolve);
                });
            }
        }
    }

    HairOITPass _pass;

    public override void Create()
    {
        _pass = new HairOITPass(settings)
        {
            renderPassEvent = settings.passEvent
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // 这里需要考虑多相机的情况：大部分时间仅在主相机执行 过场动画需要在某些相机上执行
        // // Always enqueue; no resolve material gating anymore.
        // var camera = renderingData.cameraData.camera;
        //
        // // 例1：只在主相机执行
        // if (camera != Camera.main)
        //     return;
        renderer.EnqueuePass(_pass);
    }
}

