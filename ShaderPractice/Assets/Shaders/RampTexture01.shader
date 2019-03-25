Shader "Custom/RampTexture01"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _RampTex ("Ramp Texture", 2D) = "white" {}
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
			sampler2D _RampTex;
			//float4 _RampTex_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 objVertex : POSITION;
				float3 objNormal : NORMAL;
			};

			struct v2f{
				float4 clipVertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldVertex : TEXCOORD1;
			};

			v2f vert(a2v i){
				v2f o;
				o.clipVertex = UnityObjectToClipPos(i.objVertex);

				//法线转世界空间
				o.worldNormal = UnityObjectToWorldNormal(i.objNormal);

				//顶点转世界空间
				o.worldVertex = mul((float3x3)unity_ObjectToWorld , i.objVertex).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//漫反射
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldVertex));
				float halfLambert = dot(lightDir , i.worldNormal) * 0.5 + 0.5;
				fixed3 sampledColor = tex2D(_RampTex , fixed2(halfLambert,halfLambert)).rgb * _Color.rgb;
				fixed3 diffuse = _LightColor0.rgb * sampledColor;

				//高光反射
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldVertex));
				fixed3 bPhone = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0 , dot(i.worldNormal , bPhone)) , _Gloss);

				return fixed4(ambient + diffuse + specular,1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
