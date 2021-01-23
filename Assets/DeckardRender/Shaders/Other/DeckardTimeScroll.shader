// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DeckardScroll"
{
	Properties
	{
		_TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 0
		_OcclusionMap("_OcclusionMap", 2D) = "white" {}
		_BumpMap("_BumpMap", 2D) = "bump" {}
		_EmissionMap("_EmissionMap", 2D) = "white" {}
		_MetallicGlossMap("_MetallicGlossMap", 2D) = "white" {}
		_MainTex("_MainTex", 2D) = "white" {}
		_moveDirection("moveDirection", Vector) = (0,0,0,0)
		_BumpScale("_BumpScale", Float) = 0
		_Color("_Color", Color) = (0,0,0,0)
		_Float0("Float 0", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction tessphong:_TessPhongStrength 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _EmissionMap;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float2 _moveDirection;
		uniform float4 _DeckardTime;
		uniform float _Float0;
		uniform sampler2D _BumpMap;
		uniform float _BumpScale;
		uniform float4 _Color;
		uniform sampler2D _MetallicGlossMap;
		uniform sampler2D _OcclusionMap;
		uniform float _TessPhongStrength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			float4 temp_cast_0 = (37.01).xxxx;
			return temp_cast_0;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 uv_MainTex = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 temp_output_4_0 = ( uv_MainTex + ( _moveDirection * ( _Time.y + _DeckardTime.y ) ) );
			float2 temp_output_43_0 = ( temp_output_4_0 + ( _DeckardTime.y * 0.3 ) );
			float4 tex2DNode32 = tex2Dlod( _EmissionMap, float4( temp_output_43_0, 0, 0.0) );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( tex2DNode32.r * _DeckardTime.y * _Float0 * ase_vertexNormal );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 temp_output_4_0 = ( uv_MainTex + ( _moveDirection * ( _Time.y + _DeckardTime.y ) ) );
			o.Normal = UnpackScaleNormal( tex2D( _BumpMap, temp_output_4_0 ), _BumpScale );
			float2 temp_output_43_0 = ( temp_output_4_0 + ( _DeckardTime.y * 0.3 ) );
			o.Albedo = ( tex2D( _MainTex, temp_output_43_0 ) * _Color ).rgb;
			float4 tex2DNode37 = tex2D( _MetallicGlossMap, temp_output_43_0 );
			o.Metallic = tex2DNode37.r;
			o.Smoothness = tex2DNode37.a;
			o.Occlusion = tex2D( _OcclusionMap, temp_output_43_0 ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16204
931;384;1365;795;814.8929;484.4861;2.353026;True;True
Node;AmplifyShaderEditor.TimeNode;21;-1595.299,364.9745;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;23;-1584.199,626.2743;Float;False;Global;_DeckardTime;_DeckardTime;2;0;Create;True;0;0;True;0;0,0,0,0;0.001041667,0.02083333,0.04166667,0.0625;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;1;-1362.4,-329.2;Float;True;Property;_MainTex;_MainTex;4;0;Create;True;0;0;False;0;None;f7e96904e8667e1439548f0f86389447;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-1226.099,337.6743;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;16;-1461.793,75.86032;Float;False;Property;_moveDirection;moveDirection;5;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1066.3,-86.99999;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-914.5929,90.26034;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;4;-690.4001,-120.4;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-873.1736,435.4561;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;26;-564.2253,223.5712;Float;True;Property;_EmissionMap;_EmissionMap;2;0;Create;True;0;0;False;0;None;f7e96904e8667e1439548f0f86389447;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-749.8859,297.9033;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-375.099,-499.5256;Float;False;Property;_BumpScale;_BumpScale;6;0;Create;True;0;0;False;0;0;-1.28;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-395.9507,-269.0055;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;84508b93f15f2b64386ec07486afc7a3;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;24;-597.2444,-655.476;Float;True;Property;_MetallicGlossMap;_MetallicGlossMap;3;0;Create;True;0;0;False;0;None;f7e96904e8667e1439548f0f86389447;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ColorNode;30;-64.90342,-209.4533;Float;False;Property;_Color;_Color;8;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;25;84.44345,499.4739;Float;True;Property;_OcclusionMap;_OcclusionMap;0;0;Create;True;0;0;False;0;None;f7e96904e8667e1439548f0f86389447;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;35;-25.94202,-84.68638;Float;True;Property;_BumpMap;_BumpMap;1;0;Create;True;0;0;False;0;None;10ff51d2d87fb7b46b70b55f8551c146;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;40;360.5136,617.0319;Float;False;Property;_Float0;Float 0;9;0;Create;True;0;0;False;0;0;6.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;41;801.6501,424.7416;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;32;-317.3315,80.55149;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;84508b93f15f2b64386ec07486afc7a3;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;17;-1504.193,212.1602;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;5;-1394.1,-600.7001;Float;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;38;685.6364,566.3293;Float;True;Property;_TextureSample4;Texture Sample 4;1;0;Create;True;0;0;False;0;84508b93f15f2b64386ec07486afc7a3;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-1207.292,503.4603;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;35.34956,176.4679;Float;False;Property;_EmissionColor;_EmissionColor;7;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;453.38,-94.50842;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;364.5298,-224.2087;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;11;-436.7254,419.2858;Float;False;True;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0.5,0.5,0.5;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;605.2295,167.1263;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TimeNode;13;-1671.7,-120.5;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;36;350.3103,-709.8682;Float;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;84508b93f15f2b64386ec07486afc7a3;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;-280.691,-711.4094;Float;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;0;84508b93f15f2b64386ec07486afc7a3;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;14;-1188.918,1026.866;Float;False;1;0;FLOAT;80.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;1064.549,863.6309;Float;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;False;0;37.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1783.007,476.2471;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;DeckardScroll;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;True;0;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;22;0;21;2
WireConnection;22;1;23;2
WireConnection;8;2;1;0
WireConnection;15;0;16;0
WireConnection;15;1;22;0
WireConnection;4;0;8;0
WireConnection;4;1;15;0
WireConnection;44;0;23;2
WireConnection;43;0;4;0
WireConnection;43;1;44;0
WireConnection;2;0;1;0
WireConnection;2;1;43;0
WireConnection;32;0;26;0
WireConnection;32;1;43;0
WireConnection;38;0;25;0
WireConnection;38;1;43;0
WireConnection;18;0;21;2
WireConnection;33;0;32;0
WireConnection;33;1;34;0
WireConnection;31;0;2;0
WireConnection;31;1;30;0
WireConnection;39;0;32;1
WireConnection;39;1;23;2
WireConnection;39;2;40;0
WireConnection;39;3;41;0
WireConnection;36;0;35;0
WireConnection;36;1;4;0
WireConnection;36;5;27;0
WireConnection;37;0;24;0
WireConnection;37;1;43;0
WireConnection;0;0;31;0
WireConnection;0;1;36;0
WireConnection;0;3;37;1
WireConnection;0;4;37;4
WireConnection;0;5;38;0
WireConnection;0;11;39;0
WireConnection;0;14;42;0
ASEEND*/
//CHKSM=3EB321FBEB99A0153E3CF5237C51FF6F54106501