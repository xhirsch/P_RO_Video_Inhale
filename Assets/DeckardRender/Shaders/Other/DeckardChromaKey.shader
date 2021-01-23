// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unlit/DeckardChromaKey"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.22
		_KeyColor("KeyColor", Color) = (0.1999999,1,0,0)
		_Slope("Slope", Range( -1 , 1)) = 0
		_Float0("Float 0", Range( 0 , 1)) = 0
		_Threshold("Threshold", Range( 0 , 1)) = 0
		_Float1("Float 1", Float) = 0
		_Texture0("Texture 0", 2D) = "white" {}
		_decontaminateColors("decontaminateColors", Range( 0 , 0.1)) = 0
		_ContrastMidpoint("ContrastMidpoint", Float) = 0.5
		_Contrast("Contrast", Float) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _ContrastMidpoint;
		uniform float _Contrast;
		uniform sampler2D _Texture0;
		uniform float4 _Texture0_ST;
		uniform float _Threshold;
		uniform float _deckardInterpolator;
		uniform float _Float0;
		uniform float _Slope;
		uniform float4 _KeyColor;
		uniform float4 _DeckardAngle;
		uniform float _decontaminateColors;
		uniform float _Float1;
		uniform float _Cutoff = 0.22;


		float3 MyCustomExpression1_g6( float Midpoint , float Contrast , float3 In )
		{
			float midpoint = pow(Midpoint, 2.2);
			    return  (In - midpoint) * Contrast + midpoint;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float Midpoint1_g6 = _ContrastMidpoint;
			float Contrast1_g6 = _Contrast;
			float2 uv_Texture0 = i.uv_texcoord * _Texture0_ST.xy + _Texture0_ST.zw;
			float temp_output_16_0 = ( _deckardInterpolator * _Float0 );
			float temp_output_7_0_g4 = ( _Threshold + temp_output_16_0 );
			float smoothstepResult5_g4 = smoothstep( ( temp_output_7_0_g4 * ( 1.0 - _Slope ) ) , temp_output_7_0_g4 , abs( length( abs( ( _KeyColor - tex2D( _Texture0, ( i.uv_texcoord + ( (_DeckardAngle).xy * _decontaminateColors ) ) ) ) ) ) ));
			float4 temp_cast_0 = (( 1.0 - smoothstepResult5_g4 )).xxxx;
			float3 In1_g6 = ( tex2D( _Texture0, uv_Texture0 ) - temp_cast_0 ).rgb;
			float3 localMyCustomExpression1_g6 = MyCustomExpression1_g6( Midpoint1_g6 , Contrast1_g6 , In1_g6 );
			float3 clampResult46 = clamp( localMyCustomExpression1_g6 , float3( 0,0,0 ) , float3( 1,1,1 ) );
			o.Albedo = clampResult46;
			o.Alpha = 1;
			float temp_output_7_0_g5 = ( _Threshold + temp_output_16_0 );
			float smoothstepResult5_g5 = smoothstep( ( temp_output_7_0_g5 * ( 1.0 - _Slope ) ) , temp_output_7_0_g5 , abs( length( abs( ( _KeyColor - tex2Dbias( _Texture0, float4( uv_Texture0, 0, _Float1) ) ) ) ) ));
			clip( smoothstepResult5_g5 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17701
293.3333;395.3333;1240;619;-15.97273;458.797;1.479433;True;True
Node;AmplifyShaderEditor.Vector4Node;35;-1753.559,100.2241;Float;False;Global;_DeckardAngle;_DeckardAngle;8;0;Create;True;0;0;False;0;0,0,0,0;-0.3849489,-0.1292859,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-1554.153,294.9447;Float;False;Property;_decontaminateColors;decontaminateColors;7;0;Create;True;0;0;False;0;0;0.0092;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;36;-1464.559,66.22412;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;32;-1419.559,-92.77588;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1234.833,293.2213;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-596.2533,46.49661;Float;False;Property;_Float0;Float 0;3;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-589.9217,-45.54188;Float;False;Global;_deckardInterpolator;_deckardInterpolator;6;0;Create;True;0;0;False;0;0;1.291667;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-1055.011,264.6313;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;28;-1342.745,-320.5081;Float;True;Property;_Texture0;Texture 0;6;0;Create;True;0;0;False;0;None;cf50df0157ed8eb48ad62227cefc1205;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-413.0283,573.7521;Float;False;Property;_Slope;Slope;2;0;Create;True;0;0;False;0;0;0.245;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-756.3004,-584.7;Float;False;Property;_KeyColor;KeyColor;1;0;Create;True;0;0;False;0;0.1999999,1,0,0;0,0.8088235,0.1198761,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-187.1389,-49.6521;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-474.9451,-146.006;Float;False;Property;_Threshold;Threshold;4;0;Create;True;0;0;False;0;0;0.522;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;-861.0368,346.8996;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;-1;6366cec5ad51a4d48a449c35c0ce31e1;6366cec5ad51a4d48a449c35c0ce31e1;True;0;False;white;Auto;False;Object;-1;MipBias;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;42;163.4837,433.1874;Inherit;False;ChromaKey;-1;;4;0744c75a5da2bae4faa76f6ea3439775;0;5;9;COLOR;0.03448272,1,0,0;False;10;COLOR;0,0,0,0;False;11;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;45;540.2531,264.3502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;29;-702.892,139.1642;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;6366cec5ad51a4d48a449c35c0ce31e1;6366cec5ad51a4d48a449c35c0ce31e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-1142.981,-447.5388;Float;False;Property;_Float1;Float 1;5;0;Create;True;0;0;False;0;0;1.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;44;579.7479,100.0749;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;48;675.7999,-213.2111;Inherit;False;Property;_ContrastMidpoint;ContrastMidpoint;8;0;Create;True;0;0;False;0;0.5;0.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;652.1289,-99.2948;Inherit;False;Property;_Contrast;Contrast;9;0;Create;True;0;0;False;0;0.5;1.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-848.5002,-336.4;Inherit;True;Property;_2016091016_02_40WindowsMediaPlayer;2016-09-10 16_02_40-Windows Media Player;1;0;Create;True;0;0;False;0;-1;6366cec5ad51a4d48a449c35c0ce31e1;6366cec5ad51a4d48a449c35c0ce31e1;True;0;False;white;Auto;False;Object;-1;MipBias;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;47;927.3035,-155.5132;Inherit;False;ContrastMidpoint;-1;;6;82fa6eec51a71ba41a3d531aa7afcea5;0;3;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;41;128.5502,-239.0248;Inherit;False;ChromaKey;-1;;5;0744c75a5da2bae4faa76f6ea3439775;0;5;9;COLOR;0.03448272,1,0,0;False;10;COLOR;0,0,0,0;False;11;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;46;1092.26,11.66257;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1331.41,-1.935399;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Unlit/DeckardChromaKey;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.22;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;36;0;35;0
WireConnection;37;0;36;0
WireConnection;37;1;38;0
WireConnection;33;0;32;0
WireConnection;33;1;37;0
WireConnection;16;0;15;0
WireConnection;16;1;27;0
WireConnection;43;0;28;0
WireConnection;43;1;33;0
WireConnection;42;9;10;0
WireConnection;42;10;43;0
WireConnection;42;11;17;0
WireConnection;42;12;16;0
WireConnection;42;13;22;0
WireConnection;45;0;42;0
WireConnection;29;0;28;0
WireConnection;44;0;29;0
WireConnection;44;1;45;0
WireConnection;1;0;28;0
WireConnection;1;2;30;0
WireConnection;47;2;48;0
WireConnection;47;3;49;0
WireConnection;47;4;44;0
WireConnection;41;9;10;0
WireConnection;41;10;1;0
WireConnection;41;11;17;0
WireConnection;41;12;16;0
WireConnection;41;13;22;0
WireConnection;46;0;47;0
WireConnection;0;0;46;0
WireConnection;0;10;41;0
ASEEND*/
//CHKSM=C1136288FCFB76FC1B10AEE68C0BCBFB53BB32D6