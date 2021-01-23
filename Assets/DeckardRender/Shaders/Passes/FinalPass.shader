// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Deckard/FinalPass"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_saturation("saturation", Float) = 1
		_exposure("exposure", Float) = 1
		_Temp("Temp", Range( -1 , 1)) = 0
		_Sharpen("Sharpen", Range( 0 , 1)) = 0
		_SharpenRadius("SharpenRadius", Range( 0 , 5)) = 1
		_CTint("CTint", Range( -0.2 , 0.2)) = 0
		_letterboxing("letterboxing", Range( 0 , 1)) = 0.54
		_ColorOffset("ColorOffset", Float) = 0.4
		_CContrast("CContrast", Float) = 0
		_CMidpoint("CMidpoint", Float) = 0
		_noiseScale("noiseScale", Float) = 1
		_zebras("zebras", Float) = 1
		_DeckardDepthTestEdges("_DeckardDepthTestEdges", Float) = 1
		_PreFinalPAss("PreFinalPAss", Float) = 1
		_NoiseD_A_Amount("NoiseD_A_Amount", Float) = 0
		_ContrVec("ContrVec", Vector) = (0,0,0,0)
		_CMidPointVec("CMidPointVec", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 0

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
			#include "UnityShaderVariables.cginc"


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
			uniform sampler2D _AperturePass;
			uniform float4 _AperturePass_ST;
			uniform float _finalStep;
			uniform float3 _CMidPointVec;
			uniform float3 _ContrVec;
			uniform float4 _AperturePass_TexelSize;
			uniform float _SharpenRadius;
			uniform float _Sharpen;
			uniform float _saturation;
			uniform float _PreFinalPAss;
			uniform float _exposure;
			uniform float _DeckardDepthTestEdges;
			uniform float _ColorOffset;
			uniform float _CMidpoint;
			uniform float _CContrast;
			uniform float _noiseScale;
			uniform float _NoiseD_A_Amount;
			uniform float _Temp;
			uniform float _CTint;
			uniform float _zebras;
			uniform float _letterboxing;
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
			float3 MyCustomExpression1_g2( float Midpoint , float Contrast , float3 In )
			{
				float midpoint = pow(Midpoint, 2.2);
				    return  (In - midpoint) * Contrast + midpoint;
			}
			
			float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
			float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
			float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
			float snoise( float3 v )
			{
				const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
				float3 i = floor( v + dot( v, C.yyy ) );
				float3 x0 = v - i + dot( i, C.xxx );
				float3 g = step( x0.yzx, x0.xyz );
				float3 l = 1.0 - g;
				float3 i1 = min( g.xyz, l.zxy );
				float3 i2 = max( g.xyz, l.zxy );
				float3 x1 = x0 - i1 + C.xxx;
				float3 x2 = x0 - i2 + C.yyy;
				float3 x3 = x0 - 0.5;
				i = mod3D289( i);
				float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
				float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
				float4 x_ = floor( j / 7.0 );
				float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
				float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
				float4 h = 1.0 - abs( x ) - abs( y );
				float4 b0 = float4( x.xy, y.xy );
				float4 b1 = float4( x.zw, y.zw );
				float4 s0 = floor( b0 ) * 2.0 + 1.0;
				float4 s1 = floor( b1 ) * 2.0 + 1.0;
				float4 sh = -step( h, 0.0 );
				float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
				float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
				float3 g0 = float3( a0.xy, h.x );
				float3 g1 = float3( a0.zw, h.y );
				float3 g2 = float3( a1.xy, h.z );
				float3 g3 = float3( a1.zw, h.w );
				float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
				g0 *= norm.x;
				g1 *= norm.y;
				g2 *= norm.z;
				g3 *= norm.w;
				float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
				m = m* m;
				m = m* m;
				float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
				return 42.0 * dot( m, px);
			}
			
			float3 MyCustomExpression1_g20( float Midpoint , float Contrast , float3 In )
			{
				float midpoint = pow(Midpoint, 2.2);
				    return  (In - midpoint) * Contrast + midpoint;
			}
			
			float3 MyCustomExpression1_g19( float Midpoint , float Contrast , float3 In )
			{
				float midpoint = pow(Midpoint, 2.2);
				    return  (In - midpoint) * Contrast + midpoint;
			}
			
			float3 MyCustomExpression1_g21( float Midpoint , float Contrast , float3 In )
			{
				float midpoint = pow(Midpoint, 2.2);
				    return  (In - midpoint) * Contrast + midpoint;
			}
			
			float3 temperature_Deckard1_g22( float3 In , float Temperature , float Tint )
			{
				 float t1 = Temperature * 10 / 6;
				    float t2 = Tint * 10 / 6;
				    // Get the CIE xy chromaticity of the reference white point.
				    // Note: 0.31271 = x value on the D65 white point
				    float x = 0.31271 - t1 * (t1 < 0 ? 0.1 : 0.05);
				    float standardIlluminantY = 2.87 * x - 3 * x * x - 0.27509507;
				    float y = standardIlluminantY + t2 * 0.05;
				    // Calculate the coefficients in the LMS space.
				    float3 w1 = float3(0.949237, 1.03542, 1.08728); // D65 white point
				    // CIExyToLMS
				    float Y = 1;
				    float X = Y * x / y;
				    float Z = Y * (1 - x - y) / y;
				    float L = (0.7328 * X + 0.4296 * Y - 0.1624 * Z);
				    float M = -0.7036 * X + 1.6975 * Y + 0.0061 * Z;
				    float S = 0.0030 * X + 0.0136 * Y + 0.9834 * Z;
				    float3 w2 = float3(L, M, S);
				    float3 balance = float3(w1.x / w2.x, w1.y / w2.y, w1.z / w2.z);
				    float3x3 LIN_2_LMS_MAT = {
				        3.90405e-1, 5.49941e-1, 8.92632e-3,
				        7.08416e-2, 9.63172e-1, 1.35775e-3,
				        2.31082e-2, 1.28021e-1, 9.36245e-1
				    };
				    float3x3 LMS_2_LIN_MAT = {
				        2.85847e+0, -1.62879e+0, -2.48910e-2,
				        -2.10182e-1,  1.15820e+0,  3.24281e-4,
				        -4.18120e-2, -1.18169e-1,  1.06867e+0
				    };
				    float3 lms = mul(LIN_2_LMS_MAT, In);
				    lms *= balance;
				    return mul(LMS_2_LIN_MAT, lms);
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
				float2 uv_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
				float2 uv_AperturePass = i.ase_texcoord.xy * _AperturePass_ST.xy + _AperturePass_ST.zw;
				float4 tex2DNode11 = tex2D( _AperturePass, uv_AperturePass );
				float4 lerpResult160 = lerp( tex2DNode2 , tex2DNode11 , _finalStep);
				float2 uv0_AperturePass = i.ase_texcoord.xy * _AperturePass_ST.xy + _AperturePass_ST.zw;
				float3 temp_cast_0 = (step( frac( ( ( uv0_AperturePass.x + ( uv0_AperturePass.y * 0.2 ) ) * 200.0 ) ) , 0.6 )).xxx;
				float Midpoint1_g20 = _CMidPointVec.x;
				float Contrast1_g20 = _ContrVec.x;
				float3 hsvTorgb189 = RGBToHSV( tex2DNode11.rgb );
				float2 appendResult16 = (float2(( _AperturePass_TexelSize.x * _SharpenRadius ) , 0.0));
				float2 appendResult23 = (float2(0.0 , ( _AperturePass_TexelSize.y * _SharpenRadius )));
				float3 hsvTorgb190 = RGBToHSV( ( ( ( tex2DNode11 - tex2D( _AperturePass, ( uv0_AperturePass + appendResult16 ) ) ) + ( tex2DNode11 - tex2D( _AperturePass, ( uv0_AperturePass - appendResult23 ) ) ) + ( tex2DNode11 - tex2D( _AperturePass, ( uv0_AperturePass + appendResult23 ) ) ) + ( tex2DNode11 - tex2D( _AperturePass, ( uv0_AperturePass - appendResult16 ) ) ) ) * _Sharpen ).rgb );
				float3 hsvTorgb188 = HSVToRGB( float3(hsvTorgb189.x,hsvTorgb189.y,( hsvTorgb189.z + hsvTorgb190.z )) );
				float4 lerpResult12 = lerp( tex2DNode2 , float4( hsvTorgb188 , 0.0 ) , _finalStep);
				float3 hsvTorgb37 = RGBToHSV( lerpResult12.rgb );
				float PreFinalPassValue181 = _PreFinalPAss;
				float lerpResult182 = lerp( hsvTorgb37.y , ( hsvTorgb37.y * _saturation ) , PreFinalPassValue181);
				float temp_output_39_0 = ( hsvTorgb37.z * _exposure );
				float3 hsvTorgb40 = HSVToRGB( float3(hsvTorgb37.x,lerpResult182,temp_output_39_0) );
				float3 temp_output_46_0 = ( hsvTorgb40 * float3( 1,1,1 ) );
				float3 break83 = ( saturate( ( ddx( temp_output_46_0 ) + ddy( temp_output_46_0 ) ) ) * 1.0 );
				float ifLocalVar90 = 0;
				if( ( break83.x + break83.y + break83.z ) > 0.4 )
				ifLocalVar90 = 1.0;
				else if( ( break83.x + break83.y + break83.z ) == 0.4 )
				ifLocalVar90 = 0.0;
				else if( ( break83.x + break83.y + break83.z ) < 0.4 )
				ifLocalVar90 = 0.0;
				float3 lerpResult88 = lerp( temp_output_46_0 , float3( 0,1,0 ) , ifLocalVar90);
				float3 lerpResult94 = lerp( temp_output_46_0 , lerpResult88 , _DeckardDepthTestEdges);
				float3 hsvTorgb107 = RGBToHSV( lerpResult94 );
				float Midpoint1_g2 = _CMidpoint;
				float Contrast1_g2 = _CContrast;
				float3 temp_cast_5 = (hsvTorgb107.z).xxx;
				float3 In1_g2 = temp_cast_5;
				float3 localMyCustomExpression1_g2 = MyCustomExpression1_g2( Midpoint1_g2 , Contrast1_g2 , In1_g2 );
				float3 hsvTorgb120 = HSVToRGB( float3(( hsvTorgb107.x + _ColorOffset ),hsvTorgb107.y,localMyCustomExpression1_g2.x) );
				float2 uv0100 = i.ase_texcoord.xy * float2( 1222.1,724.2 ) + float2( 0.06,0 );
				float temp_output_103_0 = ( frac( _Time.y ) * 2000.0 );
				float2 appendResult186 = (float2(_AperturePass_TexelSize.x , _AperturePass_TexelSize.y));
				float2 temp_output_187_0 = ( _noiseScale * appendResult186 );
				float simplePerlin3D119 = snoise( float3( ( ( uv0100 + temp_output_103_0 ) * temp_output_187_0 ) ,  0.0 ) );
				float temp_output_135_0 = ( hsvTorgb120.x - saturate( ( ( simplePerlin3D119 + 0.5 ) * 0.03 * ( 1.0 - hsvTorgb120.x ) ) ) );
				float3 temp_cast_8 = (temp_output_135_0).xxx;
				float3 In1_g20 = temp_cast_8;
				float3 localMyCustomExpression1_g20 = MyCustomExpression1_g20( Midpoint1_g20 , Contrast1_g20 , In1_g20 );
				float Midpoint1_g19 = _CMidPointVec.y;
				float Contrast1_g19 = _ContrVec.y;
				float2 uv099 = i.ase_texcoord.xy * float2( 1048.7,517.25 ) + float2( 1.52,1.47 );
				float simplePerlin3D117 = snoise( float3( ( ( uv099 + temp_output_103_0 ) * temp_output_187_0 ) ,  0.0 ) );
				float3 temp_cast_11 = (( hsvTorgb120.y - saturate( ( ( simplePerlin3D117 + 0.5 ) * 0.02 * ( 1.0 - hsvTorgb120.y ) ) ) )).xxx;
				float3 In1_g19 = temp_cast_11;
				float3 localMyCustomExpression1_g19 = MyCustomExpression1_g19( Midpoint1_g19 , Contrast1_g19 , In1_g19 );
				float Midpoint1_g21 = _CMidPointVec.z;
				float Contrast1_g21 = _ContrVec.z;
				float2 uv0101 = i.ase_texcoord.xy * float2( 980.5,503.22 ) + float2( 1.11,1.89 );
				float simplePerlin3D118 = snoise( float3( ( ( uv0101 + temp_output_103_0 ) * temp_output_187_0 ) ,  0.0 ) );
				float3 temp_cast_14 = (( hsvTorgb120.z - saturate( ( ( simplePerlin3D118 + 0.5 ) * 0.05 * ( 1.0 - hsvTorgb120.z ) ) ) )).xxx;
				float3 In1_g21 = temp_cast_14;
				float3 localMyCustomExpression1_g21 = MyCustomExpression1_g21( Midpoint1_g21 , Contrast1_g21 , In1_g21 );
				float3 appendResult141 = (float3(localMyCustomExpression1_g20.x , localMyCustomExpression1_g19.x , localMyCustomExpression1_g21.x));
				float3 lerpResult143 = lerp( appendResult141 , hsvTorgb120 , ( _NoiseD_A_Amount + 1.0 ));
				float3 hsvTorgb144 = RGBToHSV( lerpResult143 );
				float3 hsvTorgb147 = HSVToRGB( float3(( hsvTorgb144.x - _ColorOffset ),hsvTorgb144.y,hsvTorgb144.z) );
				float3 In1_g22 = hsvTorgb147;
				float Temperature1_g22 = _Temp;
				float Tint1_g22 = _CTint;
				float3 localtemperature_Deckard1_g22 = temperature_Deckard1_g22( In1_g22 , Temperature1_g22 , Tint1_g22 );
				float ifLocalVar162 = 0;
				if( temp_output_39_0 > 0.8 )
				ifLocalVar162 = 0.0;
				else if( temp_output_39_0 < 0.8 )
				ifLocalVar162 = 1.0;
				float lerpResult176 = lerp( ifLocalVar162 , 1.0 , _zebras);
				float3 lerpResult166 = lerp( temp_cast_0 , localtemperature_Deckard1_g22 , lerpResult176);
				float4 lerpResult158 = lerp( lerpResult160 , float4( lerpResult166 , 0.0 ) , _PreFinalPAss);
				float4 appendResult53 = (float4(( (lerpResult158).rgb * step( abs( (-1.0 + (uv0_AperturePass.y - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , _letterboxing ) ) , 1.0));
				
				
				finalColor = appendResult53;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17701
182;199;1710;739;1099.051;383.772;1.933063;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;10;-1305.264,98.48739;Float;True;Global;_AperturePass;_AperturePass;7;0;Create;True;0;0;True;0;None;;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RelayNode;174;-746.8013,406.3787;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1264.472,896.9352;Float;False;Property;_SharpenRadius;SharpenRadius;10;0;Create;True;0;0;False;0;1;0.245;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexelSizeNode;14;-1202.952,571.3967;Inherit;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-756.5084,798.801;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-772.3964,671.695;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-926.6436,1038.606;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;16;-556.0757,628.7969;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-561.9635,840.1105;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-334.7619,1196.006;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-283.5644,735.248;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-320.4631,1013.292;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-271.265,525.5231;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;28;-121.8597,1192.829;Inherit;True;Property;_TextureSample5;Texture Sample 5;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;18;-109.2053,454.0264;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-90.13933,689.1722;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;25;-115.5049,930.6734;Inherit;True;Property;_TextureSample4;Texture Sample 4;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-206.845,188.5282;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;268.6363,1081.656;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;289.9482,417.0657;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;280.412,594.0154;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;27;268.9909,860.8743;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;33;233.3118,295.8023;Float;False;Property;_Sharpen;Sharpen;9;0;Create;True;0;0;False;0;0;0.436;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;480.3045,541.4126;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;570.5133,307.8545;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RGBToHSVNode;190;735.4255,379.7879;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RGBToHSVNode;189;312.6436,27.30033;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;1;-631,-217.5;Float;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;585.4227,99.7745;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;298.3966,-117.1774;Float;False;Global;_finalStep;_finalStep;1;0;Create;True;0;0;True;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;188;774.5563,180.7139;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;2;-351,-200.5;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;12;869.5805,3.940098;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;159;5269.412,17.94507;Float;False;Property;_PreFinalPAss;PreFinalPAss;21;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;37;1128.372,163.6165;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;180;1252.773,306.4803;Float;False;Property;_saturation;saturation;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;5461.855,129.8687;Inherit;False;PreFinalPassValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;1166.21,20.08145;Inherit;False;181;PreFinalPassValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;1412.767,195.3661;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;1095.944,353.0688;Float;False;Property;_exposure;exposure;5;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;182;1511.21,43.08145;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;1441.005,363.4773;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;40;1722.273,171.7955;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;2465.88,-13.61557;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DdyOpNode;80;2804.834,156.2867;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DdxOpNode;78;2836.314,60.37604;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;2972.944,126.6174;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;86;3107.214,291.9802;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;87;3109.473,172.5506;Float;False;Constant;_Float4;Float 4;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;3258.968,153.8531;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;50;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;83;3322.462,191.3094;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;93;3303.697,377.3676;Float;False;Constant;_Float7;Float 7;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;3561.152,361.8638;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;3287.17,316.7702;Float;False;Constant;_Float6;Float 6;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;3281.987,275.4537;Float;False;Constant;_Float5;Float 5;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;90;3614.778,195.8235;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0.4;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;96;3059.301,-2841.816;Inherit;False;4673.171;1957.566;Comment;59;151;150;149;148;147;146;145;144;143;142;141;140;139;138;137;136;135;134;133;132;131;130;129;128;127;126;125;124;123;122;121;120;119;118;117;116;115;114;113;112;111;110;109;108;107;106;105;104;103;102;101;100;99;98;97;177;178;185;187;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;88;3486.464,25.47193;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;97;3418.108,-1601.044;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;3354.229,-243.5342;Float;False;Property;_DeckardDepthTestEdges;_DeckardDepthTestEdges;20;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;98;3642.588,-1684.034;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;94;3757.038,-195.8986;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;186;-917.1144,563.0802;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RelayNode;102;3132.531,-1741.882;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;110;3625.401,-1903.532;Float;False;Property;_noiseScale;noiseScale;18;0;Create;True;0;0;False;0;1;0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;185;3768.112,-1773.397;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;99;3831.203,-2066.41;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1048.7,517.25;False;1;FLOAT2;1.52,1.47;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;101;3882.111,-2491.255;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;980.5,503.22;False;1;FLOAT2;1.11,1.89;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;3996.588,-1774.034;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2000;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;100;3850.771,-2293.548;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1222.1,724.2;False;1;FLOAT2;0.06,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;3852.711,-1914.122;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;4149.408,-2438.844;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;104;4869.029,-1560.931;Float;False;Property;_CMidpoint;CMidpoint;17;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;5226.646,-1574.093;Float;False;Property;_ColorOffset;ColorOffset;13;0;Create;True;0;0;False;0;0.4;0.82;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;4747.729,-1453.129;Float;False;Property;_CContrast;CContrast;15;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;107;4381.394,-1700.567;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;106;4093.308,-1937.543;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;4153.007,-2265.044;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;4320.408,-2272.444;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;4194.108,-2055.044;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;116;5119.424,-1465.16;Inherit;False;ContrastMidpoint;-1;;2;82fa6eec51a71ba41a3d531aa7afcea5;0;3;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;4289.408,-2519.944;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;5365.211,-1912.826;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;120;5543.39,-1742.986;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NoiseGeneratorNode;119;4525.387,-2279.622;Inherit;False;Simplex3D;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;118;4453.103,-2524.432;Inherit;False;Simplex3D;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;117;4515.981,-2066.355;Inherit;False;Simplex3D;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;122;5316.773,-2391.985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;5166.428,-2270.822;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;5066.021,-2041.555;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;124;5552.465,-2155.313;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;123;5601.966,-1968.013;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;125;4851.144,-2500.632;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;5363.095,-2271.801;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.03;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;5041.91,-2490.711;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;5284.789,-2038.634;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.02;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;132;5255.453,-2493.648;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;130;5570.738,-2263.838;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;131;5470.332,-2034.571;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;136;5614.966,-1474.138;Float;False;Property;_ContrVec;ContrVec;24;0;Create;True;0;0;False;0;0,0,0;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;137;5739.554,-2555.563;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;135;5843.059,-2319.767;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;133;5812.032,-2158.885;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;134;5701.693,-1269.296;Float;False;Property;_CMidPointVec;CMidPointVec;25;0;Create;True;0;0;False;0;0,0,0;0.5,0.5,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;140;6008.361,-1812.162;Inherit;False;ContrastMidpoint;-1;;21;82fa6eec51a71ba41a3d531aa7afcea5;0;3;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;142;6039.217,-1547.057;Float;False;Property;_NoiseD_A_Amount;NoiseD_A_Amount;23;0;Create;True;0;0;False;0;0;-0.262;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;138;6128.147,-2285.84;Inherit;False;ContrastMidpoint;-1;;20;82fa6eec51a71ba41a3d531aa7afcea5;0;3;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;139;6041.824,-1994.524;Inherit;False;ContrastMidpoint;-1;;19;82fa6eec51a71ba41a3d531aa7afcea5;0;3;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;178;6322.79,-1625.303;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;141;6291.164,-1782.121;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;143;6509.52,-1976.757;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;3220.562,-323.0385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;144;6503.067,-1641.514;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;169;3304.962,-434.5052;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;145;6659.979,-1876.02;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;3638.845,669.8471;Float;False;Constant;_Float9;Float 9;21;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;3597.126,551.5016;Float;False;Constant;_1;1;21;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;147;6873.848,-1734.103;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;148;6197.91,-1427.261;Float;False;Property;_Temp;Temp;8;0;Create;True;0;0;False;0;0;-0.405;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;6366.69,-1326.606;Float;False;Property;_CTint;CTint;11;0;Create;True;0;0;False;0;0;0.037;-0.2;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;3523.964,-452.9807;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;200;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;167;3723.227,-447.5341;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;162;3849.144,467.1;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0.8;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;149;7172.088,-1702.565;Inherit;False;ColorTemperature;1;;22;fccce2e41bca18a41863dccc23edb3ef;0;3;2;FLOAT3;0,0,0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;175;5201.787,762.802;Float;False;Property;_zebras;zebras;19;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;170;4452.755,-150.1605;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;176;5540.879,722.1993;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;150;7527.614,-1705.406;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;166;5728.675,486.41;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;48;1687.666,-82.77901;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;160;565.4205,-307.8559;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;41;2000.923,-509.0124;Float;False;Property;_letterboxing;letterboxing;12;0;Create;True;0;0;False;0;0.54;0.897;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;158;5495.358,-71.21899;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;45;2002.641,-132.9744;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;173;5756.111,-71.84702;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;51;2380.402,-231.3631;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;172;6109.308,106.1319;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;74;6158.667,235.4491;Float;False;Constant;_Float2;Float 2;18;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexelSizeNode;184;3354.543,-2163.871;Inherit;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;67;2479.658,561.4703;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;64;2249.958,355.5703;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;50;2764.409,-569.5506;Inherit;False;Midtones Control;-1;;23;1862d12003a80d24ab048da83dc4e4d5;0;4;25;SAMPLER2D;0.0;False;26;FLOAT;0;False;27;FLOAT;0;False;28;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;2094.018,-271.5621;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;6309.066,116.4181;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;3011.891,449.9007;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;50;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;165;4154.278,-163.4268;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;65;2439.959,1419.57;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;153;5344.308,-185.5074;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LinearToGammaNode;156;5272.532,-490.7907;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;151;6065.314,-2428.82;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;60;1883.543,423.8224;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;73;2454.561,170.7326;Float;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;66;2335.459,304.2703;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;47;2462.573,930.3087;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;76;5114.994,-704.8466;Inherit;True;Property;_TextureSample7;Texture Sample 7;7;0;Create;True;0;0;False;0;-1;81fc6d79243b09b459232b9cec81fa5e;81fc6d79243b09b459232b9cec81fa5e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;161;3986.477,124.3893;Float;False;Constant;_Float8;Float 8;21;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GammaToLinearNode;72;3452.302,808.6072;Inherit;False;1;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;75;5401.001,-524.8586;Float;True;Global;_AlphaPass;_AlphaPass;22;0;Create;True;0;0;False;0;None;None;False;white;LockedToTexture2D;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;68;2409.9,428.0413;Float;False;Property;_tex; tex;16;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;69;2282.436,474.0023;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;2728.185,471.1735;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;63;2086.519,640.5003;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LinearToGammaNode;70;2627.625,876.9274;Inherit;False;1;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;77;4026.568,646.5963;Inherit;True;Property;_TextureSample8;Texture Sample 8;6;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;177;6361.189,-1518.103;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;57;3052.022,799.8684;Inherit;True;Property;_TextureSample6;Texture Sample 6;7;0;Create;True;0;0;False;0;-1;81fc6d79243b09b459232b9cec81fa5e;81fc6d79243b09b459232b9cec81fa5e;True;0;False;white;Auto;False;Object;-1;Auto;Texture3D;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;56;2708.623,988.1576;Float;True;Property;_Texture0;Texture 0;14;0;Create;True;0;0;False;0;None;d54551e395b1e844a811d6e2ed0acf30;False;white;LockedToTexture3D;Texture3D;-1;0;1;SAMPLER3D;0
Node;AmplifyShaderEditor.GammaToLinearNode;155;5478.718,-506.0597;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;55;6518.924,109.5898;Float;False;True;-1;2;ASEMaterialInspector;0;1;Deckard/FinalPass;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;0;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;174;0;10;0
WireConnection;14;0;174;0
WireConnection;35;0;14;2
WireConnection;35;1;36;0
WireConnection;34;0;14;1
WireConnection;34;1;36;0
WireConnection;13;2;174;0
WireConnection;16;0;34;0
WireConnection;23;1;35;0
WireConnection;29;0;13;0
WireConnection;29;1;16;0
WireConnection;20;0;13;0
WireConnection;20;1;23;0
WireConnection;24;0;13;0
WireConnection;24;1;23;0
WireConnection;17;0;13;0
WireConnection;17;1;16;0
WireConnection;28;0;174;0
WireConnection;28;1;29;0
WireConnection;18;0;174;0
WireConnection;18;1;17;0
WireConnection;19;0;174;0
WireConnection;19;1;20;0
WireConnection;25;0;174;0
WireConnection;25;1;24;0
WireConnection;11;0;10;0
WireConnection;30;0;11;0
WireConnection;30;1;28;0
WireConnection;21;0;11;0
WireConnection;21;1;18;0
WireConnection;26;0;11;0
WireConnection;26;1;19;0
WireConnection;27;0;11;0
WireConnection;27;1;25;0
WireConnection;22;0;21;0
WireConnection;22;1;26;0
WireConnection;22;2;27;0
WireConnection;22;3;30;0
WireConnection;31;0;22;0
WireConnection;31;1;33;0
WireConnection;190;0;31;0
WireConnection;189;0;11;0
WireConnection;32;0;189;3
WireConnection;32;1;190;3
WireConnection;188;0;189;1
WireConnection;188;1;189;2
WireConnection;188;2;32;0
WireConnection;2;0;1;0
WireConnection;12;0;2;0
WireConnection;12;1;188;0
WireConnection;12;2;4;0
WireConnection;37;0;12;0
WireConnection;181;0;159;0
WireConnection;179;0;37;2
WireConnection;179;1;180;0
WireConnection;182;0;37;2
WireConnection;182;1;179;0
WireConnection;182;2;183;0
WireConnection;39;0;37;3
WireConnection;39;1;38;0
WireConnection;40;0;37;1
WireConnection;40;1;182;0
WireConnection;40;2;39;0
WireConnection;46;0;40;0
WireConnection;80;0;46;0
WireConnection;78;0;46;0
WireConnection;81;0;78;0
WireConnection;81;1;80;0
WireConnection;86;0;81;0
WireConnection;79;0;86;0
WireConnection;79;1;87;0
WireConnection;83;0;79;0
WireConnection;82;0;83;0
WireConnection;82;1;83;1
WireConnection;82;2;83;2
WireConnection;90;0;82;0
WireConnection;90;2;91;0
WireConnection;90;3;92;0
WireConnection;90;4;93;0
WireConnection;88;0;46;0
WireConnection;88;2;90;0
WireConnection;98;0;97;0
WireConnection;94;0;46;0
WireConnection;94;1;88;0
WireConnection;94;2;95;0
WireConnection;186;0;14;1
WireConnection;186;1;14;2
WireConnection;102;0;94;0
WireConnection;185;0;186;0
WireConnection;103;0;98;0
WireConnection;187;0;110;0
WireConnection;187;1;185;0
WireConnection;108;0;101;0
WireConnection;108;1;103;0
WireConnection;107;0;102;0
WireConnection;106;0;99;0
WireConnection;106;1;103;0
WireConnection;109;0;100;0
WireConnection;109;1;103;0
WireConnection;113;0;109;0
WireConnection;113;1;187;0
WireConnection;112;0;106;0
WireConnection;112;1;187;0
WireConnection;116;2;104;0
WireConnection;116;3;105;0
WireConnection;116;4;107;3
WireConnection;114;0;108;0
WireConnection;114;1;187;0
WireConnection;115;0;107;1
WireConnection;115;1;111;0
WireConnection;120;0;115;0
WireConnection;120;1;107;2
WireConnection;120;2;116;0
WireConnection;119;0;113;0
WireConnection;118;0;114;0
WireConnection;117;0;112;0
WireConnection;122;0;120;3
WireConnection;126;0;119;0
WireConnection;121;0;117;0
WireConnection;124;0;120;1
WireConnection;123;0;120;2
WireConnection;125;0;118;0
WireConnection;129;0;126;0
WireConnection;129;2;124;0
WireConnection;127;0;125;0
WireConnection;127;2;122;0
WireConnection;128;0;121;0
WireConnection;128;2;123;0
WireConnection;132;0;127;0
WireConnection;130;0;129;0
WireConnection;131;0;128;0
WireConnection;137;0;120;3
WireConnection;137;1;132;0
WireConnection;135;0;120;1
WireConnection;135;1;130;0
WireConnection;133;0;120;2
WireConnection;133;1;131;0
WireConnection;140;2;134;3
WireConnection;140;3;136;3
WireConnection;140;4;137;0
WireConnection;138;2;134;1
WireConnection;138;3;136;1
WireConnection;138;4;135;0
WireConnection;139;2;134;2
WireConnection;139;3;136;2
WireConnection;139;4;133;0
WireConnection;178;0;142;0
WireConnection;141;0;138;0
WireConnection;141;1;139;0
WireConnection;141;2;140;0
WireConnection;143;0;141;0
WireConnection;143;1;120;0
WireConnection;143;2;178;0
WireConnection;171;0;13;2
WireConnection;144;0;143;0
WireConnection;169;0;13;1
WireConnection;169;1;171;0
WireConnection;145;0;144;1
WireConnection;145;1;111;0
WireConnection;147;0;145;0
WireConnection;147;1;144;2
WireConnection;147;2;144;3
WireConnection;168;0;169;0
WireConnection;167;0;168;0
WireConnection;162;0;39;0
WireConnection;162;2;163;0
WireConnection;162;4;164;0
WireConnection;149;2;147;0
WireConnection;149;5;148;0
WireConnection;149;6;146;0
WireConnection;170;0;167;0
WireConnection;176;0;162;0
WireConnection;176;2;175;0
WireConnection;150;0;149;0
WireConnection;166;0;170;0
WireConnection;166;1;150;0
WireConnection;166;2;176;0
WireConnection;48;0;13;2
WireConnection;160;0;2;0
WireConnection;160;1;11;0
WireConnection;160;2;4;0
WireConnection;158;0;160;0
WireConnection;158;1;166;0
WireConnection;158;2;159;0
WireConnection;45;0;48;0
WireConnection;173;0;158;0
WireConnection;51;0;45;0
WireConnection;51;1;41;0
WireConnection;172;0;173;0
WireConnection;172;1;51;0
WireConnection;64;0;60;0
WireConnection;53;0;172;0
WireConnection;53;3;74;0
WireConnection;153;0;156;0
WireConnection;151;1;135;0
WireConnection;60;0;46;0
WireConnection;66;0;60;1
WireConnection;76;0;75;0
WireConnection;72;0;57;0
WireConnection;69;0;60;2
WireConnection;69;1;60;1
WireConnection;69;2;60;0
WireConnection;61;0;67;0
WireConnection;61;2;68;0
WireConnection;63;0;60;2
WireConnection;70;0;46;0
WireConnection;177;0;142;0
WireConnection;57;0;56;0
WireConnection;57;1;70;0
WireConnection;55;0;53;0
ASEEND*/
//CHKSM=15E1864DF7330A55BC8804874FD5D1DF8ABE6332