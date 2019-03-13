// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/PreVertexLevelSpecularShader"
{
    Properties
    {
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,256)) = 20
    }
    SubShader
    {
		Pass{
			Tags { "LightModel"="ForwardBase" }

			CGPROGRAM

			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v i){
				v2f o;
				//顶点转换到裁切空间
				o.pos = UnityObjectToClipPos(i.vertex);

				//环境光计算
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//法线转换到世界空间
				fixed3 worldNormal = normalize(mul(i.normal,(float3x3)unity_WorldToObject));

				//获取光照方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//计算漫反射
				fixed3 diffuseColor = _LightColor0.rgb * _Diffuse * saturate(dot(worldNormal,worldLightDir));

				//计算光的出射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));

				//计算观察方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,i.vertex).xyz);

				//计算高光反射
				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);

				o.color = ambientColor + diffuseColor + specularColor;

				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				return fixed4(i.color,1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
