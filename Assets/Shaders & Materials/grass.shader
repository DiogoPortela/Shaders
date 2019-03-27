Shader "Shaders/grass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_scale("Scale", float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geo
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float _scale;

			struct vert_in{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};
			struct geo_in{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};
			struct frag_in{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			geo_in vert(vert_in i) {
				geo_in o = (geo_in)0;
				o.pos = mul(UNITY_MATRIX_M, i.pos);
				o.normal = i.normal;
				o.uv = i.uv;

				return o;
			}

			[maxvertexcount(12)]
			void geo(triangle geo_in i[3], inout TriangleStream<frag_in> triStream) {
				
				float time = _Time.x*20*tan(i[0].uv.x)+sin(i[1].uv.y) + cos(i[2].uv.y);
				int t = floor(time);
				float ft = frac(time);
				float3 mid_position = lerp( i[t%3].pos.xyz, i[(t+1)% 3].pos.xyz, ft);
				
				//float3 mid_position = (i[0].pos + i[1].pos + i[2].pos) / 3.0;
				float3 normal_position = (i[0].normal + i[1].normal + i[2].normal) / 3.0;
				float2 uv_position = (i[0].uv + i[1].uv + i[2].uv) / 3.0;

 				normal_position = normalize(normal_position);
				mid_position += normal_position * _scale;
				

				frag_in o;
				//lados da piramide
                for (int k = 0; k < 3; k++)
                {
                    o.pos = mul(UNITY_MATRIX_VP, i[k].pos);
                    o.uv = i[k].uv;
                    o.normal = i[k].normal;
                    triStream.Append(o);

                    o.pos = mul(UNITY_MATRIX_VP, i[(k + 1)%3].pos);
                    o.uv = i[(k + 1) % 3].uv;
                    o.normal = i[(k + 1) % 3].normal;
                    triStream.Append(o);

                    o.pos = mul(UNITY_MATRIX_VP, float4(mid_position, 1.0));                    o.uv = uv_position;
                    o.normal = normal_position;
                    triStream.Append(o);
                }

                //base da piramide
                for (int j = 0; j > 3; j++)
                {
                    o.pos = mul(UNITY_MATRIX_VP, i[j].pos);
                    o.uv = i[j].uv;
                    o.normal = i[j].normal;
                    triStream.Append(o);
                }
                triStream.RestartStrip();
			}

			float4 frag(frag_in i) : COLOR {
				return tex2D(_MainTex, i.uv);
			}
			
			ENDCG
		}
	}
}