// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DeckardRender/reconstructDepth"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float4 screenPos;
		};

		uniform sampler2D _CameraDepthTexture;


		half2 UnStereo( half2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			half2 UV22_g7 = ase_screenPosNorm.xy;
			half2 localUnStereo22_g7 = UnStereo( UV22_g7 );
			half2 break64_g6 = localUnStereo22_g7;
			half4 tex2DNode36_g6 = tex2D( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float4 staticSwitch38_g6 = ( 1.0 - tex2DNode36_g6 );
			#else
				float4 staticSwitch38_g6 = tex2DNode36_g6;
			#endif
			half3 appendResult39_g6 = (half3(break64_g6.x , break64_g6.y , staticSwitch38_g6.r));
			half4 appendResult42_g6 = (half4((appendResult39_g6*2.0 + -1.0) , 1.0));
			half4 temp_output_43_0_g6 = mul( unity_CameraInvProjection, appendResult42_g6 );
			half4 appendResult49_g6 = (half4(( ( (temp_output_43_0_g6).xyz / (temp_output_43_0_g6).w ) * float3( 1,1,-1 ) ) , 1.0));
			o.Emission = mul( unity_CameraToWorld, appendResult49_g6 ).xyz;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17701
1098;803;1710;900;-383.1104;838.8535;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;8;-693.5542,-181.9297;Inherit;False;828.5967;315.5001;Screen depth difference to get intersection and fading effect with terrain and objects;4;12;11;10;9;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-447.7472,-883.7879;Inherit;False;985.6011;418.6005;Get screen color for refraction and disturbe it with normals;6;27;26;25;24;23;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CustomExpressionNode;35;1227.537,-303.8604;Float;False;float fade = 0@$float factor = 1 / Iterations@$for(float i=0@ i<Iterations@ i++)${ $if ((factor * i) >= depth)$finalColor = finalColor + 0.0001@$else{$ finalColor = depth@$break@$}$}$$$finalColor = finalColor@			return finalColor@;4;False;6;True;depth;FLOAT;0;In;;Float;False;True;uv_Texture0;FLOAT2;0,0;In;;Float;False;True;Iterations;FLOAT;128;In;;Float;False;True;OffsetX;FLOAT2;0,0;In;;Float;False;True;noise;SAMPLER2D;_Sampler435;In;;Float;False;True;finalColor;FLOAT4;0,0,0,0;Out;;Float;False;raymarch;True;False;0;6;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;128;False;3;FLOAT2;0,0;False;4;SAMPLER2D;_Sampler435;False;5;FLOAT4;0,0,0,0;False;2;FLOAT4;0;FLOAT4;6
Node;AmplifyShaderEditor.LerpOp;28;783.5513,-348.4676;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SurfaceDepthNode;1;-732.4999,140.5;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;5;-389.7,284.2;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;12;-33.29484,-9.61829;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;196.4056,-167.7649;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;29;-353.0109,47.21677;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;14;11.58606,89.49555;Float;False;Property;_WaterDepth;Water Depth;3;0;Create;True;0;0;False;0;0;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-204.8469,-585.1879;Float;False;Property;_Distortion;Distortion;5;0;Create;True;0;0;False;0;0.5;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;6;-50,230;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;26;317.8541,-732.488;Float;False;Global;_WaterGrab;WaterGrab;-1;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;3;-656.9,274.0999;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;2.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;24;-100.2925,-767.296;Inherit;False;True;True;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;27;-403.6403,-824.43;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LinearDepthNode;4;-524.4873,339.7844;Inherit;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-26.74549,-661.7879;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;126.3531,-728.6879;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;17;594.0888,-27.63335;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;16;387.7873,-48.83261;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;207.3927,-9.849602;Float;False;Property;_WaterFalloff;Water Falloff;4;0;Create;True;0;0;False;0;0;-3.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-198.9721,-96.35699;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;907.7999,-23.80682;Float;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;256;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;10;-421.5539,-80.92962;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;9;-643.5541,-78.42951;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;37;1278.125,-515.1068;Inherit;False;Reconstruct World Position From Depth;1;;6;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;19;1780.367,-310.7488;Half;False;True;-1;2;ASEMaterialInspector;0;0;Standard;DeckardRender/reconstructDepth;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;35;0;10;0
WireConnection;35;2;36;0
WireConnection;28;0;26;0
WireConnection;28;2;17;0
WireConnection;12;0;11;0
WireConnection;13;0;11;0
WireConnection;13;1;14;0
WireConnection;26;0;24;0
WireConnection;24;0;27;4
WireConnection;23;1;22;0
WireConnection;25;0;24;0
WireConnection;25;1;23;0
WireConnection;17;0;16;0
WireConnection;16;0;11;0
WireConnection;16;1;15;0
WireConnection;11;0;10;0
WireConnection;10;0;9;0
WireConnection;19;2;37;0
ASEEND*/
//CHKSM=17CE4D62FA0E119BBAEA3F92262C635BBF5E2B41