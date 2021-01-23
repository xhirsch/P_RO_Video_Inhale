// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Deckard/facebookDepthBuffer"
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
				UNITY_VERTEX_OUTPUT_STEREO
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
			};

			uniform sampler2D _LastCameraDepthTexture;
			uniform float4 _LastCameraDepthTexture_ST;
			uniform float _DeckardDepthScale;
			uniform float _DeckardDepthOffset;
			
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
				fixed4 finalColor;
				float2 uv_LastCameraDepthTexture = i.ase_texcoord.xy * _LastCameraDepthTexture_ST.xy + _LastCameraDepthTexture_ST.zw;
				float temp_output_3_0 = (tex2D( _LastCameraDepthTexture, uv_LastCameraDepthTexture ).r*_DeckardDepthScale + _DeckardDepthOffset);
				float3 temp_cast_0 = (temp_output_3_0).xxx;
				half3 linearToGamma8 = temp_cast_0;
				linearToGamma8 = half3( LinearToGammaSpaceExact(linearToGamma8.r), LinearToGammaSpaceExact(linearToGamma8.g), LinearToGammaSpaceExact(linearToGamma8.b) );
				half3 linearToGamma11 = linearToGamma8;
				linearToGamma11 = half3( LinearToGammaSpaceExact(linearToGamma11.r), LinearToGammaSpaceExact(linearToGamma11.g), LinearToGammaSpaceExact(linearToGamma11.b) );
				
				
				finalColor = float4( linearToGamma11 , 0.0 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16204
831;466;1365;843;513.3371;558.9977;1.3;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;1;-779.2,-285.1;Float;True;Global;_LastCameraDepthTexture;_LastCameraDepthTexture;0;0;Create;True;0;0;False;0;None;;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-522.912,91.70611;Float;False;Global;_DeckardDepthOffset;_DeckardDepthOffset;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-448,-275.9;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-508.6621,-11.10149;Float;False;Global;_DeckardDepthScale;_DeckardDepthScale;2;0;Create;True;0;0;False;0;1;0.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;3;-21.3,-105.2;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LinearToGammaNode;8;226.3629,6.502268;Float;False;1;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LinearToGammaNode;11;439.5629,74.10231;Float;False;1;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;9;330.3629,236.6023;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GammaToLinearNode;10;293.9629,-115.6977;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;504.9,-69.50001;Float;False;True;2;Float;ASEMaterialInspector;0;1;Deckard/facebookDepthBuffer;0770190933193b94aaa3065e307002fa;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;2;0;1;0
WireConnection;3;0;2;1
WireConnection;3;1;6;0
WireConnection;3;2;7;0
WireConnection;8;0;3;0
WireConnection;11;0;8;0
WireConnection;9;0;3;0
WireConnection;10;0;3;0
WireConnection;0;0;11;0
ASEEND*/
//CHKSM=5DDB910C3B98CC62EDD4A8A7B95890519E8F1C08