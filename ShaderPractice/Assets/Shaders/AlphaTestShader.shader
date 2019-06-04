// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/AlphaTest" {
	Properties {
		_Color ("Main_Tint", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
	}

	SubShader {
		Tags { "Queue"="AlphaTest" "IgnoreProjector"="true" "RenderType"="TransparentCutout" }

		Pass {
			Tags { "LightModel"="ForwardBase" }
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;

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

				//顶点转裁切空间
				o.clipVertex = UnityObjectToClipPos(i.vertex);

				//法线转世界空间
				o.worldNormal = UnityObjectToWorldNormal(i.normal);

				//顶点转世界空间
				o.worldPosition = mul(unity_ObjectToWorld, i.vertex).xyz;

				//解析uv顶点uv坐标
				o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				//归一化片元法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//获取片元到光源的向量
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPosition));

				//纹理采样
				fixed4 texColor = tex2D(_MainTex, i.uv);

				//透明度测试
//				if ((texColor.a - _Cutoff) < 0.0){
//					discard;
//				}
				clip(texColor.a - _Cutoff);

				//反射率
				fixed3 albedo = texColor.rgb * _Color.rgb;

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				return fixed4(ambient +diffuse, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Transparent/Cutout/VertexLit"
}
