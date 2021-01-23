// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( DeckardAlphaRendererPPSRenderer ), PostProcessEvent.BeforeStack, "DeckardAlphaRenderer", false )]
public sealed class DeckardAlphaRendererPPSSettings : PostProcessEffectSettings
{
}

public sealed class DeckardAlphaRendererPPSRenderer : PostProcessEffectRenderer<DeckardAlphaRendererPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "DeckardAlphaRenderer" ) );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
