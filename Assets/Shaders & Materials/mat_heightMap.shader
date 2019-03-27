Shader "Shaders/mat_heightmap"
{
	Properties
	{
		_Color("Cor", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_hmap("Texture", 2D) = "white" {}
		_h("DisplacementFactor", float) = 0.1
	}
		SubShader
	{

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _Color;
			uniform sampler2D _MainTex;
			uniform sampler2D _hmap;
			uniform float _h;

			struct vertexIn
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};
			struct vertexOut
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			vertexOut vert(vertexIn i)
			{
				vertexOut o;

				float4 displacement = tex2Dlod(_hmap, float4(i.uv.x, i.uv.y, 0.0, 0.0));
				
				i.pos = i.pos + float4(normalize(i.normal), 0.0) * displacement.x * _h;
				o.pos = UnityObjectToClipPos(i.pos);
				o.uv = i.uv;

				return o;
			}
			float4 frag(vertexOut i) : COLOR
			{
				return tex2D(_MainTex, i.uv) + _Color;
				//return float4(i.uv, 0, 1);
				//float4 cor = float4(cos(time) * i.uv.x, sin(time) * i.uv.y , 0, 1);
				/*if (i.uv.x > 0.5 && i.uv.y < 0.5) {
					cor = float4(0, 1, 0, 1);
				}
				else {
					cor = float4(0, 0, 1, 1);
				}*/


				//return cor;
			}
			ENDCG
		}
	}
}
