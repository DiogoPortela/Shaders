// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shaders/tess"
{
    Properties
    {
    	_tessOut("tess externo", Range(1,64)) = 1.0
    	_tessIn("tess interno", Range(1,64)) = 1.0
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

            uniform float _tessOut, _tessIn;

            struct vs_in
            {
            	float4 pos : POSITION;
            };
            struct hs_in
            {
  	        	float4 pos : POSITION;
            };
            struct control_point
            {
            	float4 pos : POSITION;
            };
            struct fs_in
            {
            	float4 pos : SV_POSITION;
            };
            struct tess_constant
            {
            	float out_tess[3] : SV_TessFactor;
            	float in_tess : SV_InsideTessFactor;
            };

            hs_in vs(vs_in i)
            {
            	hs_in o;
            	o.pos = i.pos;
            	return o;
            }

            tess_constant get_tess(InputPatch<hs_in, 3> i)
            {
            	tess_constant o;

            	o.out_tess[0] = _tessOut;
            	o.out_tess[1] = _tessOut;
            	o.out_tess[2] = _tessOut;
            	o.in_tess = _tessIn;

            	return o;
            }

            //hull shader
            [domain("tri")]
            [partitioning("pow2")]
            [outputtopology("triangle_cw")]
            [patchconstantfunc("get_tess")]
            [outputcontrolpoints(3)]
            control_point hs( InputPatch<hs_in, 3> i, uint id : SV_OutputControlPointID)
            {
            	control_point o;
            	o.pos = i[id].pos;
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

            	o.pos = UnityObjectToClipPos(float4(p, 1.0));
            	return o;
            }

            float4 fs(fs_in i) : COLOR
            {
				return float4(1,1,0,1);
            }

            ENDCG
        }
    }
}
