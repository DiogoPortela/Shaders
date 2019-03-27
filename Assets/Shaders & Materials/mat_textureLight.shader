Shader "Shaders/mat_textureLight"
{
	Properties
	{
		_TexDay("Day texture", 2D) = "white" {}
		_TexNight("Night texture", 2D) = "white" {}
		_MergeValue("Merge Value", Range(0, 1)) = 0.2
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			uniform sampler2D _TexDay;
			uniform sampler2D _TexNight;
			uniform float _MergeValue;

			struct vertexIn
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};
			struct fragIn
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 modelPosition : TEXCOORD1;
			};

			fragIn vert(vertexIn input) {
				fragIn output;

				float3 modelPosition = mul(UNITY_MATRIX_M, input.pos);
				float3 normal = normalize(
					mul(float4(input.normal, 0), unity_WorldToObject).xyz
				);

				output.pos = UnityObjectToClipPos(input.pos);
				output.normal = normal;
				output.modelPosition = modelPosition;
				output.uv = input.uv;
				return output;
			}
			float4 frag(fragIn input) : COLOR{
				float3 normal = normalize(input.normal);
				float3 cam = _WorldSpaceCameraPos.xyz;
				float3 lookDirection = normalize(input.modelPosition - cam);
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 reflection = reflect(lightDirection, normal);

				float specularIntensity = 0;
				//float diffuseIntensity = max(0, dot(normal, -lightDirection));
				//float diffuseIntensity2 = max(0, dot(normal, lightDirection));
				float diffuseIntensity3 = dot(normal, lightDirection);

				/*if (diffuseIntensity > 0) {
					specularIntensity = pow(max(0, dot(reflection, -lookDirection)), _Shinniness);
				}

				return tex2D(_TexDay, input.uv) * diffuseIntensity + _SpecColor * specularIntensity;*/

				//float4 result = float4(0,0,0,0);
				//if (diffuseIntensity > 0) {
				//	specularIntensity = pow(max(0, dot(reflection, -lookDirection)), _Shinniness);
				//	result = tex2D(_TexDay, input.uv) /* diffuseIntensity*/ + _SpecColor * specularIntensity;
				//}
				//else {
				//	result = tex2D(_TexNight, input.uv) /* diffuseIntensity*/ +_SpecColor * specularIntensity;
				//}
				//result = tex2D(_TexDay, input.uv) * (diffuseIntensity) + tex2D(_TexNight, input.uv) * (1 - 0.25 - diffuseIntensity);

				float4 color, day, night;
				day = tex2D(_TexDay, input.uv);
				night = tex2D (_TexNight, input.uv);

				color = float4(0, 0, 0, 0);

				if (diffuseIntensity3 > _MergeValue) {
					color = day;
				}
				else if (diffuseIntensity3 < -_MergeValue) {
					color = night;
				}
				else {
					float m = 1.0 / (2.0 * _MergeValue);
					float y = m * diffuseIntensity3 + 0.5;
					color = lerp(night, day, y);
				}
				return color;
			}
			ENDCG
		}
	}
}
