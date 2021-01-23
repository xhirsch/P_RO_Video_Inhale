// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Deckard/DeckardCookie"
{
	Properties
	{
		_DeckardLightIntenisty("_DeckardLightIntenisty", Float) = 1
		_DeckardLightColor("_DeckardLightColor", Color) = (0,0,0,0)
		_DeckardLightOffset("_DeckardLightOffset", Vector) = (0,0,0,0)
		_DeckardLightScale("_DeckardLightScale", Vector) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "DisableBatching" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			half filler;
		};

		uniform float3 _DeckardLightScale;
		uniform float3 _DeckardLightOffset;
		uniform float4 _DeckardLightColor;
		uniform float _DeckardLightIntenisty;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 temp_output_5_0 = ( ase_vertex3Pos * _DeckardLightScale );
			float3 temp_output_11_0 = ( temp_output_5_0 + _DeckardLightOffset );
			v.vertex.xyz = temp_output_11_0;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Emission = ( _DeckardLightColor * _DeckardLightIntenisty ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16204
900;589;1365;695;1115.119;225.8293;1.6;True;True
Node;AmplifyShaderEditor.PosVertexDataNode;4;-630.3,132.9998;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;6;-390.9,220.7002;Float;False;Property;_DeckardLightScale;_DeckardLightScale;3;0;Create;True;0;0;False;0;0,0,0;1.08,0.61,1.36;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;3;-303.5,48.5;Float;False;Property;_DeckardLightIntenisty;_DeckardLightIntenisty;0;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;7;-601.1172,440.5099;Float;False;Property;_DeckardLightOffset;_DeckardLightOffset;2;0;Create;True;0;0;False;0;0,0,0;1.08,0.61,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-111.7,128.5999;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;1;-295.5,-133.5;Float;False;Property;_DeckardLightColor;_DeckardLightColor;1;0;Create;True;0;0;False;0;0,0,0,0;1,0.9922921,0.7205882,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-15.60472,372.1428;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-107.6446,518.6801;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;14;-322.3448,660.9797;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;13;395.2554,395.6788;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;187.6825,33.61196;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;9;47.94151,171.2211;Float;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-52.5,-103.5;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;454.4998,-198.8;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Deckard/DeckardCookie;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;4;0
WireConnection;5;1;6;0
WireConnection;11;0;5;0
WireConnection;11;1;7;0
WireConnection;14;0;7;0
WireConnection;13;0;15;0
WireConnection;10;0;9;0
WireConnection;10;1;5;0
WireConnection;9;0;11;0
WireConnection;2;0;1;0
WireConnection;2;1;3;0
WireConnection;0;2;2;0
WireConnection;0;11;11;0
ASEEND*/
//CHKSM=6C79496A073853517995EFE70599118F1E04288E