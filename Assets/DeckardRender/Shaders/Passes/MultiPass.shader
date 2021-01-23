// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Deckard/MultiPass"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "black" {}
		_saturation("saturation", Float) = 1
		_expose("expose", Float) = 1
		_dLUT("_dLUT", 3D) = "white" {}
		_ChromaticAbberation("ChromaticAbberation", Float) = 0
		_Gain("_Gain", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" }
	LOD 0

		CGINCLUDE
		#pragma target 4.0
		ENDCG
		Blend One One , One One
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
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
				float4 ase_texcoord1 : TEXCOORD1;
			};

			uniform sampler2D _DeckardDepth;
			uniform float _DeckardFocusDistance;
			uniform float _DeckardFocusTest;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _saturation;
			uniform float _expose;
			uniform sampler3D _dLUT;
			uniform float _filmResponseValue;
			uniform float _renderSteps;
			uniform float _deckardInterpolator;
			uniform float _ChromaticAbberation;
			uniform float _Gain;
			uniform float4 _DeckardDepth_ST;
			uniform float _DeckardDepthScale;
			uniform float _DeckardDepthOffset;
			uniform float _DeckardDepthTest;
			float DepthConvert109( sampler2D DepthTex , float4 UVScreens )
			{
				float dpth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(DepthTex,UNITY_PROJ_COORD(UVScreens))));
				return dpth;
			}
			
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
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
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
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
				float4 color107 = IsGammaSpace() ? float4(1,0,0,0) : float4(1,0,0,0);
				float4 color108 = IsGammaSpace() ? float4(0,0.7931032,1,0) : float4(0,0.5922036,1,0);
				sampler2D DepthTex109 = _DeckardDepth;
				float4 screenPos = i.ase_texcoord;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 UVScreens109 = ase_screenPosNorm;
				float localDepthConvert109 = DepthConvert109( DepthTex109 , UVScreens109 );
				float4 lerpResult106 = lerp( color107 , color108 , step( localDepthConvert109 , _DeckardFocusDistance ));
				float4 lerpResult162 = lerp( float4( 1,1,1,0 ) , lerpResult106 , _DeckardFocusTest);
				float2 uv0_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode2 = tex2D( _MainTex, uv0_MainTex );
				float4 appendResult5 = (float4(tex2DNode2));
				float3 hsvTorgb227 = RGBToHSV( appendResult5.xyz );
				float3 hsvTorgb228 = HSVToRGB( float3(hsvTorgb227.x,( hsvTorgb227.y * _saturation ),( hsvTorgb227.z * _expose )) );
				float3 temp_output_136_0 = ( hsvTorgb228 * float3( 1,1,1 ) );
				half3 linearToGamma96 = temp_output_136_0;
				linearToGamma96 = half3( LinearToGammaSpaceExact(linearToGamma96.r), LinearToGammaSpaceExact(linearToGamma96.g), LinearToGammaSpaceExact(linearToGamma96.b) );
				half3 gammaToLinear94 = tex3D( _dLUT, linearToGamma96 ).rgb;
				gammaToLinear94 = half3( GammaToLinearSpaceExact(gammaToLinear94.r), GammaToLinearSpaceExact(gammaToLinear94.g), GammaToLinearSpaceExact(gammaToLinear94.b) );
				float3 lerpResult142 = lerp( temp_output_136_0 , gammaToLinear94 , _filmResponseValue);
				float temp_output_7_0 = ( 1.0 / ( ( _renderSteps * 2.0 ) + 2.0 ) );
				float iter139 = _deckardInterpolator;
				float3 hsvTorgb3_g14 = HSVToRGB( float3(( iter139 + 0.1 ),1.0,1.0) );
				float3 lerpResult99 = lerp( ( hsvTorgb3_g14 * ( ( 1.0 - _ChromaticAbberation ) + 1.0 ) ) , float3( 1,1,1 ) , _ChromaticAbberation);
				float2 uv_DeckardDepth = i.ase_texcoord1.xy * _DeckardDepth_ST.xy + _DeckardDepth_ST.zw;
				float4 temp_cast_4 = ((tex2D( _DeckardDepth, uv_DeckardDepth ).r*_DeckardDepthScale + _DeckardDepthOffset)).xxxx;
				float4 lerpResult185 = lerp( ( lerpResult162 * float4( ( ( lerpResult142 * temp_output_7_0 ) * lerpResult99 ) , 0.0 ) * _Gain ) , temp_cast_4 , _DeckardDepthTest);
				float4 appendResult196 = (float4((lerpResult185).rgb , ( 0.0 * temp_output_7_0 )));
				
				
				finalColor = appendResult196;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17701
1275;503;1710;745;1586.317;796.6243;1.3;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;15;-2124.286,-618.1688;Float;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;True;0;None;None;False;black;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;235;-1866.703,-426.0911;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-661.17,-536.532;Inherit;True;Property;_bla;bla;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipBias;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;5;103.0672,-84.10232;Inherit;False;FLOAT4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RGBToHSVNode;227;500.2568,-144.433;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;233;519.7598,269.6241;Float;False;Property;_expose;expose;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;230;452.7798,167.4047;Float;False;Property;_saturation;saturation;3;0;Create;True;0;0;False;0;1;1.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;232;804.7538,131.51;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;229;737.7738,29.29056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;228;882.2568,-130.433;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;164;-961.2462,733.8032;Float;False;Global;_deckardInterpolator;_deckardInterpolator;17;0;Create;True;0;0;False;0;0;0.875;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;1114.468,81.21841;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;95;1308.895,302.064;Float;True;Property;_dLUT;_dLUT;5;0;Create;True;0;0;False;0;None;d54551e395b1e844a811d6e2ed0acf30;False;white;LockedToTexture3D;Texture3D;-1;0;1;SAMPLER3D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;724.7168,913.149;Float;False;iter;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;304.8169,894.4352;Float;False;Global;_renderSteps;_renderSteps;0;0;Create;True;0;0;True;0;10;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;1044.443,966.5066;Float;False;Property;_ChromaticAbberation;ChromaticAbberation;8;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LinearToGammaNode;96;1277.956,186.2363;Inherit;False;1;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;417.7561,746.4345;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;112;2608.865,23.94483;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;26;2461.435,-152.2989;Float;True;Global;_DeckardDepth;_DeckardDepth;2;0;Create;True;0;0;True;0;None;;False;white;LockedToTexture2D;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;93;1622.89,247.2236;Inherit;True;Property;_TextureSample6;Texture Sample 6;7;0;Create;True;0;0;False;0;-1;81fc6d79243b09b459232b9cec81fa5e;81fc6d79243b09b459232b9cec81fa5e;True;0;False;white;Auto;False;Object;-1;Auto;Texture3D;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;170;1239.121,1226.935;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;167;1027.548,1387.608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;98;1285.046,1358.066;Inherit;False;Simple HUE;-1;;14;32abb5f0db087604486c2db83a2e817a;0;1;1;FLOAT;0;False;4;FLOAT3;6;FLOAT;7;FLOAT;5;FLOAT;8
Node;AmplifyShaderEditor.SimpleAddOpNode;19;637.7343,698.4642;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;2809.811,196.8246;Float;False;Global;_DeckardFocusDistance;_DeckardFocusDistance;14;0;Create;True;0;0;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;109;2877.45,-24.28161;Float;False;float dpth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(DepthTex,UNITY_PROJ_COORD(UVScreens))))@$return dpth@;1;False;2;True;DepthTex;SAMPLER2D;_Sampler0109;In;;Float;False;True;UVScreens;FLOAT4;0,0,0,0;In;;Float;False;DepthConvert;True;False;0;2;0;SAMPLER2D;_Sampler0109;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GammaToLinearNode;94;1973.929,298.1906;Inherit;False;1;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;169;1411.396,1142.393;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;1965.316,395.0614;Float;False;Global;_filmResponseValue;_filmResponseValue;15;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;107;2104.786,-523.1636;Float;False;Constant;_Color2;Color 2;15;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;142;2337.858,274.7523;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;108;2162.679,-257.6361;Float;False;Constant;_Color3;Color 3;15;0;Create;True;0;0;False;0;0,0.7931032,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;7;1286.47,692.1254;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;104;3135.118,137.9235;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;1572.506,1108.895;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;2592.73,453.6938;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;163;2821.803,285.8515;Float;False;Global;_DeckardFocusTest;_DeckardFocusTest;18;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;106;3109.592,-154.6189;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;99;1660.63,838.2513;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;1,1,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;179;3688.676,577.6772;Float;False;Property;_Gain;_Gain;12;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;2911.196,507.6975;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;162;3293.912,285.2604;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;188;3701.554,155.6201;Float;False;Global;_DeckardDepthScale;_DeckardDepthScale;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;186;3280.969,-341.6006;Inherit;True;Property;_TextureSample4;Texture Sample 4;19;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;189;3745.804,229.8278;Float;False;Global;_DeckardDepthOffset;_DeckardDepthOffset;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;3891.443,368.4507;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;184;4048.248,557.5269;Float;False;Global;_DeckardDepthTest;_DeckardDepthTest;18;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;187;4002.093,32.67739;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;185;4275.895,288.9468;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;195;4625.428,296.8715;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;4898.556,408.7289;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;87;793.1214,305.0185;Float;False;Constant;_Color0;Color 0;10;0;Create;True;0;0;False;0;0.1999998,0,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;89;832.0681,644.8141;Float;False;Property;_abberationStep;_abberationStep;7;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;132;624.994,488.3528;Float;False;Constant;_Float12;Float 12;18;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;130;-2178.38,-843.5028;Inherit;False;DeckardTime;-1;;15;e4f3ae0481d4c844ca4007e0512ce67f;0;1;2;FLOAT;-1.74;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;16.64692,202.0373;Float;False;Property;_NoisePower;NoisePower;6;0;Create;True;0;0;False;0;1.031384;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;236;-1618.703,-752.0911;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;-1366.661,-955.8825;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;253;-239.417,-493.7242;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;-86.01703,-180.4242;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.5,0.5,0.5,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;218;-615.4018,1125.736;Inherit;False;DeckardTime;-1;;16;e4f3ae0481d4c844ca4007e0512ce67f;0;1;2;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1118.87,119.9088;Float;False;Property;_Float10;Float 10;10;0;Create;True;0;0;False;0;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;196;5197.375,377.1373;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;23;-2302.994,835.6775;Float;True;Property;_Texture0;Texture 0;1;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture3D;-1;0;1;SAMPLER3D;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-886.9926,-371.9855;Float;False;Property;_Float0;Float 0;11;0;Create;True;0;0;False;0;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;234;-927.3224,-687.0333;Inherit;False;Constant;_difraction;difraction;22;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;246;-1913.625,-1062.732;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;10;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;240;-2302.503,-1093.291;Inherit;False;Property;_DifractionScale;DifractionScale;14;0;Create;True;0;0;False;0;0;23.63;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;118;-756.3256,-139.5125;Float;False;float fade@$for(int i=1@ i<Iterations@ i++)${ $fade = (Iterations - (i / 2.0))@$finalColor =  tex2D( tex, uv_Texture0 + float2((OffsetX.x * i) - (OffsetX.x * Iterations *0.5), (OffsetX.y * i) - (OffsetX.y * Iterations *0.5)  ))  + finalColor @$}$$finalColor = finalColor / Iterations@			return finalColor@;4;False;6;True;tex;SAMPLER2D;sampler02;In;;Float;False;True;uv_Texture0;FLOAT2;0,0;In;;Float;False;True;Iterations;FLOAT;2;In;;Float;False;True;OffsetX;FLOAT2;0,0;In;;Float;False;True;noise;SAMPLER2D;_Sampler4118;In;;Float;False;True;finalColor;FLOAT4;0,0,0,0;Out;;Float;False;Blur;True;False;0;6;0;SAMPLER2D;sampler02;False;1;FLOAT2;0,0;False;2;FLOAT;2;False;3;FLOAT2;0,0;False;4;SAMPLER2D;_Sampler4118;False;5;FLOAT4;0,0,0,0;False;2;FLOAT4;0;FLOAT4;6
Node;AmplifyShaderEditor.SimpleAddOpNode;241;-1822.305,-692.816;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;247;-1168.025,-704.3322;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-1161.65,-206.3248;Float;False;Property;_ITer;ITer;9;0;Create;True;0;0;False;0;6.7;46.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-1513.981,-129.2486;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;239;-1612.703,-625.0911;Inherit;False;Property;_DifractionAmount;DifractionAmount;13;0;Create;True;0;0;False;0;0;4.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;244;-1366.905,-393.016;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;250;-1142.673,-1077.138;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;90;1278.894,539.4371;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;1,1,1,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexelSizeNode;249;-1469.243,-1201.312;Inherit;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;243;-1603.905,-355.016;Inherit;False;Global;_DeckardAngle;_DeckardAngle;14;0;Create;True;0;0;False;0;0,0,0,0;0.3273969,0.2067684,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;251;-206.9485,-346.3657;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;86;1086.572,528.2229;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-758.4401,204.4572;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;237;-1197.703,-573.291;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-993.4828,236.4489;Inherit;False;139;iter;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;245;-1707.225,-1053.132;Inherit;True;Property;_Noise;Noise;15;0;Create;True;0;0;False;0;-1;6f9a0e55e3ffc6044944be5e3035e195;499c13baaf0a16b4ea170bf3c3cbf0bd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;88;827.8679,458.9145;Float;False;Constant;_Color1;Color 1;10;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;147;5630.161,364.7988;Float;False;True;-1;2;ASEMaterialInspector;0;1;Deckard/MultiPass;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;4;1;False;-1;1;False;-1;4;1;False;-1;1;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;0;False;-1;True;0;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Transparent=RenderType;True;4;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;235;2;15;0
WireConnection;2;0;15;0
WireConnection;2;1;235;0
WireConnection;5;0;2;0
WireConnection;227;0;5;0
WireConnection;232;0;227;3
WireConnection;232;1;233;0
WireConnection;229;0;227;2
WireConnection;229;1;230;0
WireConnection;228;0;227;1
WireConnection;228;1;229;0
WireConnection;228;2;232;0
WireConnection;136;0;228;0
WireConnection;139;0;164;0
WireConnection;96;0;136;0
WireConnection;20;0;6;0
WireConnection;93;0;95;0
WireConnection;93;1;96;0
WireConnection;170;0;100;0
WireConnection;167;0;139;0
WireConnection;98;1;167;0
WireConnection;19;0;20;0
WireConnection;109;0;26;0
WireConnection;109;1;112;0
WireConnection;94;0;93;0
WireConnection;169;0;170;0
WireConnection;142;0;136;0
WireConnection;142;1;94;0
WireConnection;142;2;143;0
WireConnection;7;1;19;0
WireConnection;104;0;109;0
WireConnection;104;1;105;0
WireConnection;168;0;98;6
WireConnection;168;1;169;0
WireConnection;10;0;142;0
WireConnection;10;1;7;0
WireConnection;106;0;107;0
WireConnection;106;1;108;0
WireConnection;106;2;104;0
WireConnection;99;0;168;0
WireConnection;99;2;100;0
WireConnection;85;0;10;0
WireConnection;85;1;99;0
WireConnection;162;1;106;0
WireConnection;162;2;163;0
WireConnection;186;0;26;0
WireConnection;101;0;162;0
WireConnection;101;1;85;0
WireConnection;101;2;179;0
WireConnection;187;0;186;1
WireConnection;187;1;188;0
WireConnection;187;2;189;0
WireConnection;185;0;101;0
WireConnection;185;1;187;0
WireConnection;185;2;184;0
WireConnection;195;0;185;0
WireConnection;212;1;7;0
WireConnection;236;1;240;0
WireConnection;238;0;245;0
WireConnection;238;1;239;0
WireConnection;238;2;244;0
WireConnection;253;0;2;0
WireConnection;253;1;118;6
WireConnection;252;0;251;0
WireConnection;196;0;195;0
WireConnection;196;3;212;0
WireConnection;246;0;241;0
WireConnection;246;1;240;0
WireConnection;246;2;244;0
WireConnection;118;0;15;0
WireConnection;118;1;21;0
WireConnection;118;2;120;0
WireConnection;118;3;247;0
WireConnection;241;0;235;0
WireConnection;241;1;130;0
WireConnection;247;0;244;0
WireConnection;247;1;239;0
WireConnection;247;2;250;0
WireConnection;21;2;15;0
WireConnection;244;0;243;1
WireConnection;244;1;243;2
WireConnection;250;0;249;1
WireConnection;250;1;249;2
WireConnection;90;0;86;0
WireConnection;249;0;15;0
WireConnection;251;1;118;6
WireConnection;86;0;87;0
WireConnection;86;1;88;0
WireConnection;86;2;89;0
WireConnection;141;0;121;0
WireConnection;141;1;140;0
WireConnection;237;0;247;0
WireConnection;237;1;235;0
WireConnection;245;1;246;0
WireConnection;147;0;196;0
ASEEND*/
//CHKSM=93C35AF10AFC2DFB32B065E66687DD6EEEF881B4