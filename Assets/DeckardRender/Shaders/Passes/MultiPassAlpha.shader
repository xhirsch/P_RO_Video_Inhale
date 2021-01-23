// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Deckard/MultiPassAlpha"
{
	Properties
	{
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
		LOD 100

		CGINCLUDE
		#pragma target 3.5
		ENDCG
		Blend One One
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			
			CGPROGRAM

#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
		//only defining to not throw compilation error over Unity 5.5
		#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
			};

			uniform sampler2D Texture1;
			uniform float _NoiseMove;
			uniform sampler2D _DeckardDepth;
			uniform float4 _DeckardDepth_ST;
			uniform float _renderSteps;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				float3 vertexValue =  float3(0,0,0) ;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				float2 uv_DeckardDepth = i.ase_texcoord.xy * _DeckardDepth_ST.xy + _DeckardDepth_ST.zw;
				float4 tex2DNode186 = tex2D( _DeckardDepth, uv_DeckardDepth );
				float ifLocalVar201 = 0;
				if( tex2DNode186.r > 0.0 )
				ifLocalVar201 = 1.0;
				else if( tex2DNode186.r == 0.0 )
				ifLocalVar201 = 0.0;
				else if( tex2DNode186.r < 0.0 )
				ifLocalVar201 = 0.0;
				float temp_output_20_0 = ( _renderSteps * 2.0 );
				float temp_output_10_0 = ( ifLocalVar201 * ( 1.0 / temp_output_20_0 ) );
				float4 temp_cast_0 = (temp_output_10_0).xxxx;
				
				
				finalColor = temp_cast_0;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16800
761.3334;811.3334;1752;467;-2143.767;213.142;2.2;True;True
Node;AmplifyShaderEditor.RangedFloatNode;6;3231.701,442.5988;Float;False;Global;_renderSteps;_renderSteps;0;0;Create;True;0;0;True;0;10;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;26;2393.107,-141.3664;Float;True;Global;_DeckardDepth;_DeckardDepth;2;0;Create;True;0;0;True;0;None;;False;white;LockedToTexture2D;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;3521.02,445.3776;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;203;3817.193,811.4822;Float;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;204;3892.328,907.345;Float;False;Constant;_Float2;Float 2;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;186;2766.872,-131.9685;Float;True;Property;_TextureSample4;Texture Sample 4;19;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;202;3727.807,719.5058;Float;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;201;4046.051,545.3134;Float;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;7;4048.335,379.2421;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GammaToLinearNode;194;3768.439,-17.52182;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LinearToGammaNode;198;3503.09,93.27309;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;196;4029.675,-194.7252;Float;True;Property;_TextureSample0;Texture Sample 0;19;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;195;4698.421,76.05832;Float;False;True;True;True;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;205;4310.389,84.70354;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;23;-2302.994,835.6775;Float;True;Property;_Texture0;Texture 0;1;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture3D;0;1;SAMPLER3D;0
Node;AmplifyShaderEditor.TexturePropertyNode;15;3209.25,162.227;Float;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;3817.682,372.744;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-585.6987,1459.597;Float;False;Global;_NoiseMove;_NoiseMove;4;0;Create;True;0;0;True;0;0;0.3120127;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;197;3441.04,-244.2222;Float;True;Global;Texture1;Texture 1;3;0;Create;True;0;0;True;0;None;None;False;white;LockedToTexture2D;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;4478.051,243.6248;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;3513.698,200.8787;Float;True;Property;_bla;bla;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;5;4080.002,112.9722;Float;False;FLOAT4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;200;4719.291,-95.89806;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;147;5093.745,184.8272;Float;False;True;2;Float;ASEMaterialInspector;0;1;Deckard/MultiPassAlpha;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;4;1;False;-1;1;False;-1;0;1;False;-1;10;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;0;False;-1;True;0;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;3;0;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;20;0;6;0
WireConnection;186;0;26;0
WireConnection;201;0;186;1
WireConnection;201;2;202;0
WireConnection;201;3;203;0
WireConnection;201;4;204;0
WireConnection;7;1;20;0
WireConnection;194;0;186;1
WireConnection;198;0;186;4
WireConnection;196;0;197;0
WireConnection;195;0;10;0
WireConnection;205;0;2;1
WireConnection;205;1;201;0
WireConnection;19;0;20;0
WireConnection;10;0;201;0
WireConnection;10;1;7;0
WireConnection;2;0;15;0
WireConnection;5;0;2;0
WireConnection;200;0;10;0
WireConnection;147;0;10;0
ASEEND*/
//CHKSM=FF7C29625BD0B915F5C0FC3C0384EE08724E56AC