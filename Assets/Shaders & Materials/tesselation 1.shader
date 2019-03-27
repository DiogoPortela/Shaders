Shader "Shaders/tesselation1"
{
	Properties
	{
		_MainTex ("Diffuse Map", 2D) = "white" {}
		_normalMap("Normal Map", 2D) = "bump" {}
    	_heightMap("Height Map", 2D) = "white" {}   
		_specMap("Specular Map", 2D) = "white" {}
		_h("Height Value", float) = 0.1 	
		_spec("Specular Color", Color) = (1,1,1,1)
		_specEx("Specular Value", Range(1, 256)) = 1.0
		_tess("Tesselation Value", Range(1, 64)) = 1.0
		_lodDist("Lod Distance", float) = 1.0

	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma hull h
			#pragma domain d
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex, _heightMap, _normalMap, _specMap;
			uniform float _tess, _lodDist, _h, _specEx;
			uniform float4 _spec;

			struct vs_in{
            	float4 pos : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};
			struct hs_in{
            	float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 tangent : TANGENT;
				float3 bitangent : TEXCOORD1;
			};
			 struct control_point{
            	float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 tangent : TANGENT;
				float3 bitangent : TEXCOORD1;

            };
			struct fs_in{
            	float4 pos : SV_POSITION;
				float3 posNoModel : TEXCOORD2;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float3 tangent : TANGENT;
				float3 bitangent : TEXCOORD1;
			};

			 struct tess_constant
            {
            	float out_tess[3] : SV_TessFactor;
            	float in_tess : SV_InsideTessFactor;
            };

			hs_in vert(vs_in i){
				hs_in o; 
				o.pos = i.pos;
				o.uv = i.uv;
				o.normal = UnityObjectToWorldNormal(i.normal);
				o.tangent = UnityObjectToWorldNormal(i.tangent);
				o.bitangent = cross(o.tangent, o.normal);

				return o;
			}
			
            tess_constant get_tess(InputPatch<hs_in, 3> i)
            {
            	tess_constant o;

            	float3 cam = _WorldSpaceCameraPos.xyz;
            	float3 centre = mul(UNITY_MATRIX_M, (i[0].pos + i[1].pos + i[2].pos) / 3.0).xyz;
            	float dist = length(cam-centre);

            	float distMin = 0.0, distMax = _lodDist;

            	float tess = max( 1.0, (distMax - dist)/(distMax - distMin) * _tess);

            	o.out_tess[0] = tess;
            	o.out_tess[1] = tess;
            	o.out_tess[2] = tess;
            	o.in_tess = tess;

            	return o;
            }

			[domain("tri")]
            [partitioning("integer")]
            [outputtopology("triangle_cw")]
            [patchconstantfunc("get_tess")]
            [outputcontrolpoints(3)]
			control_point h(InputPatch<hs_in, 3> i, uint id : SV_OutputControlPointID){
				control_point o;
            	o.pos = i[id].pos;
				o.uv = i[id].uv;
            	o.normal = i[id].normal;
				o.tangent = i[id].tangent;
				o.bitangent = i[id].bitangent;
            	return o;
			}

            [domain("tri")]
            fs_in d(const OutputPatch<control_point, 3> i, tess_constant tc, float3 barycentric : SV_DomainLocation)
            {
            	fs_in o;
				
            	float3 p = 	i[0].pos.xyz * barycentric.x + 
            				i[1].pos.xyz * barycentric.y + 
            				i[2].pos.xyz * barycentric.z;
				float3 n = 	normalize(i[0].normal) * barycentric.x + 
            				normalize(i[1].normal) * barycentric.y + 
            				normalize(i[2].normal) * barycentric.z;
				float2 uv = i[0].uv.xy * barycentric.x + 
            				i[1].uv.xy * barycentric.y + 
            				i[2].uv.xy * barycentric.z;
				float3 t = 	normalize(i[0].tangent) * barycentric.x + 
            				normalize(i[1].tangent) * barycentric.y + 
            				normalize(i[2].tangent) * barycentric.z;
				float3 bt = normalize(i[0].bitangent) * barycentric.x + 
            				normalize(i[1].bitangent) * barycentric.y + 
            				normalize(i[2].bitangent) * barycentric.z;

				//float lenOffset = length(i[0].pos) - length(p);
				p = mul(unity_ObjectToWorld, float4(p,1));// + normalize(n) * lenOffset; 

				float4 displacement = tex2Dlod(_heightMap, float4(uv, 0.0, 0.0));
				p = p + normalize(n) * displacement.x * _h;

				o.posNoModel = p;
            	o.pos = mul(UNITY_MATRIX_VP, float4(p, 1));
				o.uv = uv;
				o.normal = n;
				o.tangent = t;
				o.bitangent = bt;
            	return o;
            }

            float4 frag(fs_in i) : COLOR
            {
				float3 normal = normalize(i.normal);
				float3 tan = normalize(i.tangent);
				float3 bitan = normalize(i.bitangent);

				float3 tangentNormal = tex2D(_normalMap, i.uv) * 2 - 1;
				//float3 surfaceNormal = bitan;
				float3 worldNormal = float3(tan * tangentNormal.r + bitan * tangentNormal.g + normal * tangentNormal.b);

				float3 cam = _WorldSpaceCameraPos.xyz;
				float3 lookDirection = normalize(i.posNoModel - cam);
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 reflection = reflect(lightDirection, normal);

				//float specularIntensity = 0;
				//float diffuseIntensity = 0;
				float diffuseArea = max(0, dot(normal, lightDirection));

				float diffuseIntensity = max(0, dot(worldNormal, lightDirection));
				float specularIntensity = pow(max(0, dot(reflection, lookDirection)), _specEx);

				//return float4(diffuseArea * worldNormal, 1);
				return tex2D( _MainTex, i.uv) * diffuseIntensity + _spec * specularIntensity * tex2D(_specMap, i.uv);
            }

			ENDCG
		}
	}
}
