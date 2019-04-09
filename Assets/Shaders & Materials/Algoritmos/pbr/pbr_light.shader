// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shaders/pbr_light"
{
    Properties
    {
        _DifColor("Cor Difusa", Color) = (1,1,1,1)
        _SpecColor("Cor Especular", Color) = (1,1,1,1)
        _Smoothness("Smoothness", Range(0,1)) = 0
        _Metallic("Metallic", Range(0,1)) = 0
        _IOR("Index of Refraction", Range(0, 2)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform float4 _DifColor, _SpecColor;
            uniform float _Smoothness, _Metallic, _IOR;

            struct vert_in{
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };
            struct frag_in{
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
                float3 bitangent : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            //ndf
            float ggx_ndf(float roughness, float NdotH){
                float rr = roughness * roughness;
                float nn = NdotH * NdotH;
                float tanr = (1-nn) /(nn);
                return ((1.0 / 3.1415) * sqrt(roughness / (nn * rr + tanr)));
            }
            float blinn_ndf(float NdotH, float shininess)
            {
                float specularGloss = max(1, shininess * 40);
                float res = pow(NdotH, specularGloss) * shininess * ((2+shininess) / (2*3.1415));
                return res;
            }

            float gaussian_ndf(float NdotH, float roughness)
            {
                float rr = roughness * roughness;
                float theta = acos(NdotH);
                return exp(-theta * theta / rr);
            }

            float wardA_ndf(float anisotropy, float smoothness, float NdotL, float NdotV, float NdotH, float HX, float HY)
            {
                float aspect = sqrt(1.0 - anisotropy * 0.9);
                float x = max(0.001, sqrt(1.0 - smoothness) / aspect) * (smoothness * smoothness);
                float y = max(0.001, sqrt(1.0 - smoothness) * aspect) * (smoothness * smoothness);
                HX /= x;
                HY /= y;

                return sqrt(max(0.001, NdotL / NdotV)) * exp(-2.0 * (HX*HX + HY * HY) / (1 + NdotH));
            }
            //gs
            float walter_gsf(float NdotL, float NdotV, float roughness){
                float a = roughness * roughness;
                float nl = NdotL * NdotL;
                float nv = NdotV * NdotV;
                float sl = 2.0 / (1.0 + sqrt(1.0 + a * (1.0 - nl)/(nl)));
                float sv = 2.0 / (1.0 + sqrt(1.0 + a * (1.0 - nv)/(nv)));

                return(sv * sl);
            }
            float neumann_gsf(float NdotL, float NdotV){
                return (NdotL * NdotL) / max(NdotL, NdotV);
            }
            //ff
            float mix_f(float i, float j, float x){
                return j * x + i * (1.0 - x);
            }
            float schlick_f(float i){
                float x = clamp(1.0 - i, 0.0, 1.0);
                return x*x*x*x*x;
            }
            float schlick_ff(float ior, float LdotH){
                float f = pow(ior -1, 2) / pow(ior + 1, 2);
                return f + (1-f) * schlick_f(LdotH);
            }
            float f0(float NdotL, float NdotV, float LdotH, float roughness){
                float light = schlick_f(NdotL);
                float view = schlick_f(NdotV);
                float diff = 0.5 + 2.0 * LdotH * LdotH * roughness;
                return mix_f(1, diff, light) * mix_f(1, diff, view);
            }

            frag_in vert (vert_in i){
                frag_in o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.normal = normalize(mul(unity_WorldToObject, float4(i.normal, 0)).xyz);
                o.tangent = normalize(mul(float4(i.tangent, 0), UNITY_MATRIX_M));
                o.bitangent = normalize(cross(o.normal, o.tangent));
                o.worldPos = mul(UNITY_MATRIX_M, i.pos);
                return o;
            }
            float4 frag (frag_in i) : COLOR {

                float4 result;

                float3 N = normalize(i.normal);                                     //NORMAL
                float3 L = normalize(_WorldSpaceLightPos0.xyz);                     //LUZ
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);    //OLHAR
                float3 R = reflect(-V, N);                                          //REFLECAO DO OLHAR
                float3 H = normalize(V + L);                                        //HALF DIRECTION
                float3 Halt = reflect(-L, N);                                       //ALTERNATIVA DO DE CIMA.

                float4 cDiffuse = _DifColor;
                float4 cSpecular = _SpecColor;

                float NdotL = max(dot(N, L), 0.0);
                float NdotH = max(dot(N, H), 0.0);
                float NdotV = max(dot(N, V), 0.0);
                float VdotH = max(dot(V, H), 0.0);
                float LdotH = max(dot(L, H), 0.0);
                float LdotV = max(dot(L, V), 0.0);
                float RdotV = max(dot(R, V), 0.0);

                float distr_dif = 1;
                float distr_spec = 1;

                float smoothness = _Smoothness;
                float metallic = _Metallic;
                float roughness = 1.0 - (smoothness * smoothness);
                roughness *= roughness;
                float ior = _IOR;

                //Normal Distribution Function
                //float ndf = ggx_ndf(roughness, NdotH);
                float ndf = wardA_ndf(1, smoothness, NdotL, NdotV, NdotH, dot(H, i.tangent), dot(H, i.bitangent));
                
                //Geometry Shadowing
                //float gs = walter_gsf(NdotL, NdotV, roughness);
                float gs =  neumann_gsf(NdotL, NdotV);
                
                //Fresnel Function
                float ffd = f0(NdotL, NdotV, LdotH, roughness);
                float ffs = schlick_ff(ior, LdotH);

                

                //calc distributions
                distr_dif *= max(0.01, (1.0f - metallic)) * ffd;
                distr_spec += ((ndf * gs * ffs)/(4.0 * NdotL * NdotV));

                cDiffuse *= distr_dif;
                cSpecular *= distr_spec;

                result = float4((cDiffuse.rbg + cSpecular.rgb) * NdotL, 1);
                return result;
            }
            ENDCG
        }
    }
}
