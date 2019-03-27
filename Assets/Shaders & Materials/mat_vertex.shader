Shader "Shaders/mat_vertex"
{
	Properties
	{
		_Color("Diffuse", Color) = (1,1,1,1)
		_Spec("Specular", Color) = (1,1,1,1)
		_Shinniness("Shinniness", Range(1, 32)) = 1
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			uniform float4 _Color;
			uniform float4 _Spec;
			uniform float _Shinniness;

			struct vertexIn
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};
			struct vertexOut
			{
				float4 pos : SV_POSITION;
				float4 color: COLOR;
			};

			vertexOut vert(vertexIn input)
			{
				vertexOut output;
				
				//Specular
				float3 cam = _WorldSpaceCameraPos.xyz;
				float3 positionWorld = mul(UNITY_MATRIX_M, input.pos);
				float3 lookDiretion = normalize(positionWorld - cam);

				//Difuse
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 normal = normalize(
					mul(float4(input.normal, 0), unity_WorldToObject).xyz
					);

				float3 reflection = reflect(lightDirection, normal);
				
				float diffuseIntensity = max(0, dot(normal, lightDirection));
				float specularIntensity = 0;

				if (diffuseIntensity > 0) {
					specularIntensity = pow(max(0, dot(reflection, lookDiretion)), _Shinniness);
				}

				output.pos = UnityObjectToClipPos(input.pos);
				output.color = _Color * diffuseIntensity + _Spec * specularIntensity;
				return output;
			}
			float4 frag(vertexOut output) : COLOR
			{
				return output.color;
			}
			ENDCG
		}
	}
}