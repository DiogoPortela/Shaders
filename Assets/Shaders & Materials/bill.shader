Shader "Shaders/bill"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_sizeX("Size X", float) = 1.0
		_sizeY("Size Y", float) = 1.0
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
			uniform float _sizeX;
			uniform float _sizeY;

			struct vert_in{
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};
			struct geo_in{
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};
			struct frag_in{
				float4 pos : SV_POSITION;
				float2 uv : TEXTCOORD0;
			};

			geo_in vert(vert_in i) {
				geo_in o = (geo_in)0;
				o.pos = mul(UNITY_MATRIX_M, i.pos);
				o.normal = i.normal;

				return o;
			}

			[maxvertexcount(4)]
			void geo(point geo_in i[1], inout TriangleStream<frag_in> triStream){
				float3 up = float3(0,1,0);
				float3 look = normalize(-_WorldSpaceCameraPos.xyz + i[0].pos.xyz);
				float3 right = normalize(cross(up, look));
				up = normalize(cross(look, right));

				float4 pos_bill[4];
				float2 uv_bill[4];

				pos_bill[0] = float4(i[0].pos + up * _sizeY - right * _sizeX, 1.0);
				pos_bill[1] = float4(i[0].pos + up * _sizeY + right * _sizeX, 1.0);
				pos_bill[2] = float4(i[0].pos - up * _sizeY - right * _sizeX, 1.0);
				pos_bill[3] = float4(i[0].pos - up * _sizeY + right * _sizeX, 1.0);
				for(int k = 0; k < 4; k++){
					pos_bill[k] = mul(UNITY_MATRIX_VP, pos_bill[k]);
				}

				uv_bill[0] = float2(0, 1);
				uv_bill[1] = float2(1, 1);
				uv_bill[2] = float2(0, 0);
				uv_bill[3] = float2(1, 0);

				//
				frag_in o;
				for(int j = 0; j < 4; j++){
					o.pos = pos_bill[j];
					o.uv = uv_bill[j];
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
