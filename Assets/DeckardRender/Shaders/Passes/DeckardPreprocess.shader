// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Deckard/PreProcess"
{
	Properties
	{
		_step("step", Float) = 0
		_MainTex("_MainTex", 2D) = "white" {}
		_ITer("ITer", Float) = 6.7
		_Float10("Float 10", Float) = 0.01
		_StreakIntensity("StreakIntensity", Float) = 0.9
		_StreakColor("StreakColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend One Zero , One OneMinusSrcAlpha
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

			uniform float _step;
			uniform float _renderSteps;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _DeckardExposure;
			uniform float _ITer;
			uniform float4 _DeckardAngle;
			uniform float _Float10;
			uniform sampler2D _Sampler46;
			uniform float _StreakIntensity;
			uniform float4 _StreakColor;
			float4 Blur6( sampler2D tex , float2 uv_Texture0 , float Iterations , float2 OffsetX , sampler2D noise , out float4 finalColor )
			{
				float fade;
				for(float i=1; i<Iterations; i++)
				{ 
				fade = 1 - (i/Iterations);
				finalColor =  tex2D( tex, uv_Texture0 + (OffsetX * i)) * fade + finalColor;
				}
				finalColor = finalColor;			return finalColor;
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
				float4 tex2DNode3 = tex2D( _MainTex, uv_MainTex );
				sampler2D tex6 = _MainTex;
				float2 uv0_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv_Texture06 = uv0_MainTex;
				float Iterations6 = _ITer;
				float2 OffsetX6 = ( (_DeckardAngle).xy * _Float10 );
				sampler2D noise6 = _Sampler46;
				float4 finalColor6 = float4( 0,0,0,0 );
				float4 localBlur6 = Blur6( tex6 , uv_Texture06 , Iterations6 , OffsetX6 , noise6 , finalColor6 );
				float4 temp_output_14_0 = ( pow( finalColor6 , 1.55 ) * _StreakIntensity * _StreakColor );
				float4 appendResult46 = (float4((( ( tex2DNode3 * _DeckardExposure ) + ( temp_output_14_0 * _DeckardExposure ) )).rgb , tex2DNode3.a));
				
				
				finalColor = appendResult46;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16800
637.3334;482.6667;1752;465;1379.915;455.0223;2.537733;True;True
Node;AmplifyShaderEditor.Vector4Node;22;-874.4051,974.7159;Float;False;Global;_DeckardAngle;_DeckardAngle;8;0;Create;True;0;0;False;0;0,0,0,0;0.9340611,-0.1801164,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;1;-633.4,-112.6;Float;True;Property;_MainTex;_MainTex;2;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ComponentMaskNode;23;-339.4401,913.0386;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-311.0007,1082.368;Float;False;Property;_Float10;Float 10;4;0;Create;True;0;0;False;0;0.01;0.001;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-158.7939,610.476;Float;False;Property;_ITer;ITer;3;0;Create;True;0;0;False;0;6.7;24.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;11.82703,876.191;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-381.8275,385.2437;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;6;17.57673,1049.14;Float;False;float fade@$$for(float i=1@ i<Iterations@ i++)${ $fade = 1 - (i/Iterations)@$finalColor =  tex2D( tex, uv_Texture0 + (OffsetX * i)) * fade + finalColor@$}$$$finalColor = finalColor@			return finalColor@;4;False;6;True;tex;SAMPLER2D;sampler02;In;;Float;False;True;uv_Texture0;FLOAT2;0,0;In;;Float;False;True;Iterations;FLOAT;2;In;;Float;False;True;OffsetX;FLOAT2;0,0;In;;Float;False;True;noise;SAMPLER2D;_Sampler46;In;;Float;False;True;finalColor;FLOAT4;0,0,0,0;Out;;Float;False;Blur;True;False;0;6;0;SAMPLER2D;sampler02;False;1;FLOAT2;0,0;False;2;FLOAT;2;False;3;FLOAT2;0,0;False;4;SAMPLER2D;_Sampler46;False;5;FLOAT4;0,0,0,0;False;2;FLOAT4;0;FLOAT4;6
Node;AmplifyShaderEditor.RangedFloatNode;13;456.5126,514.7899;Float;False;Property;_StreakIntensity;StreakIntensity;6;0;Create;True;0;0;False;0;0.9;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;15;478.3828,679.9141;Float;False;Property;_StreakColor;StreakColor;7;0;Create;True;0;0;False;0;0,0,0,0;0.2132353,0.3163285,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;44;461.8052,327.8609;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1.55;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;748.9788,220.0359;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;4;53.02878,146.0349;Float;False;Global;_DeckardExposure;_DeckardExposure;2;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-329.3,-109.9;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;443.5808,-76.40732;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;974.8732,141.7548;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;1347.681,110.4583;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;47;1529.889,195.7962;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;24;-57.39232,749.3692;Float;False;Constant;_Vector1;Vector 1;8;0;Create;True;0;0;False;0;0.002,0.002;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-90.27603,469.9131;Float;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureArrayNode;35;-1052.38,-0.855572;Float;True;Property;_TextureArray0;Texture Array 0;9;0;Create;True;0;0;False;0;None;0;Object;-1;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-1292.01,814.8483;Float;False;Global;_renderSteps;_renderSteps;0;0;Create;True;0;0;True;0;10;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-658.9033,430.2004;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;39;966.1482,388.4145;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1089.967,482.9829;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1000;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-861.2357,573.1527;Float;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;False;0;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;45;910.5989,-214.9171;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-736.9917,757.1763;Float;False;iter;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-454.3715,520.3704;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.02941179;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;36;-1587,375.2188;Float;False;Global;_DeckardTime;_DeckardTime;10;0;Create;True;0;0;False;0;0,0,0,0;0.001024306,0.02048611,0.04097223,0.06145834;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-1283.701,274.0527;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;40;-1560.863,273.1583;Float;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;46;1768.38,212.2487;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;20;-906.6584,751.0535;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosterizeNode;41;-585.9877,1145.159;Float;False;31;2;1;COLOR;0,0,0,0;False;0;INT;31;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-460.6513,726.4962;Float;False;21;iter;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-682.9034,614.9388;Float;False;Property;_NoiseDisplace;NoiseDisplace;8;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;-1492.425,76.11861;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;27;-1812.122,-152.605;Float;True;Property;_Noise;Noise;1;0;Create;True;0;0;False;0;None;518b8337a0340444aa49dd0780efa9c2;False;white;LockedToTexture2DArray;Texture2DArray;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;11;161.447,742.3016;Float;False;Property;_StreakThreshold;StreakThreshold;5;0;Create;True;0;0;False;0;0;0.485;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;760.2026,804.6605;Float;False;Global;_deckardInterpolator;_deckardInterpolator;10;0;Create;True;0;0;False;0;0;1.966667;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;43;864.9893,594.1138;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1307.3,663.5666;Float;False;Property;_step;step;0;0;Create;True;0;0;True;0;0;20.62;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1966.328,210.0305;Float;False;True;2;Float;ASEMaterialInspector;0;1;Deckard/PreProcess;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;3;1;False;-1;10;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Transparent=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;0;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;23;0;22;0
WireConnection;10;0;23;0
WireConnection;10;1;8;0
WireConnection;5;2;1;0
WireConnection;6;0;1;0
WireConnection;6;1;5;0
WireConnection;6;2;7;0
WireConnection;6;3;10;0
WireConnection;44;0;6;6
WireConnection;14;0;44;0
WireConnection;14;1;13;0
WireConnection;14;2;15;0
WireConnection;3;0;1;0
WireConnection;2;0;3;0
WireConnection;2;1;4;0
WireConnection;16;0;14;0
WireConnection;16;1;4;0
WireConnection;17;0;2;0
WireConnection;17;1;16;0
WireConnection;47;0;17;0
WireConnection;29;0;5;0
WireConnection;29;1;32;0
WireConnection;35;6;27;0
WireConnection;35;0;38;0
WireConnection;35;1;37;0
WireConnection;30;0;35;0
WireConnection;30;1;31;0
WireConnection;39;0;14;0
WireConnection;37;0;36;2
WireConnection;45;0;3;0
WireConnection;21;0;20;0
WireConnection;32;0;30;0
WireConnection;32;1;34;0
WireConnection;38;0;33;0
WireConnection;38;1;40;0
WireConnection;38;2;36;2
WireConnection;46;0;47;0
WireConnection;46;3;3;4
WireConnection;20;0;19;0
WireConnection;20;1;18;0
WireConnection;41;1;22;0
WireConnection;33;2;27;0
WireConnection;43;2;42;0
WireConnection;0;0;46;0
ASEEND*/
//CHKSM=C890D82B5DBB5AC6AACF4F2948EB9BBE98860969