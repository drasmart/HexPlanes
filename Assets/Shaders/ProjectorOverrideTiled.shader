// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'
// Upgrade NOTE: replaced '_ProjectorClip' with 'unity_ProjectorClip'

Shader "Projector/Override (Tiled)" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_ShadowTex ("Cookie", 2D) = "" {}
	}
	
	Subshader {
		Tags {"Queue"="Transparent"}
		Pass {
			ZWrite Off
			//ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			//Offset -1, -1
	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			
			struct v2f {
				float4 uvShadow : TEXCOORD0;
				UNITY_FOG_COORDS(2)
				float4 pos : SV_POSITION;
			};
			
			float4x4 unity_Projector;
			float4x4 unity_ProjectorClip;
			
			v2f vert (float4 vertex : POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(vertex);
				o.uvShadow = mul (unity_Projector, vertex);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			fixed4 _Color;
			sampler2D _ShadowTex;
			float4 _ShadowTex_ST;
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 texS = tex2D (_ShadowTex, TRANSFORM_TEX(UNITY_PROJ_COORD(i.uvShadow), _ShadowTex));
				texS.rgb *= _Color.rgb;
				texS.a *= _Color.a;
	
				//fixed4 texF = tex2D (_FalloffTex, TRANSFORM_TEX(UNITY_PROJ_COORD(i.uvFalloff), _FalloffTex));
				//fixed4 res = texS * texF.a;

				UNITY_APPLY_FOG_COLOR(i.fogCoord, res, fixed4(0,0,0,0));
				return texS;
			}
			ENDCG
		}
	}
}
