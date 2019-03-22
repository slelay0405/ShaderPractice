Shader "Custom/NromalMapWorldSpaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTexture", 2D) = "white" {}
        _BumpTex ("BumpTexture", 2D) = "bump" {}
        _BumpScale ("BumpScale", float) = 1.0
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8,256)) = 20
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
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 clipVertex : SV_POSITION;
				float4 uv : TEXCOORD0;
				//世界空间的点的位置存在w项中
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCCORD2;
				float4 TtoW2 : TEXCOORD3;
			};

			v2f vert(a2v i){
				v2f o;

				o.clipVertex = UnityObjectToClipPos(i.vertex);

				//uv坐标
				o.uv.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = i.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;

				//计算世界空间下的法线、切线、副法线
				float3 worldNormal = normalize(mul(i.normal , (float3x3)unity_WorldToObject));
				float3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld , i.tangent.xyz));
				//内置函数写法
				//float3 worldNormal = UnityObjectToWorldNormal(i.normal);
				//float3 worldTangent = UnityObjectToWorldDir(i.tangent.xyz);
				float3 worldBinormal = cross(worldNormal , worldTangent) * i.tangent.w;

				//世界空间下的顶点位置
				float3 worldVertex = mul(unity_ObjectToWorld , i.vertex).xyz;

				//构造切线空间到世界空间的矩阵
				o.TtoW0 = float4(worldTangent.x , worldBinormal.x , worldNormal.x , worldVertex.x);
				o.TtoW1 = float4(worldTangent.y , worldBinormal.y , worldNormal.y , worldVertex.y);
				o.TtoW2 = float4(worldTangent.z , worldBinormal.z , worldNormal.z , worldVertex.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				float3 worldVertex = float3(i.TtoW0.w , i.TtoW1.w , i.TtoW2.w);

				//世界空间的光和视角方向
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldVertex));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldVertex));

				//世界空间下的法线
				fixed4 packedNormal = tex2D(_BumpTex , i.uv.zw);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				fixed3 worldNormal = normalize(float3( dot(i.TtoW0.xyz , tangentNormal) , dot(i.TtoW1 , tangentNormal) , dot(i.TtoW2 , tangentNormal)));
				
				//纹理贴图采样
				fixed3 albedo = tex2D(_MainTex , i.uv).rgb * _Color.rgb;

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,lightDir));

				//高光反射
				fixed3 bPhone = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow( max(0,dot(worldNormal,bPhone)),_Gloss);

				return fixed4(ambient + diffuse + specular,1.0);
			}
			ENDCG
		}
	}
    FallBack "Diffuse"
}
