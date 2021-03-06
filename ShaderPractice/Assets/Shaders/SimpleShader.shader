﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SimpleShader"
{
    Properties{
	   _Color("Color Tint",Color) = (1.0,1.0,1.0,1.0)
	}

    SubShader
    {

		Pass{
		    CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;

			struct a2v{
				float4 vertex : POSITION;
				fixed3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5);
			    return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				return fixed4(i.color * _Color.rgb,1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
