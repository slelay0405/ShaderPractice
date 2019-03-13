Shader "Custom/PrePixelLevelSpecularShader"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
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
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXTCOORD0;
				float3 worldPos : TEXTCOORD1;
			};

			v2f vert(a2v i){
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);

				//将顶点转到世界空间
				o.worldPos = mul(unity_ObjectToWorld,i.vertex).xyz;

				//获得世界空间的法线
				o.worldNormal = mul(i.normal,(float3x3)unity_WorldToObject);

				return o;
			}

			float4 frag(v2f i) : SV_Target{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//世界空间的法线和光
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//漫反射
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				//光的出射角和摄像机视角
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

				//高光反射
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
