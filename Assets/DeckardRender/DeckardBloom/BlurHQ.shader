// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Deckard/BlurHQ"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_Iterations("Iterations", Int) = 50
		_blurOffset("_blurOffset", Vector) = (0.003,0,0,0)
		_blur("_blur", Float) = 1
		_LensFlares("LensFlares", Float) = 1
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
				
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
			};

			uniform sampler2D _MainTex;
			uniform float2 _blurOffset;
			uniform float _blur;
			uniform float4 _MainTex_TexelSize;
			uniform float _deckardInterpolator;
			uniform int _Iterations;
			uniform sampler2D _Sampler42;
			uniform float _LensFlares;
			float4 Blur2( sampler2D tex , float2 uv_Texture0 , float Iterations , float2 OffsetX , sampler2D noise , out float4 finalColor )
			{
				float fade = 0;
				float factor = 6.28319/ 2 / Iterations;
				for(float i=0; i<Iterations; i++)
				{ 
				fade = (i/Iterations);
				finalColor =  (tex2D( tex, uv_Texture0 + (OffsetX * i)) * sin(factor * i)) + finalColor;
				}
				finalColor = finalColor;			return finalColor;
			}
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				
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
				sampler2D tex2 = _MainTex;
				float4 screenPos = i.ase_texcoord;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult13 = (float2(_MainTex_TexelSize.x , _MainTex_TexelSize.y));
				float lerpResult18 = lerp( 0.5 , 3.0 , _deckardInterpolator);
				float2 temp_output_14_0 = ( _blurOffset * _blur * appendResult13 * lerpResult18 );
				float2 uv_Texture02 = ( ase_screenPosNorm - float4( ( temp_output_14_0 * _Iterations * 0.5 ), 0.0 , 0.0 ) ).xy;
				float Iterations2 = (float)_Iterations;
				float2 OffsetX2 = temp_output_14_0;
				sampler2D noise2 = _Sampler42;
				float4 finalColor2 = float4( 0,0,0,0 );
				float4 localBlur2 = Blur2( tex2 , uv_Texture02 , Iterations2 , OffsetX2 , noise2 , finalColor2 );
				
				
				finalColor = ( ( finalColor2 / _Iterations ) * _LensFlares );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16800
1266;874;1751;1225;616.4509;532.4682;1.3;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;1;-1019.6,-200.1999;Float;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-581.7526,690.1731;Float;False;Global;_deckardInterpolator;_deckardInterpolator;17;0;Create;True;0;0;False;0;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexelSizeNode;12;-693.1523,-55.95019;Float;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-731.3672,551.7613;Float;False;Property;_blur;_blur;3;0;Create;True;0;0;False;0;1;391.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;18;-268.5526,712.5737;Float;False;3;0;FLOAT;0.5;False;1;FLOAT;3;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-389.6526,29.54988;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;7;-543.9996,406.5998;Float;False;Property;_blurOffset;_blurOffset;2;0;Create;True;0;0;False;0;0.003,0;0,-0.006;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.IntNode;4;277.965,421.1555;Float;False;Property;_Iterations;Iterations;1;0;Create;True;0;0;False;0;50;18;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-285.7675,385.3609;Float;False;4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-134.7519,479.2498;Float;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;3;-780.4001,129.9;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-153.6516,148.5498;Float;False;3;3;0;FLOAT2;0,0;False;1;INT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;-223.1518,-6.950195;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomExpressionNode;2;123.8,-18.80001;Float;False;float fade = 0@$float factor = 6.28319/ 2 / Iterations@$for(float i=0@ i<Iterations@ i++)${ $fade = (i/Iterations)@$finalColor =  (tex2D( tex, uv_Texture0 + (OffsetX * i)) * sin(factor * i)) + finalColor@$}$$$finalColor = finalColor@			return finalColor@;4;False;6;True;tex;SAMPLER2D;sampler02;In;;Float;False;True;uv_Texture0;FLOAT2;0,0;In;;Float;False;True;Iterations;FLOAT;2;In;;Float;False;True;OffsetX;FLOAT2;0,0;In;;Float;False;True;noise;SAMPLER2D;_Sampler42;In;;Float;False;True;finalColor;FLOAT4;0,0,0,0;Out;;Float;False;Blur;True;False;0;6;0;SAMPLER2D;sampler02;False;1;FLOAT2;0,0;False;2;FLOAT;2;False;3;FLOAT2;0,0;False;4;SAMPLER2D;_Sampler42;False;5;FLOAT4;0,0,0,0;False;2;FLOAT4;0;FLOAT4;6
Node;AmplifyShaderEditor.SimpleDivideOpNode;6;633.0994,28.80004;Float;False;2;0;FLOAT4;0,0,0,0;False;1;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;20;619.8491,317.7318;Float;False;Property;_LensFlares;LensFlares;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;834.3492,94.13174;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-251.3525,578.1736;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1042.4,38.59999;Float;False;True;2;Float;ASEMaterialInspector;0;1;Deckard/BlurHQ;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;12;0;1;0
WireConnection;18;2;16;0
WireConnection;13;0;12;1
WireConnection;13;1;12;2
WireConnection;14;0;7;0
WireConnection;14;1;15;0
WireConnection;14;2;13;0
WireConnection;14;3;18;0
WireConnection;9;0;14;0
WireConnection;9;1;4;0
WireConnection;9;2;11;0
WireConnection;10;0;3;0
WireConnection;10;1;9;0
WireConnection;2;0;1;0
WireConnection;2;1;10;0
WireConnection;2;2;4;0
WireConnection;2;3;14;0
WireConnection;6;0;2;6
WireConnection;6;1;4;0
WireConnection;19;0;6;0
WireConnection;19;1;20;0
WireConnection;17;0;16;0
WireConnection;0;0;19;0
ASEEND*/
//CHKSM=B7CA8BAFF1B31324A353DE6DF6C758F0375FA944