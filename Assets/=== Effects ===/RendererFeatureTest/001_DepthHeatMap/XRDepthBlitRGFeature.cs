// XRDepthBlitRGFeature.cs — Unity 6000, URP 17
// 用法：把这个 Renderer Feature 加到 Universal Renderer 的 Renderer Features 列表。
// 建议注入点：AfterRenderingTransparents 或 AfterRendering（先从 AfterRenderingTransparents 开始测）

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class XRDepthBlitRGFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent injectionPoint = RenderPassEvent.AfterRenderingTransparents;
        public Material debugMaterial; // 使用下方的 DebugDepthHeatmap.shader
        public bool onlyXR = false;    // 仅在 XR 时启用（可选）
        public bool keepPass = true;   // 调试时防止被 RG 折叠
    }
    public Settings settings = new Settings();

    class RGPass : ScriptableRenderPass
    {
        Material _mat;
        bool _onlyXR, _keepPass;

        // 小型数据容器（给 RG 的 SetRenderFunc 使用）
        class CopyData { public TextureHandle src; }
        class ComposeData { public TextureHandle src; public Material mat; }

        public RGPass(Material mat, bool onlyXR, bool keepPass, RenderPassEvent evt)
        {
            _mat = mat;
            _onlyXR = onlyXR;
            _keepPass = keepPass;
            renderPassEvent = evt;
        }

        // —— 核心：Render Graph 录制
        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameContext)
        {
            var camData = frameContext.Get<UniversalCameraData>();
            if (_onlyXR && !camData.xr.enabled) return;

            var res = frameContext.Get<UniversalResourceData>();
            TextureHandle camColor = res.activeColorTexture;
            TextureHandle camDepth = res.activeDepthTexture;

            // 1) 创建与相机同规格的临时纹理（作为中间源）
            //   推荐从已存在的 handle 取描述符，再用 RenderGraph.CreateTexture 创建，避免尺寸/切片不匹配（XR安全）。
            //   也可以用 UniversalRenderer.CreateRenderGraphTexture 简化。:contentReference[oaicite:1]{index=1}
            var tempDesc = camColor.GetDescriptor(renderGraph);
            TextureHandle tempColor = renderGraph.CreateTexture(tempDesc);
            // 从已经存在的handle取得描述符？

            // 2) Pass A：把 active camera color 拷贝到 tempColor（避免在同一 pass 里读写同一资源）
            using (var builder = renderGraph.AddRasterRenderPass<CopyData>("RG Copy CameraColor -> Temp", out var passData))
            {
                passData.src = camColor;

                builder.UseTexture(passData.src, AccessFlags.Read); // 声明读源
                builder.SetRenderAttachment(tempColor, 0);          // 写目标（color）

                // 注意：此处不需要 depth 附件，仅做 copy
                if (_keepPass) builder.AllowPassCulling(false);

                builder.SetRenderFunc((CopyData data, RasterGraphContext ctx) =>
                {
                    // 使用 Blitter 做全屏 copy（RG/URP 官方推荐，避免旧式 Blit 的 XR 兼容问题）:contentReference[oaicite:2]{index=2}
                    Blitter.BlitTexture(ctx.cmd, data.src, new Vector4(1, 1, 0, 0), 0, false);
                });
            }

            // 3) Pass B：从 tempColor 全屏绘制回相机 color；着色器里可采样 _CameraDepthTexture 做调试/合成
            using (var builder = renderGraph.AddRasterRenderPass<ComposeData>("RG Compose Temp -> CameraColor (Depth Debug)", out var passData))
            {
                passData.src = tempColor;
                passData.mat = _mat;

                builder.UseTexture(passData.src, AccessFlags.Read);             // 读源（color）
                builder.SetRenderAttachment(camColor, 0);                       // 写入相机 color
                builder.SetRenderAttachmentDepth(camDepth, AccessFlags.Read);   // 绑定相机 depth（供深度测试与采样场景一致）:contentReference[oaicite:3]{index=3}

                if (_keepPass) builder.AllowPassCulling(false);

                builder.SetRenderFunc((ComposeData data, RasterGraphContext ctx) =>
                {
                    // 用调试材质把 temp 覆盖回去；材质里采样 _CameraDepthTexture（XR 安全宏）做可视化/合成
                    Blitter.BlitTexture(ctx.cmd, data.src, new Vector4(1, 1, 0, 0), data.mat, 0);
                });
            }
        }
    }

    RGPass _pass;

    public override void Create()
    {
        _pass = new RGPass(settings.debugMaterial, settings.onlyXR, settings.keepPass, settings.injectionPoint);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(_pass);
    }
}
