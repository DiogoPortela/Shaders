// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shaders/raymarch"
{
    Properties
    {
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            struct vert_in{
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct frag_in{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 ray_dir : TEXCOORD1;
            };

            frag_in vert(vert_in i){
                frag_in o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.uv = i.uv;
                //o.ray_dir = normalize(mul(UNITY_MATRIX_M, i.pos).xyz - _WorldSpaceCameraPos.xyz);
                o.ray_dir = mul(UNITY_MATRIX_M, i.pos).xyz;
                return o;
            }

            float4 frag(frag_in i) : COLOR {

                //SPHERE
                float3 centre = float3(0,0,0);
                float radius = 2;
                
                //SQUARE
                float3 centreSqr = float3(0,0,0);
                float size = 2;


                float3 cor = float3(0,0,0);

                //RAY
                float3 ray_origin = _WorldSpaceCameraPos.xyz;
                float3 ray_dir = normalize(i.ray_dir - ray_origin);

                //raymaych
                //dist max
                float max_dist = 100.0f;
                //samples
                int samples = 1000;
                float passo = max_dist /(float) samples;

                for(int k = 0; k < samples; k++){
                    float3 spos = ray_origin + ray_dir * passo * k;

                    // float test = length(spos - centre);
                    // if(test < radius){
                    //     cor += float3(0.01, 0.0, 0.001);
                    // }
                    
                    float left = centreSqr.x  - (size / 2);
                    float right = centreSqr.x + (size / 2);
                    float up = centreSqr.y    + (size / 2);
                    float down = centreSqr.y  - (size / 2);
                    float back = centreSqr.z  + (size / 2);
                    float front = centreSqr.z - (size / 2);
                    

                    if( spos.x < right  && spos.x > left    &&
                        spos.y < up     && spos.y > down    &&
                        spos.z < back   && spos.z > front)
                        {
                            cor += float3(0.1, 0.0, 0.01);
                        }

                }

                return float4(cor, 1);
            }

            ENDCG
        }
    }
}
