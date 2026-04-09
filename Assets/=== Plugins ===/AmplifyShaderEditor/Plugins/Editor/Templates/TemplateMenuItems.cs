// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
using UnityEditor;

namespace AmplifyShaderEditor
{
	public class TemplateMenuItems
	{
		[MenuItem( "Assets/Create/Amplify Shader/Custom Render Texture/Initialize", false, 85 )]
		public static void ApplyTemplateCustomRenderTextureInitialize()
		{
			AmplifyShaderEditorWindow.CreateConfirmationTemplateShader( "6ce779933eb99f049b78d6163735e06f" );
		}
		[MenuItem( "Assets/Create/Amplify Shader/Custom Render Texture/Update", false, 85 )]
		public static void ApplyTemplateCustomRenderTextureUpdate()
		{
			AmplifyShaderEditorWindow.CreateConfirmationTemplateShader( "32120270d1b3a8746af2aca8bc749736" );
		}
		[MenuItem( "Assets/Create/Amplify Shader/UI/Default", false, 85 )]
		public static void ApplyTemplateUIDefault()
		{
			AmplifyShaderEditorWindow.CreateConfirmationTemplateShader( "5056123faa0c79b47ab6ad7e8bf059a4" );
		}
		[MenuItem( "Assets/Create/Amplify Shader/Universal/2D Custom Lit", false, 85 )]
		public static void ApplyTemplateUniversal2DCustomLit()
		{
			AmplifyShaderEditorWindow.CreateConfirmationTemplateShader( "ece0159bad6633944bf6b818f4dd296c" );
		}
		[MenuItem( "Assets/Create/Amplify Shader/Universal/2D Lit", false, 85 )]
		public static void ApplyTemplateUniversal2DLit()
		{
			AmplifyShaderEditorWindow.CreateConfirmationTemplateShader( "199187dac283dbe4a8cb1ea611d70c58" );
		}
		[MenuItem( "Assets/Create/Amplify Shader/Universal/2D Unlit", false, 85 )]
		public static void ApplyTemplateUniversal2DUnlit()
		{
			AmplifyShaderEditorWindow.CreateConfirmationTemplateShader( "cf964e524c8e69742b1d21fbe2ebcc4a" );
		}
		[MenuItem( "Assets/Create/Amplify Shader/Universal/Decal", false, 85 )]
		public static void ApplyTemplateUniversalDecal()
		{
			AmplifyShaderEditorWindow.CreateConfirmationTemplateShader( "c2a467ab6d5391a4ea692226d82ffefd" );
		}
		[MenuItem( "Assets/Create/Amplify Shader/Universal/Lit", false, 85 )]
		public static void ApplyTemplateUniversalLit()
		{
			AmplifyShaderEditorWindow.CreateConfirmationTemplateShader( "94348b07e5e8bab40bd6c8a1e3df54cd" );
		}
		[MenuItem( "Assets/Create/Amplify Shader/Universal/Unlit", false, 85 )]
		public static void ApplyTemplateUniversalUnlit()
		{
			AmplifyShaderEditorWindow.CreateConfirmationTemplateShader( "2992e84f91cbeb14eab234972e07ea9d" );
		}
	}
}
