Shader "cods/cod1"
{
	Properties
	{
		_Sura ("sura", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex ara
			#pragma fragment oro
			
			#include "UnityCG.cginc"

			struct a
			{
				float4 p : POSITION;
				float2 u : TEXCOORD0;
			};

			struct b
			{
				float4 p : SV_POSITION;
				float2 u : TEXCOORD0;
			};

			uniform sampler2D _Sura;
			
			b ara (a i)
			{
				b o;
				o.p = UnityObjectToClipPos(i.p);
				o.u = i.u;
				return o;
			}
			
			float4 oro(b i) : COLOR
			{
				float2 yav;
				float4 c = float4(1,1,1,1);
				if (cos(_Time.y) > 0.75) 
				{
					yav = float2(cos(i.u.x + _Time.x), cos(i.u.y + _Time.x*0.5));
					c = tex2D(_Sura, yav);
				}
				else 
				{
					yav = float2(cos(i.u.x * _Time.y), tan(i.u.y * _Time.x));
					c = float4(tex2D(_Sura, yav).xy, 0.0, 1.0);
				}
				
				return c;
			}
			ENDCG
		}
	}
}
