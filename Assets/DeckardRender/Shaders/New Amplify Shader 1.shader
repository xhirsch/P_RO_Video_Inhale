// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LAB"
{
	Properties
	{
		_Color0("Color 0", Color) = (0.1230019,1,0,0)
		_Float0("Float 0", Range( 0 , 1)) = 0
		_Float3("Float 3", Range( 0 , 1)) = 0
		_Float5("Float 5", Float) = 0.25
		_Height("Height", Float) = 0
		_Float4("Float 4", Float) = 0
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float _Float4;
		uniform float _Height;
		uniform sampler2D _TextureSample1;
		uniform sampler2D _TextureSample2;
		uniform float4 _TextureSample2_ST;
		uniform float4 _Color0;
		uniform float _Float3;
		uniform float _Float0;
		uniform float _Float5;


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


		float3 BumpToNormal117( float In , float3 Position , float3x3 TangentMatrix )
		{
			float3 worldDirivativeX = ddx(Position * 100);
			    float3 worldDirivativeY = ddy(Position * 100);
			    float3 crossX = cross(TangentMatrix[2].xyz, worldDirivativeX);
			    float3 crossY = cross(TangentMatrix[2].xyz, worldDirivativeY);
			    float3 d = abs(dot(crossY, worldDirivativeX));
			    float3 inToNormal = ((((In + ddx(In)) - In) * crossY) + (((In + ddy(In)) - In) * crossX)) * sign(d);
			    inToNormal.y *= -1.0;
			    return normalize((d * TangentMatrix[2].xyz) - inToNormal);
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord186 = i.uv_texcoord * float2( 62.71,83.8 );
			float mulTime187 = _Time.y * -0.3;
			float mulTime180 = _Time.y * 1.98;
			float3 appendResult191 = (float3(( uv_TexCoord186 + mulTime187 ) , mulTime180));
			float simplePerlin3D192 = snoise( appendResult191 );
			float2 uv_TexCoord188 = i.uv_texcoord * float2( 200,200 );
			float mulTime179 = _Time.y * 1.66;
			float3 appendResult181 = (float3(( uv_TexCoord188 + mulTime179 ) , mulTime180));
			float simplePerlin3D182 = snoise( appendResult181 );
			float temp_output_178_0 = pow( ( ( simplePerlin3D192 + 1.0 ) * ( simplePerlin3D182 + 1.0 ) ) , _Float4 );
			float2 Offset176 = ( ( temp_output_178_0 - 1 ) * ( i.viewDir.xy / i.viewDir.z ) * _Height ) + uv_TexCoord186;
			float mulTime148 = _Time.y * -0.3;
			float mulTime172 = _Time.y * 1.98;
			float3 appendResult153 = (float3(( Offset176 + mulTime148 ) , mulTime172));
			float simplePerlin3D126 = snoise( appendResult153 );
			float mulTime138 = _Time.y * 1.66;
			float3 appendResult154 = (float3(( Offset176 + mulTime138 ) , mulTime172));
			float simplePerlin3D135 = snoise( appendResult154 );
			float temp_output_149_0 = pow( ( ( simplePerlin3D126 + 1.0 ) * ( simplePerlin3D135 + 1.0 ) ) , _Float4 );
			float temp_output_213_0 = distance( i.uv_texcoord , float2( 0.5,0.5 ) );
			float mulTime222 = _Time.y * -0.01;
			float temp_output_217_0 = ( ( temp_output_213_0 + mulTime222 ) * 50.0 );
			float In117 = ( temp_output_149_0 + sin( ( temp_output_217_0 * radians( 360.0 ) ) ) );
			float3 ase_worldPos = i.worldPos;
			float3 temp_output_130_0 = ase_worldPos;
			float3 Position117 = temp_output_130_0;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3x3 TangentMatrix117 = ase_worldToTangent;
			float3 localBumpToNormal117 = BumpToNormal117( In117 , Position117 , TangentMatrix117 );
			float3 objectToTangentDir = normalize( mul( ase_worldToTangent, mul( unity_ObjectToWorld, float4( localBumpToNormal117, 0 ) ).xyz) );
			o.Normal = ( objectToTangentDir * float3( 0.2,0.2,1 ) );
			float2 uv_TextureSample2 = i.uv_texcoord * _TextureSample2_ST.xy + _TextureSample2_ST.zw;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_tanViewDir = mul( ase_worldToTangent, ase_worldViewDir );
			float2 Offset203 = ( ( tex2D( _TextureSample2, uv_TextureSample2 ).a - 1 ) * ( ase_tanViewDir.xy / ase_tanViewDir.z ) * 1.0 ) + Offset176;
			o.Albedo = tex2D( _TextureSample1, Offset203 ).rgb;
			o.Emission = ( _Color0 * temp_output_178_0 ).rgb;
			o.Metallic = _Float3;
			float temp_output_166_0 = ( abs( ddy( temp_output_149_0 ) ) + abs( ddy( temp_output_149_0 ) ) );
			float temp_output_169_0 = ( temp_output_166_0 * _Float5 );
			o.Smoothness = ( _Float0 - temp_output_169_0 );
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16800
1527;427;1751;1225;3833.682;885.0406;1.5617;True;True
Node;AmplifyShaderEditor.SimpleTimeNode;187;-5552.119,626.3582;Float;False;1;0;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;186;-5401.357,236.4747;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;62.71,83.8;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;188;-5940.179,717.2376;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;200,200;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;179;-5623.133,843.5342;Float;False;1;0;FLOAT;1.66;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;190;-5317.971,748.1313;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;189;-5303.417,549.0446;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;180;-5514.84,1046.18;Float;False;1;0;FLOAT;1.98;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;191;-5097.286,619.1462;Float;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;181;-5168.073,903.6157;Float;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;182;-4996.574,905.4412;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;192;-4960.07,619.1669;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;183;-4683.013,615.5161;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;184;-4738.504,869.0296;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;194;-4541.646,762.0992;Float;False;Property;_Float4;Float 4;17;0;Create;True;0;0;False;0;0;0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-4579.464,899.587;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;178;-4343.275,793.6596;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.64;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;193;-4478,1101.825;Float;False;Property;_Height;Height;16;0;Create;True;0;0;False;0;0;-0.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;177;-4559.532,1238.489;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxMappingNode;176;-4184.193,1020.075;Float;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;4;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;138;-4244.474,363.3615;Float;False;1;0;FLOAT;1.66;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;148;-4226.305,109.7424;Float;False;1;0;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;-3957.558,65.22753;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;139;-3930.47,384.4915;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;172;-4139.826,575.118;Float;False;1;0;FLOAT;1.98;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;155;-4563.564,246.1757;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;154;-3793.059,432.5537;Float;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;153;-3722.272,148.0843;Float;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceOpNode;213;-2943.038,-202.7086;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;222;-2842.879,-354.0626;Float;False;1;0;FLOAT;-0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;135;-3621.56,434.3792;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;126;-3585.056,148.1051;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-3307.999,144.4542;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;150;-3363.49,397.9676;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;223;-2647.228,-274.4158;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-3103.033,228.7103;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;221;-2952.37,34.01175;Float;False;1;0;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;217;-2436.957,-273.1688;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-2738.276,17.25647;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;149;-2873.167,228.7863;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.64;False;1;FLOAT;0
Node;AmplifyShaderEditor.DdyOpNode;157;-2079.147,167.0302;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DdyOpNode;164;-2062.33,256.741;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;219;-2513.149,48.90541;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;119;-2705.776,860.2618;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;162;-1869.757,117.6733;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;165;-1867.672,241.9576;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;214;-2475.47,306.3588;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;130;-2231.375,625.116;Float;False;Object;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldToTangentMatrix;118;-2438.974,554.989;Float;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-1267.948,267.1895;Float;False;Property;_Float5;Float 5;15;0;Create;True;0;0;False;0;0.25;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;166;-1451.33,169.6411;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;210;-1671.883,-428.2712;Float;True;Property;_TextureSample2;Texture Sample 2;22;0;Create;True;0;0;False;0;None;c93579a4742816c45a467d1da98464cc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;204;-1445.417,-93.09286;Float;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;117;-2101.953,378.4985;Float;False;float3 worldDirivativeX = ddx(Position * 100)@$    float3 worldDirivativeY = ddy(Position * 100)@$    float3 crossX = cross(TangentMatrix[2].xyz, worldDirivativeX)@$    float3 crossY = cross(TangentMatrix[2].xyz, worldDirivativeY)@$    float3 d = abs(dot(crossY, worldDirivativeX))@$    float3 inToNormal = ((((In + ddx(In)) - In) * crossY) + (((In + ddy(In)) - In) * crossX)) * sign(d)@$    inToNormal.y *= -1.0@$    return normalize((d * TangentMatrix[2].xyz) - inToNormal)@;3;False;3;True;In;FLOAT;0;In;;Float;False;True;Position;FLOAT3;0,0,0;In;;Float;False;True;TangentMatrix;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;In;;Float;False;BumpToNormal;True;False;0;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;129;-1791.161,360.8382;Float;False;Object;Tangent;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxMappingNode;203;-1195.726,-361.2502;Float;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;2.3;False;2;FLOAT;1;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;173;-839.0095,855.7828;Float;False;Property;_Color0;Color 0;8;0;Create;True;0;0;False;0;0.1230019,1,0,0;0.01793344,0.2924521,0.1426004,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-1035.808,238.2526;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.71;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;114;-2998.915,-2387.581;Float;False;4673.171;1957.566;Comment;56;51;65;113;64;66;69;25;24;55;57;54;105;106;60;112;110;111;74;79;85;90;84;77;75;83;89;82;78;91;88;102;92;72;87;50;81;52;93;107;95;94;108;99;70;98;96;97;53;86;80;73;104;103;100;115;116;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-1434.845,558.8707;Float;False;Property;_Float0;Float 0;13;0;Create;True;0;0;False;0;0;0.962;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;139.6933,-973.0256;Float;False;Property;_Temperature;Temperature;4;0;Create;True;0;0;False;0;0;-0.02;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;209;-1924.105,-414.6414;Float;True;Property;_Texture1;Texture 1;18;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.HSVToRGBNode;55;841.2318,-1268.667;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-2061.628,-1319.798;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2000;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-969.6306,515.4412;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;64;-457.549,-1040.702;Float;False;Property;_NoiseContrast;NoiseContrast;12;0;Create;True;0;0;False;0;0,0,0;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-773.4277,-1584.399;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0.02;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;60;262.2271,-1499.838;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-686.2936,446.4708;Float;False;Property;_Float3;Float 3;14;0;Create;True;0;0;False;0;0;0.249;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;111;-16.39222,-1540.288;Float;False;ContrastMidpoint;-1;;25;82fa6eec51a71ba41a3d531aa7afcea5;0;3;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-695.1213,-1817.566;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0.03;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;107;-799.7922,-1019.924;Float;False;ContrastMidpoint;-1;;28;82fa6eec51a71ba41a3d531aa7afcea5;0;3;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;86;-2176.105,-2037.02;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;980.5,503.22;False;1;FLOAT2;1.11,1.89;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;77;-487.4789,-1809.603;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-1160.387,-914.6951;Float;False;Property;_midpoint;midpoint;9;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;73;-2207.445,-1839.313;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1222.1,724.2;False;1;FLOAT2;0.06,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleContrastOpNode;66;7.097744,-1974.584;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RGBToHSVNode;51;-1676.823,-1246.331;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;25;308.4737,-872.3704;Float;False;Property;_Tint;Tint;5;0;Create;True;0;0;False;0;0;0.008;-0.2;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;91;-505.7511,-1701.078;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;84;-587.885,-1580.335;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-1207.073,-2046.396;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-1908.808,-1984.609;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-1251.988,-983.2933;Float;False;Property;_Contrast;Contrast;7;0;Create;True;0;0;False;0;0;0.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;100;-2640.108,-1146.808;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1768.808,-2065.708;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-757.7712,-1116.357;Float;False;Property;_Float6;Float 6;6;0;Create;True;0;0;False;0;0.4;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;215;-2714.114,-153.6582;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;103;-2415.628,-1229.798;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;158;-1476.829,675.3409;Float;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;-689.658,157.6894;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;127;-4026.344,-234.5871;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;62.71,83.8;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-3412.438,-897.5969;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;106;123.7025,-1194.922;Float;False;Property;_NoiseAmount;NoiseAmount;11;0;Create;True;0;0;False;0;0;0.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;-215.1573,-1865.531;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-2379.108,-1345.808;Float;False;Property;_NoiseScale;NoiseScale;10;0;Create;True;0;0;False;0;1;0.47;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;116;1469.398,-1251.17;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;115;-2925.685,-1287.646;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;1;-3850.099,-923.0864;Float;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;False;0;None;777459221126dae42ae9b15d22225a30;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-1964.908,-1483.307;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-462.079,673.2838;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-1478.699,321.8143;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.2,0.2,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;85;-318.6628,-2101.327;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;92;-456.2508,-1513.777;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;69;-993.0211,-1188.954;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;168;-1197.155,57.5164;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;110;69.93082,-1831.604;Float;False;ContrastMidpoint;-1;;27;82fa6eec51a71ba41a3d531aa7afcea5;0;3;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;87;-1605.114,-2070.197;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-693.0057,-1458.59;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;112;5.588856,-1374.233;Float;False;ContrastMidpoint;-1;;21;82fa6eec51a71ba41a3d531aa7afcea5;0;3;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;113;-338.3229,-822.8606;Float;False;Property;_NoiseMidpoint;NoiseMidpoint;21;0;Create;True;0;0;False;0;0,0,0;0.5,0.5,0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;225;-2215.761,-233.8117;Float;False;ContrastMidpoint;-1;;29;82fa6eec51a71ba41a3d531aa7afcea5;0;3;2;FLOAT;0.86;False;3;FLOAT;0.3;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;216;-2444.025,-98.71571;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;80;-2227.013,-1612.175;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1048.7,517.25;False;1;FLOAT2;1.52,1.47;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-992.1949,-1587.319;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-1737.808,-1818.208;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.HSVToRGBNode;50;-483.6543,-1390.06;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;98;-1905.209,-1810.808;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;195;-1040.932,-104.7911;Float;True;Property;_TextureSample1;Texture Sample 1;19;0;Create;True;0;0;False;0;None;c26acf27d9382534d9a58bd79aaa14e3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;601.7627,-1421.784;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;81;-1542.235,-1612.12;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-891.7887,-1816.587;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;212;-517.5973,-110.1896;Float;True;Property;_TextureSample4;Texture Sample 4;20;0;Create;True;0;0;False;0;None;c26acf27d9382534d9a58bd79aaa14e3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;90;-802.7636,-2039.412;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;65;1113.872,-1248.329;Float;False;ColorTemperature;1;;26;fccce2e41bca18a41863dccc23edb3ef;0;3;2;FLOAT3;0,0,0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;72;-1532.829,-1825.386;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;170;-623.2301,568.4412;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-1864.108,-1600.808;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;105;451.3036,-1522.521;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-1016.306,-2036.475;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;54;444.8506,-1187.279;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;79;-246.1843,-1704.65;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;102;-741.4433,-1937.75;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;121;-163.2301,340.6706;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;LAB;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;190;0;188;0
WireConnection;190;1;179;0
WireConnection;189;0;186;0
WireConnection;189;1;187;0
WireConnection;191;0;189;0
WireConnection;191;2;180;0
WireConnection;181;0;190;0
WireConnection;181;2;180;0
WireConnection;182;0;181;0
WireConnection;192;0;191;0
WireConnection;183;0;192;0
WireConnection;184;0;182;0
WireConnection;185;0;183;0
WireConnection;185;1;184;0
WireConnection;178;0;185;0
WireConnection;178;1;194;0
WireConnection;176;0;186;0
WireConnection;176;1;178;0
WireConnection;176;2;193;0
WireConnection;176;3;177;0
WireConnection;147;0;176;0
WireConnection;147;1;148;0
WireConnection;139;0;176;0
WireConnection;139;1;138;0
WireConnection;154;0;139;0
WireConnection;154;2;172;0
WireConnection;153;0;147;0
WireConnection;153;2;172;0
WireConnection;213;0;155;0
WireConnection;135;0;154;0
WireConnection;126;0;153;0
WireConnection;137;0;126;0
WireConnection;150;0;135;0
WireConnection;223;0;213;0
WireConnection;223;1;222;0
WireConnection;136;0;137;0
WireConnection;136;1;150;0
WireConnection;217;0;223;0
WireConnection;220;0;217;0
WireConnection;220;1;221;0
WireConnection;149;0;136;0
WireConnection;149;1;194;0
WireConnection;157;0;149;0
WireConnection;164;0;149;0
WireConnection;219;0;220;0
WireConnection;162;0;157;0
WireConnection;165;0;164;0
WireConnection;214;0;149;0
WireConnection;214;1;219;0
WireConnection;130;0;119;0
WireConnection;166;0;162;0
WireConnection;166;1;165;0
WireConnection;117;0;214;0
WireConnection;117;1;130;0
WireConnection;117;2;118;0
WireConnection;129;0;117;0
WireConnection;203;0;176;0
WireConnection;203;1;210;4
WireConnection;203;3;204;0
WireConnection;169;0;166;0
WireConnection;169;1;171;0
WireConnection;55;0;57;0
WireConnection;55;1;54;2
WireConnection;55;2;54;3
WireConnection;104;0;103;0
WireConnection;167;0;151;0
WireConnection;167;1;169;0
WireConnection;83;0;82;0
WireConnection;83;2;92;0
WireConnection;60;0;110;0
WireConnection;60;1;111;0
WireConnection;60;2;112;0
WireConnection;111;2;113;2
WireConnection;111;3;64;2
WireConnection;111;4;79;0
WireConnection;75;0;78;0
WireConnection;75;2;91;0
WireConnection;107;2;108;0
WireConnection;107;3;70;0
WireConnection;107;4;51;3
WireConnection;77;0;75;0
WireConnection;66;1;74;0
WireConnection;51;0;115;0
WireConnection;91;0;50;1
WireConnection;84;0;83;0
WireConnection;88;0;87;0
WireConnection;97;0;86;0
WireConnection;97;1;104;0
WireConnection;93;0;97;0
WireConnection;93;1;96;0
WireConnection;215;0;213;0
WireConnection;103;0;100;0
WireConnection;207;1;166;0
WireConnection;2;0;1;0
WireConnection;74;0;50;1
WireConnection;74;1;77;0
WireConnection;116;0;65;0
WireConnection;115;0;2;0
WireConnection;99;0;80;0
WireConnection;99;1;104;0
WireConnection;206;0;173;0
WireConnection;206;1;178;0
WireConnection;128;0;129;0
WireConnection;85;0;50;3
WireConnection;85;1;90;0
WireConnection;92;0;50;2
WireConnection;69;1;51;3
WireConnection;69;0;70;0
WireConnection;168;0;166;0
WireConnection;110;2;113;1
WireConnection;110;3;64;1
WireConnection;110;4;74;0
WireConnection;87;0;93;0
WireConnection;52;0;51;1
WireConnection;52;1;53;0
WireConnection;112;2;113;3
WireConnection;112;3;64;3
WireConnection;112;4;85;0
WireConnection;225;4;216;0
WireConnection;216;0;217;0
WireConnection;82;0;81;0
WireConnection;94;0;98;0
WireConnection;94;1;96;0
WireConnection;50;0;52;0
WireConnection;50;1;51;2
WireConnection;50;2;107;0
WireConnection;98;0;73;0
WireConnection;98;1;104;0
WireConnection;195;1;203;0
WireConnection;57;0;54;1
WireConnection;57;1;53;0
WireConnection;81;0;95;0
WireConnection;78;0;72;0
WireConnection;212;1;176;0
WireConnection;90;0;89;0
WireConnection;65;2;55;0
WireConnection;65;5;24;0
WireConnection;65;6;25;0
WireConnection;72;0;94;0
WireConnection;170;0;151;0
WireConnection;170;1;169;0
WireConnection;95;0;99;0
WireConnection;95;1;96;0
WireConnection;105;0;60;0
WireConnection;105;1;50;0
WireConnection;105;2;106;0
WireConnection;89;0;88;0
WireConnection;89;2;102;0
WireConnection;54;0;105;0
WireConnection;79;0;50;2
WireConnection;79;1;84;0
WireConnection;102;0;50;3
WireConnection;121;0;195;0
WireConnection;121;1;128;0
WireConnection;121;2;206;0
WireConnection;121;3;152;0
WireConnection;121;4;170;0
ASEEND*/
//CHKSM=50626693CD9A3CDC1E83519CB88DD54A17C5D0FD