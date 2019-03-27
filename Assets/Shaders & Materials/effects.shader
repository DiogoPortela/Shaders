Shader "Shaders/effects"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
		SubShader
	{

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_TexelSize;

			struct vertexIn
			{
				float4 pos : POSITION;
				float4 uv : TEXCOORD0;
			};
			struct vertexOut
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			//Aux functions
			float4 filter(sampler2D tex, float2 uv, float2 size) {
				float4 res = float4(0, 0, 0, 0);

				float f[9] = {	1, 2, 1,
								2, 4, 2,
								1, 2, 1 };
				int it = 0;

				for (float x = -1; x < 2; x++) {
					for (float y = -1; y < 2; y++) {
						res += f[it++] * tex2D(tex, uv + float2(x * size.x, y * size.y));
					}
				}
				return res / 9.0;
			}

			//Shader
			vertexOut vert(vertexIn i)
			{
				vertexOut o;

				o.pos = UnityObjectToClipPos(i.pos);
				o.uv = i.uv;

				return o;
			}
			float4 frag(vertexOut i) : COLOR
			{
				float4 cor = float4(0,0,0,1);
				//float resx = _ScreenParams.z, resy = _SreenParams.w;

				float2 texel_size = float2(_MainTex_TexelSize.xy);
				cor = filter(_MainTex, i.uv, texel_size);
				return float4(cor.xyz, 1.0);
			}
			ENDCG
		}
	}
}
