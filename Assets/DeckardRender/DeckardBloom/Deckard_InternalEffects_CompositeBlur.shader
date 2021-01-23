// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Deckard/InternalEffects/CompositeBlur"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
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

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _DeckardBlurRT;
			uniform float4 _DeckardBlurRT_ST;
			uniform float _deckardInterpolator;
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			
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
				float2 uv_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv_DeckardBlurRT = i.ase_texcoord.xy * _DeckardBlurRT_ST.xy + _DeckardBlurRT_ST.zw;
				float2 uv0_DeckardBlurRT = i.ase_texcoord.xy * _DeckardBlurRT_ST.xy + _DeckardBlurRT_ST.zw;
				float lerpResult25 = lerp( 5.0 , 0.5 , _deckardInterpolator);
				float3 hsvTorgb3_g1 = HSVToRGB( float3(( _deckardInterpolator + 0.0 ),1.0,1.0) );
				
				
				finalColor = ( pow( tex2D( _MainTex, uv_MainTex ) , 1.0 ) + ( pow( ( ( tex2D( _DeckardBlurRT, uv_DeckardBlurRT ) * 10.0 ) + ( tex2D( _DeckardBlurRT, ( ( ( uv0_DeckardBlurRT + float2( -0.5,-0.5 ) ) * float2( -0.3,-0.3 ) * lerpResult25 ) + float2( 0.5,0.5 ) ) ) * float4( 0.7003676,0.7191937,0.75,0 ) * float4( hsvTorgb3_g1 , 0.0 ) ) ) , 0.92 ) * float4( 0.1202963,0.1286205,0.1838235,0 ) ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16800
368.6667;438;1752;461;1592.727;172.9188;2.128538;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;4;-760.6794,248.875;Float;True;Global;_DeckardBlurRT;_DeckardBlurRT;1;0;Create;True;0;0;True;0;None;;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-462.0109,483.5822;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;-501.5246,1005.182;Float;False;Global;_deckardInterpolator;_deckardInterpolator;17;0;Create;True;0;0;False;0;0;1.981132;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-217.4482,749.3688;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;25;-30.81825,945.0115;Float;False;3;0;FLOAT;5;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-26.65154,751.6249;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;-0.3,-0.3;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-71.61203,1148.879;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;240.4731,622.88;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;9;524.282,583.9114;Float;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-138.4775,456.289;Float;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-367.7,187.6002;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;26;93.70786,1097.74;Float;False;Simple HUE;-1;;1;32abb5f0db087604486c2db83a2e817a;0;1;1;FLOAT;0;False;4;FLOAT3;6;FLOAT;7;FLOAT;5;FLOAT;8
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;338.5324,308.1438;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0.7003676,0.7191937,0.75,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;25.32099,215.2749;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;-596.5,-128;Float;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;187.2949,87.27053;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-257.5,-105;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;23;364.9532,121.0447;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.92;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;627.7462,146.7025;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.1202963,0.1286205,0.1838235,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;19;166.8267,-49.59222;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-455.6066,664.509;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;97.81542,356.0828;Float;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;665.4738,-33.1077;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;28;-300.0168,1172.828;Float;False;1;2;1;COLOR;0,0,0,0;False;0;INT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;11;-685.3699,646.2399;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;892.7365,-22.05684;Float;False;True;2;Float;ASEMaterialInspector;0;1;Deckard/InternalEffects/CompositeBlur;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;17;2;4;0
WireConnection;22;0;17;0
WireConnection;25;2;24;0
WireConnection;12;0;22;0
WireConnection;12;2;25;0
WireConnection;29;0;24;0
WireConnection;21;0;12;0
WireConnection;9;0;4;0
WireConnection;9;1;21;0
WireConnection;3;0;4;0
WireConnection;26;1;29;0
WireConnection;13;0;9;0
WireConnection;13;2;26;6
WireConnection;6;0;3;0
WireConnection;6;1;7;0
WireConnection;5;0;6;0
WireConnection;5;1;13;0
WireConnection;2;0;1;0
WireConnection;23;0;5;0
WireConnection;27;0;23;0
WireConnection;19;0;2;0
WireConnection;16;0;11;1
WireConnection;16;1;11;2
WireConnection;20;0;19;0
WireConnection;20;1;27;0
WireConnection;28;1;24;0
WireConnection;0;0;20;0
ASEEND*/
//CHKSM=363DB3CF51DD19B8F915EA5C867FC64F31449513