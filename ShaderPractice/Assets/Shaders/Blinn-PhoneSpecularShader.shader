Shader "Custom/Blinn-PhoneSpecularShader"
{
    Properties
    {
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Specular("Specular Color",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,256)) = 20
    }
    SubShader
    {
		Pass{
			Tags{"LightModel" = "ForwardBase"}

			CGPROGRAM
			
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 clipVertex : SV_POSITION;
				float3 worldVertex : TEXTCOORD0;
				float3 worldNormal : TEXTCOORD1;
			};

			v2f vert(a2v i){
				v2f o;
				//顶点转到裁切空间
				o.clipVertex = UnityObjectToClipPos(i.vertex);

				//顶点转换到世界空间
				o.worldVertex = mul(unity_ObjectToWorld,i.vertex).xyz;

				//法线转换到世界空间
				o.worldNormal = mul(i.normal,(float3x3)unity_WorldToObject);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//漫反射
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				//Blinn-Phone高光
				fixed3 viewDir = normalize(_WorldSpaceCameraPos - i.worldVertex);
				fixed3 bPhoneDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,bPhoneDir)),_Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
