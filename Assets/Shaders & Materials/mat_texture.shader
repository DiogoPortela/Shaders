Shader "Shaders/mat_texture"
{
	Properties
	{
		_Color("Cor", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
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

			struct vertexIn
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct vertexOut
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			vertexOut vert(vertexIn i)
			{
				vertexOut o;

				o.pos = UnityObjectToClipPos(i.pos);
				o.uv = i.uv;

				return o;
			}
			float4 frag(vertexOut i) : COLOR
			{
				//return tex2D(_MainTex, i.uv) + _Color;
				//return float4(i.uv, 0, 1);
				float time = _Time.x * 80;
				float cor = tex2D(_MainTex, float2(sin(time) * i.uv.x, i.uv.y));
				//float4 cor = float4(cos(time) * i.uv.x, sin(time) * i.uv.y , 0, 1);
				/*if (i.uv.x > 0.5 && i.uv.y < 0.5) {
					cor = float4(0, 1, 0, 1);
				}
				else {
					cor = float4(0, 0, 1, 1);
				}*/


				return cor;
			}
			ENDCG
		}
	}
}
