Shader "Shaders/mat_pixel"
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
				float3 normal : NORMAL;
				float3 modelPosition : TEXCOORD0;
			};

			vertexOut vert(vertexIn input)
			{
				vertexOut output;

				float3 modelPosition = mul(UNITY_MATRIX_M, input.pos);
				float3 normal = normalize(
					mul(float4(input.normal, 0), unity_WorldToObject).xyz
				);

				output.pos = UnityObjectToClipPos(input.pos);
				output.normal = normal;
				output.modelPosition = modelPosition;
				return output;
			}
			float4 frag(vertexOut output) : COLOR
			{
				float3 normal = normalize(output.normal);
				float3 cam = _WorldSpaceCameraPos.xyz;
				float3 lookDirection = normalize(output.modelPosition - cam);
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 reflection = reflect(lightDirection, normal);

				float specularIntensity = 0;
				float diffuseIntensity = max(0, dot(normal, lightDirection));

				if (diffuseIntensity > 0) { 
					specularIntensity = pow(max(0, dot(reflection, lookDirection)), _Shinniness);
				}

				return _Color * diffuseIntensity + _Spec * specularIntensity;
			}
			ENDCG
		}
	}
}