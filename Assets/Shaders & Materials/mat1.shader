// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shaders/mat1"
{
	Properties
	{
		_Color("Cor", Color) = (1,1,1,1)	
	}
		SubShader
	{

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _Color;
			struct vertexIn
			{
				float4 pos : POSITION;
				float4 color : COLOR;

			};
			struct vertexOut
			{
				float4 pos : SV_POSITION;
				float4 color : COLOR;
			};

			vertexOut vert(vertexIn i)
			{
				vertexOut o;
				
				o.pos = UnityObjectToClipPos(i.pos);
				o.color = i.color;

				return o;
			}
			float4 frag(vertexOut pos) : COLOR
			{
				return _Color;
			}
			ENDCG
		}
	}
}
