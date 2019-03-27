Shader "Shaders/tessLod"
{
    Properties
    {
    	_MainTex("Textura", 2D) = "white" {}
    	_tessOut("tess externo", Range(1,64)) = 1.0
    	_tessIn("tess interno", Range(1,64)) = 1.0
    	_heightMap("Height Map", 2D) = "white" {}    	
    	_h("Height", float) = 1.0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vs
            #pragma fragment fs
            #pragma hull hs
            #pragma domain ds

            #include "UnityCG.cginc"

            uniform float _tessOut, _tessIn, _h;
            uniform sampler2D _heightMap, _MainTex;

            struct vs_in
            {
            	float4 pos : POSITION;
            	float3 normal : NORMAL;
            	float2 uv : TEXCOORD0;
            };
            struct hs_in
            {
  	        	float4 pos : POSITION;
            	float3 normal : NORMAL;
            	float2 uv : TEXCOORD0;
            };
            struct control_point
            {
            	float4 pos : POSITION;
            	float3 normal : NORMAL;
            	float2 uv : TEXCOORD0;
            };
            struct fs_in
            {
            	float4 pos : SV_POSITION;
            	float3 normal : NORMAL;
            	float2 uv : TEXCOORD0;
            };
            struct tess_constant
            {
            	float out_tess[3] : SV_TessFactor;
            	float in_tess : SV_InsideTessFactor;
            };

            //vertex shader
            hs_in vs(vs_in i)
            {
            	hs_in o;
            	o.pos = i.pos;
            	o.uv = i.uv;
            	o.normal = normalize(mul(unity_WorldToObject,float4(i.normal, 0)).xyz);
            	return o;
            }

            tess_constant get_tess(InputPatch<hs_in, 3> i)
            {
            	tess_constant o;

            	float3 cam = _WorldSpaceCameraPos.xyz;
            	float3 centre = mul(UNITY_MATRIX_M, (i[0].pos+i[1].pos+i[2].pos)/3.0).xyz;
            	float dist = length(cam-centre);

            	float distMin = 0.0, distMax = 8.0;

            	//(distMax - dist)/(distMax-distMin) * _tessOut;

            	float tess = max( 1.0, (distMax - dist)/(distMax-distMin) * _tessOut);

            	o.out_tess[0] = tess;
            	o.out_tess[1] = tess;
            	o.out_tess[2] = tess;
            	o.in_tess = tess;

            	return o;
            }

            //hull shader
            [domain("tri")]
            [partitioning("integer")]
            [outputtopology("triangle_cw")]
            [patchconstantfunc("get_tess")]
            [outputcontrolpoints(3)]
            control_point hs( InputPatch<hs_in, 3> i, uint id : SV_OutputControlPointID)
            {
            	control_point o;
            	o.pos = i[id].pos;
            	o.uv = i[id].uv;
            	o.normal = i[id].normal;
            	return o;
            }

            //domain shader
            [domain("tri")]
            fs_in ds(const OutputPatch<control_point, 3> i, tess_constant tc, float3 barycentric : SV_DomainLocation)
            {
            	fs_in o;

            	float3 p = 	i[0].pos.xyz * barycentric.x + 
            				i[1].pos.xyz * barycentric.y + 
            				i[2].pos.xyz * barycentric.z;
            	float3 n = 	i[0].normal * barycentric.x + 
            				i[1].normal * barycentric.y + 
            				i[2].normal * barycentric.z;
            	float2 u = 	i[0].uv * barycentric.x + 
            				i[1].uv * barycentric.y + 
            				i[2].uv * barycentric.z;

            	float4 displacement = tex2Dlod(_heightMap, 
										float4(u,0.0,0.0));
				p = mul(UNITY_MATRIX_M, float4(p,1)) + normalize(n)*displacement.x*_h;

            	o.pos = mul(UNITY_MATRIX_VP, float4(p,1));
            	o.uv = u;
            	o.normal = n;
            	return o;
            }

            //fragment shader
            float4 fs(fs_in i) : COLOR
            {
				return tex2D(_MainTex, i.uv);
            }

            ENDCG
        }
    }
}
