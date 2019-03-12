// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PreVertexLevelDiffuseShader"
{
    Properties
    {
        _Diffuse ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
	    Pass{
		    Tags { "LightMode"="ForwardBase" }

            CGPROGRAM

		    #include "Lighting.cginc"
		
		    #pragma vertex vert
		    #pragma fragment frag

		    fixed4 _Diffuse;

		    struct a2v{
		     	float4 vertex : POSITION;
		    	float4 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 color : COLOR;
			};

			v2f vert(a2v v){
				v2f o;
				//顶点变换到裁切空间
				o.pos = UnityObjectToClipPos(v.vertex);

				//从Unity内置变量获取环境光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//世界空间中顶点法线
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));

				//世界空间中光照方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				//漫反射部分
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				return fixed4(i.color,1.0);
			}
			ENDCG
		}
	}
    FallBack "Diffuse"
}
