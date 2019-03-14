Shader "Custom/SingleTextureShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTexture", 2D) = "white" {}
        _Specular ("Specular",Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8,256)) = 20
    }
    SubShader
    {
		Pass{
			Tags{ "LightModel" = "ForwardBase" }

			CGPROGRAM

			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex; 
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 clipPosition : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float2 uv : TEXCOORD1;
				float3 worldPosition : TEXCOORD2;
			};

			v2f vert(a2v i){
				v2f o;
				//顶点转换到裁切空间
				o.clipPosition = UnityObjectToClipPos(i.vertex);

				//顶点转换到世界空间
				o.worldPosition = mul((float3x3)unity_ObjectToWorld,i.vertex);

				//法线转换到世界空间
				o.worldNormal = UnityObjectToWorldNormal(i.normal);

				//计算UV坐标
				o.uv = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				//漫反射
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0).xyz;
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldLightDir,worldNormal));

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//Blinn-Phone高光反射
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPosition)).xyz;
				fixed3 bPhoneDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(bPhoneDir,worldNormal)),_Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}
			ENDCG
		}



   
    }
    FallBack "Diffuse"
}
