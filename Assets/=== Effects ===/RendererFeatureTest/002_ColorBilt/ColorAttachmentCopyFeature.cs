using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class ColorAttachmentCopyFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent passEvent = RenderPassEvent.AfterRenderingOpaques;

        // 全局纹理名：shader 里就采样这个
        public string globalTextureName = "_ShiER_CameraColorCopy";
    }
    public Settings settings = new Settings();
    
    class CopyPass : ScriptableRenderPass
    {
        static readonly int k_GlobalTexId = Shader.PropertyToID("_ShiER_CameraColorCopy");
        string _globalName;
        RTHandle _copyRT;

        public CopyPass(string globalName, RenderPassEvent evt)
        {
            _globalName = globalName;
            renderPassEvent = evt;
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            _copyRT?.Release();
            _copyRT = null;
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            var resources = frameData.Get<UniversalResourceData>();

            // 源：相机 active color
            TextureHandle src = resources.activeColorTexture;
            // TextureHandle src1 = resources;
            if (!src.IsValid())
                return;

            // 目标：创建一张临时纹理
            var desc = renderGraph.GetTextureDesc(src);
            desc.name = "ShiER CameraColor Copy";
            desc.clearBuffer = false;

            TextureHandle dst = renderGraph.CreateTexture(desc);

            using (var builder = renderGraph.AddRasterRenderPass<CopyPassData>(
                       "ShiER Copy CameraColor",
                       out var passData))
            {
                // PassData：只需要存 src（dst 用 SetRenderAttachment 指定）
                passData.src = src;

                // 声明依赖：读 src
                builder.UseTexture(passData.src, AccessFlags.Read);

                // 声明输出：写入 dst（作为 color attachment 0）
                builder.SetRenderAttachment(dst, 0);

                // 设置成全局纹理：✅ 官方推荐方式
                builder.SetGlobalTextureAfterPass(dst, Shader.PropertyToID(_globalName));

                // 防止因为“结果没被后续 pass 使用”而被 RG 裁掉（调试期建议开）
                builder.AllowPassCulling(false);

                // 执行函数（RasterGraphContext！）
                builder.SetRenderFunc(static (CopyPassData data, RasterGraphContext ctx) =>
                {
                    // 把 data.src blit 到本 pass 的 render attachment（也就是 dst）
                    Blitter.BlitTexture(ctx.cmd, data.src, new Vector4(1, 1, 0, 0), 0, false);
                });
            }
        }

        class CopyPassData
        {
            public TextureHandle src;
        }

    }

    CopyPass _pass;

    public override void Create()
    {
        _pass = new CopyPass(settings.globalTextureName, settings.passEvent);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // 其他的相机不会影响此Feature
        var camera = renderingData.cameraData.camera;
        if (camera != Camera.main)
            return;
        
        renderer.EnqueuePass(_pass);
    }
}
