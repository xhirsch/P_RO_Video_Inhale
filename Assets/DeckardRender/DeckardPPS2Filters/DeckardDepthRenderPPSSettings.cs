// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( DeckardDepthRenderPPSRenderer ), PostProcessEvent.AfterStack, "DeckardDepthRender", true )]
public sealed class DeckardDepthRenderPPSSettings : PostProcessEffectSettings
{
	[Tooltip( "ScaleDepth" )]
	public FloatParameter _ScaleDepth = new FloatParameter { value = 1f };
}

public sealed class DeckardDepthRenderPPSRenderer : PostProcessEffectRenderer<DeckardDepthRenderPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "DeckardDepthRender" ) );
		sheet.properties.SetFloat( "_ScaleDepth", settings._ScaleDepth );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
