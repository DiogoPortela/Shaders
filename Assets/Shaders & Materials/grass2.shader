Shader "Shaders/grass2"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_sizeX("sizeX", float) = 1.0
		_sizeY("sizeY", float) = 1.0
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geo
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float _sizeY, _sizeX;

			struct vert_in
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct geo_in
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct frag_in
			{
				float4 pos : POSITION;
				float h : NORMAL;
				float2 uv : TEXCOORD0;
			};

			geo_in vert(vert_in i)
			{
				geo_in o = (geo_in)0;
				o.pos = mul(UNITY_MATRIX_M, i.pos);
				o.normal = i.normal;
				o.uv = i.uv;
				return o;
			}

			[maxvertexcount(12)]
			void geo(triangle geo_in i[3],
				inout TriangleStream<frag_in> triStream)
			{
				//centro do triangulo
				//normal deste triangulo
				//obter o ponto de cima usando a normal
				//float3 center_pos = (	i[0].pos.xyz +
				//						i[1].pos.xyz + 
				//						i[2].pos.xyz) / 3.0;
				float time = _Time.x*20*tan(i[0].uv.x)+sin(i[1].uv.y) + cos(i[2].uv.y);
				int t = floor(time);
				float ft = frac(time);
				float3 center_pos = lerp(i[t%3].pos.xyz, 
										i[(t+1) % 3].pos.xyz, 
										ft);

				float2 center_uv = (i[0].uv +
									i[1].uv +
									i[2].uv) / 3.0;
				float3 center_normal = (i[0].normal +
										i[1].normal +
										i[2].normal) / 3.0;
				center_normal = normalize(center_normal);
				center_pos += center_normal*_sizeY;
				//gerar piramide
				frag_in o;
				//lados da piramide
				for (int k=0; k<3; k++) 
				{ 
					o.pos = mul(UNITY_MATRIX_VP, i[k].pos);
					o.uv = i[k].uv;
					o.h = i[k].pos.y;
					triStream.Append(o);

					o.pos = mul(UNITY_MATRIX_VP, i[(k+1)%3].pos);
					o.uv = i[(k + 1) % 3].uv;
					o.h = i[(k + 1) % 3].pos.y;
					triStream.Append(o);

					o.pos = mul(UNITY_MATRIX_VP, float4(center_pos,1.0));
					o.uv = center_uv;
					o.h = center_normal.y;
					triStream.Append(o);
					triStream.RestartStrip();
				}
				//base da piramide
				o.pos = mul(UNITY_MATRIX_VP, i[0].pos);
				o.uv = i[0].uv;
				o.h = i[0].pos.y;
				triStream.Append(o);

				o.pos = mul(UNITY_MATRIX_VP, i[1].pos);
				o.uv = i[1].uv;
				o.h = i[1].pos.y;
				triStream.Append(o);
				
				o.pos = mul(UNITY_MATRIX_VP, i[2].pos);
				o.uv = i[2].uv;
				o.h = i[2].pos.y;
				triStream.Append(o);
				triStream.RestartStrip();
			}

			float4 frag(frag_in i) : COLOR
			{
				//return tex2D(_MainTex, i.uv);
				return float4(0.2,0.8,0.3,1.0)*i.h;
			}

			ENDCG
		}
	}
}
