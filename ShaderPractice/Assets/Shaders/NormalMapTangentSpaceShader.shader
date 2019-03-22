Shader "Custom/NormalMapTangentSpaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_MainTex("MainTexture",2D) = "white"{}
		_BumpMap("NormalMap",2D) = "bump"{}
		_BumpScale("BumpScale",Float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,256)) = 20
    }
    SubShader
    {
		Pass{
			Tags { "LightModel" = "ForwardBase" }

			CGPROGRAM

			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertexPos : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 clipPosition : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v i){
				v2f o;

				//顶点着色的本职工作
				o.clipPosition = UnityObjectToClipPos(i.vertexPos);

				//计算uv
				o.uv.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = i.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				//计算模型空间变换到切线空间的矩阵
				float3 binormal = cross(normalize(i.normal),normalize(i.tangent.xyz)) * i.tangent.w;
				float3x3 rotationMatrix = float3x3(i.tangent.xyz , binormal , i.normal);

				//用自己计算和内置提供的两个矩阵变换光纤和视角的空间
				o.lightDir = mul(rotationMatrix , ObjSpaceLightDir(i.vertexPos)).xyz;
				o.viewDir = mul(rotationMatrix,ObjSpaceViewDir(i.vertexPos)).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				//归一化
				fixed3 tLightDir = normalize(i.lightDir);
				fixed3 tViewDir = normalize(i.viewDir);

				//纹理贴图采样
				fixed3 albedo = tex2D(_MainTex , i.uv).rgb * _Color;

				//法线贴图采样
				fixed4 packedNormal = tex2D(_BumpMap , i.uv.zw);
				fixed3 tangentNormal;
				/*tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));*/
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy , tangentNormal.xy)));


				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tLightDir));

				//高光反射
				fixed3 bPhone = normalize(tLightDir + tViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,bPhone)),_Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
