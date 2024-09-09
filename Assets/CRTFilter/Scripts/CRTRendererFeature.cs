using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CRTFilter
{
    public class CRTRendererFeature : ScriptableRendererFeature
    {
        public enum Presets
        {
            none,
            subtle,
            retro,
            strong,
            oldCrt,
            arcade,
            custom
        }

        public Shader shader;
        public RenderPassEvent injectionPoint = RenderPassEvent.BeforeRenderingPostProcessing;
        public Presets preset;

        [Range(0f, 640f)]
        public float pixelResolutionX = 320;
        [Range(0f, 640f)]
        public float pixelResolutionY = 200;

        [Header("Screen geometry")]
        [Range(0f, 10f)]
        public float screenBend = 4f;
        [Range(0f, 10f)]
        public float screenOverscan = 1f;
        [Range(0f, 10f)]
        public float vignetteSize = 5.3f;
        [Range(0f, 20f)]
        public float vignetteSmooth = 2;
        [Range(2f, 50f)]
        public float vignetteRound = 25f;

        [Header("Blur effects")]
        [Range(0f, 10f)]
        public float blur = 0;
        [Range(0f, 50f)]
        public float bleed = 0;
        [Range(0f, 50f)]
        public float smidge = 0;

        [Header("Scanlines and noise")]
        [Range(0f, 10f)]
        public float scanlinesStrength = 3;
        [Range(0f, 10f)]
        public float apertureStrength = 3;
        [Range(-50f, 50f)]
        public float shadowlines = 8;
        [Range(-20f, 20f)]
        public float shadowlinesSpeed = -2;
        [Range(0f, 1f)]
        public float shadowlinesAlpha = 0.05f;
        [Range(0f, 50f)]
        public float noiseSize = 75f;
        [Range(0f, 10f)]
        public float noiseSpeed = 0.02f;
        [Range(0f, 1f)]
        public float noiseAlpha = 0.05f;

        [Header("Image adjustments")]
        [Range(-2f, 2f)]
        public float brightness = 0;
        [Range(-3f, 3f)]
        public float contrast = 1;
        [Range(-3f, 3f)]
        public float gamma = 1;
        [Range(0f, 2f)]
        public float red = 1;
        [Range(0f, 2f)]
        public float green = 1;
        [Range(0f, 2f)]
        public float blue = 1;
        [Range(-10f, 10f)]
        public float chromaticAberration = 1;

        public Vector2 redOffset = new Vector2(0.1f, -0.1f);
        public Vector2 blueOffset = new Vector2(0, 0.1f);
        public Vector2 greenOffset = new Vector2(-0.1f, 0f);

        private CRTRenderPass crtRenderPass;
        private Material shaderMaterial;

        #region Settings presets

        public void OnValidate()
        {
            switch (preset)
            {
                case Presets.none:
                    screenBend = 0;
                    screenOverscan = 0;
                    blur = 0;
                    bleed = 0;
                    smidge = 0;
                    scanlinesStrength = 0;
                    apertureStrength = 0;
                    shadowlines = 0;
                    shadowlinesSpeed = 0;
                    shadowlinesAlpha = 0;
                    vignetteSize = 0;
                    vignetteSmooth = 0;
                    vignetteRound = 25;
                    noiseSize = 0;
                    noiseAlpha = 0;
                    noiseSpeed = 0;
                    brightness = 0;
                    contrast = 1;
                    gamma = 1;
                    red = 1;
                    green = 1;
                    blue = 1;
                    chromaticAberration = 0;
                    redOffset = Vector2.zero;
                    blueOffset = Vector2.zero;
                    greenOffset = Vector2.zero;
                    break;
                case Presets.subtle:
                    screenBend = 0.51f;
                    screenOverscan = 0;
                    blur = 0.5f;
                    bleed = 0;
                    smidge = 0;
                    scanlinesStrength = 1;
                    apertureStrength = 0.1f;
                    shadowlines = 0;
                    shadowlinesSpeed = 0;
                    shadowlinesAlpha = 0;
                    vignetteSize = 5.65f;
                    vignetteSmooth = 2;
                    vignetteRound = 37;
                    noiseSize = 0;
                    noiseAlpha = 0;
                    noiseSpeed = 0;
                    chromaticAberration = 0;
                    break;
                case Presets.retro:
                    screenBend = 0;
                    screenOverscan = 0;
                    blur = 0.5f;
                    bleed = 1.1f;
                    smidge = 14;
                    scanlinesStrength = 9;
                    apertureStrength = 1;
                    shadowlines = 0;
                    shadowlinesSpeed = 0;
                    shadowlinesAlpha = 0;
                    vignetteSize = 5.7f;
                    vignetteSmooth = 4.3f;
                    vignetteRound = 50;
                    noiseSize = 0;
                    noiseAlpha = 0;
                    noiseSpeed = 0;
                    chromaticAberration = 0;
                    break;
                case Presets.strong:
                    screenBend = 6.5f;
                    screenOverscan = 0.5f;
                    blur = 0.8f;
                    bleed = 0;
                    smidge = 0;
                    scanlinesStrength = 2.8f;
                    apertureStrength = 1;
                    shadowlines = 3.5f;
                    shadowlinesSpeed = 0.5f;
                    shadowlinesAlpha = 0.1f;
                    vignetteSize = 5.7f;
                    vignetteSmooth = 2.8f;
                    vignetteRound = 30;
                    noiseSize = 0;
                    noiseAlpha = 0;
                    noiseSpeed = 0;
                    chromaticAberration = 0.5f;
                    break;
                case Presets.oldCrt:
                    screenBend = 8.3f;
                    screenOverscan = 1.5f;
                    blur = 1;
                    bleed = 0.1f;
                    smidge = 0;
                    scanlinesStrength = 9;
                    apertureStrength = 4;
                    shadowlines = 3.5f;
                    shadowlinesSpeed = 1.5f;
                    shadowlinesAlpha = 0.2f;
                    vignetteSize = 5.7f;
                    vignetteSmooth = 2;
                    vignetteRound = 13;
                    noiseSize = 26;
                    noiseAlpha = 0.25f;
                    noiseSpeed = 7.2f;
                    chromaticAberration = 1.5f;
                    break;
                case Presets.arcade:
                    screenBend = 7.2f;
                    screenOverscan = 0.5f;
                    blur = 0;
                    bleed = 3;
                    smidge = 15;
                    scanlinesStrength = 9;
                    apertureStrength = 4;
                    shadowlines = 0;
                    shadowlinesSpeed = 0;
                    shadowlinesAlpha = 0;
                    vignetteSize = 5.7f;
                    vignetteSmooth = 1;
                    vignetteRound = 15;
                    noiseSize = 0;
                    noiseAlpha = 0;
                    noiseSpeed = 0;
                    chromaticAberration = 1;
                    break;
                case Presets.custom:
                default:
                    break;
            }

            if (chromaticAberration != 0)
            {
                redOffset = new Vector2(chromaticAberration / 10, chromaticAberration / 10);
                blueOffset = new Vector2(0, -(chromaticAberration / 10) * 1.4f);
                greenOffset = new Vector2(-chromaticAberration / 10, chromaticAberration / 10);
            }
        }

        #endregion

        public override void Create()
        {
            if (shaderMaterial == null)
                shaderMaterial = CoreUtils.CreateEngineMaterial(shader);

            if (crtRenderPass == null)
            {
                crtRenderPass = new CRTRenderPass(shaderMaterial);
                crtRenderPass.renderPassEvent = (RenderPassEvent)injectionPoint;
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (shaderMaterial != null)
            {
                CoreUtils.Destroy(shaderMaterial);
                shaderMaterial = null;
            }

            if (crtRenderPass != null)
            {
                crtRenderPass.Dispose();
                crtRenderPass = null;
            }
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (shaderMaterial == null || crtRenderPass == null)
                return;

            shaderMaterial.SetFloat("m_screenBend", screenBend == 0 ? 1000 : 13 - screenBend);
            shaderMaterial.SetFloat("m_screenOverscan", screenOverscan * 0.025f);
            shaderMaterial.SetFloat("m_blur", blur / 1000);
            shaderMaterial.SetFloat("m_smidge", smidge / 50);
            shaderMaterial.SetFloat("m_bleedr", bleed);
            shaderMaterial.SetFloat("m_bleedg", bleed > 0 ? 1 : 0);
            shaderMaterial.SetFloat("m_bleedb", bleed > 0 ? 1 : 0);
            shaderMaterial.SetFloat("m_resX", pixelResolutionX);
            shaderMaterial.SetFloat("m_resY", pixelResolutionY);
            shaderMaterial.SetFloat("m_scanlinesStrength", scanlinesStrength / 10);
            shaderMaterial.SetFloat("m_apertureStrength", apertureStrength / 10);
            shaderMaterial.SetFloat("m_shadowlines", shadowlines);
            shaderMaterial.SetFloat("m_shadowlinesSpeed", shadowlinesSpeed);
            shaderMaterial.SetFloat("m_shadowlinesAlpha", shadowlinesAlpha * 0.2f);
            shaderMaterial.SetFloat("m_vignetteSize", vignetteSize * 0.35f);
            shaderMaterial.SetFloat("m_vignetteSmooth", vignetteSmooth * 0.1f);
            shaderMaterial.SetFloat("m_vignetteRound", vignetteRound);
            shaderMaterial.SetFloat("m_noiseSize", noiseSize * 20);
            shaderMaterial.SetFloat("m_noiseAlpha", noiseAlpha * 0.2f);
            shaderMaterial.SetFloat("m_noiseSpeed", noiseSpeed * 0.0001f);
            shaderMaterial.SetFloat("m_brightness", brightness);
            shaderMaterial.SetFloat("m_contrast", contrast);
            shaderMaterial.SetFloat("m_gamma", gamma);
            shaderMaterial.SetFloat("m_red", red);
            shaderMaterial.SetFloat("m_green", green);
            shaderMaterial.SetFloat("m_blue", blue);
            shaderMaterial.SetVector("m_redOffset", redOffset / 100);
            shaderMaterial.SetVector("m_greenOffset", greenOffset / 100);
            shaderMaterial.SetVector("m_blueOffset", blueOffset / 100);

            crtRenderPass.ConfigureInput(ScriptableRenderPassInput.Color);
            renderer.EnqueuePass(crtRenderPass);
        }

        class CRTRenderPass : ScriptableRenderPass
        {
            private const string PROFTAG = "CRTFilter";

            private Material shaderMaterial;
            private RTHandle crtTexture;

            public CRTRenderPass(Material material)
            {
                this.shaderMaterial = material;
            }

            public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
            {
                var crtTextureDescriptor = cameraTextureDescriptor;
                crtTextureDescriptor.depthBufferBits = (int)DepthBits.None;

                //if (SystemInfo.IsFormatSupported(GraphicsFormat.B10G11R11_UFloatPack32, FormatUsage.Linear | FormatUsage.Render))
                //    crtTextureDescriptor.graphicsFormat = GraphicsFormat.B10G11R11_UFloatPack32;
                //else
                //    crtTextureDescriptor.graphicsFormat = QualitySettings.activeColorSpace == ColorSpace.Linear ? GraphicsFormat.R8G8B8A8_SRGB : GraphicsFormat.R8G8B8A8_UNorm;
                
                RenderingUtils.ReAllocateIfNeeded(ref crtTexture, crtTextureDescriptor, name: "_CRTTexture", wrapMode: TextureWrapMode.Clamp);
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                if (shaderMaterial == null || crtTexture == null)
                    return;

                var cmd = CommandBufferPool.Get(PROFTAG);

                shaderMaterial.SetFloat("m_time", Time.time);
                cmd.Blit(renderingData.cameraData.renderer.cameraColorTargetHandle, crtTexture, shaderMaterial, 0);
                cmd.Blit(crtTexture, renderingData.cameraData.renderer.cameraColorTargetHandle);
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                CommandBufferPool.Release(cmd);
            }

            public void Dispose()
            {
                RTHandles.Release(crtTexture);
                crtTexture = null;
            }
        }
    }
}