Shader "Shaders/environment"
{
	Properties
	{
		_Cube ("Texture", Cube) = "" {}
		_refract("RefractionIndex", float) = 1.5
		_reflVal("ReflectionValue", Range(0, 1)) = 1
	}
		SubShader
	{

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform samplerCUBE _Cube;
			uniform float _refract;
			uniform float _reflVal;

			struct vertexIn
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};
			struct vertexOut
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float3 look : TEXCOORD0;
			};
			
			vertexOut vert(vertexIn i)
			{
				vertexOut o;

				o.look = mul(UNITY_MATRIX_M, i.pos).xyz - _WorldSpaceCameraPos.xyz;
				o.normal = normalize(mul(float4(i.normal, 0.0), unity_WorldToObject).xyz);

				o.pos = UnityObjectToClipPos(i.pos);

				return o;
			}
			float4 frag(vertexOut i) : COLOR
			{
				float3 refl = reflect(normalize(i.look), normalize(i.normal));
				float3 refr = refract(normalize(i.look), normalize(i.normal), _refract);

				//float4 fresnel = Rzero + (1.0f - Rzero) * pow(abs(1.0f - dot(Input.Normal, Input.ViewVec)), 5.0);

				return texCUBE(_Cube, refl) * _reflVal + texCUBE(_Cube, refr) * (1 -_reflVal);

				/*float4 t = tex2D(DiffuseSampler, Input.TexCoord);

				float4 fresnel = Rzero + (1.0f - Rzero) * pow(abs(1.0f - dot(Input.Normal, Input.ViewVec)), 5.0);
				float4 result = 5 * t + lerp(t, reflection, fresnel);
				result.a = 1;
				return result;*/
			}
			ENDCG
		}
	}
}
