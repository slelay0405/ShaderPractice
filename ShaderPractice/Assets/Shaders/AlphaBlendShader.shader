// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/AlphaBlend" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1
	}
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

		Pass{
			Tags { "LightModel"="ForwardBase" }

			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0; 
			};

			struct v2f{
				float4 clipVertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPosition : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v i){
				v2f o;

				o.clipVertex = UnityObjectToClipPos(i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldPosition = mul(unity_ObjectToWorld,i.vertex).xyz;
				o.uv = TRANSFORM_TEX(i.texcoord,_MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPosition));

				//纹理采样
				fixed4 texColor = tex2D(_MainTex,i.uv);

				//反射率
				fixed3 albedo = texColor.rgb * _Color.rgb;

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

				//混合
				fixed4 blendColor = fixed4(ambient + diffuse, texColor.a * _AlphaScale);

				return blendColor;
			}
			ENDCG
		}



	}
	FallBack "Transparent/VertexLit"
}
