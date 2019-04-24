// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "procedural/shader1"
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
            
            //#include "UnityCG.cginc"

            struct vertex_in{
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct frag_in{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            frag_in vert(vertex_in i){
                frag_in o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.uv = i.uv;
                return o;
            }

            //Utils

            float plot(float2 uv, float p)
            {
                float thickness = 0.03;
                return (smoothstep(p - thickness, p, uv.y) - smoothstep(p, p + thickness, uv.y));
            }
            float2x2 roda2D(float a){

                //cos(a) -sin(a)
                //sin(a) cos(a)
                return float2x2(cos(a), -sin(a), sin(a), cos(a));
            }

            float rand(float2 uv)
            {
                //return frac(sin(uv.x * 10) * sin(uv.y * 5));
                return frac(sin(dot(uv, float2(10, 77))) *
                            539445.43);
            }

            float random2D(float2 uv){
                uv = float2(dot(uv, float2(32423.23, 234234.212)), dot(uv, float2(534534.3423, 234234.5234)));
                return (2.0 * frac(sin(uv) * 423423.) - 1.0);
            }

            float noise(float2 uv){
                float2 i = floor(uv);
                float2 f = frac(uv);

                float2 comb = f * f * (3.0 - 2.0 * f);

                float2 a = i + float2(0,0);
                float2 b = i + float2(1,0);
                float2 c = i + float2(0,1);
                float2 d = i + float2(1,1);

                return lerp(lerp(random2D(a), random2D(b), uv.x),
                            lerp(random2D(c), random2D(d), uv.x),
                            uv.y);
            }

            float noise3(float2 uv){
                float2 i = floor(uv);
                float2 f = frac(uv);

                float2 comb = f * f * (3.0 - 2.0 * f);

                float2 a = i + float2(0,0);
                float2 b = i + float2(1,0);
                float2 c = i + float2(0,1);
                float2 d = i + float2(1,1);

                return lerp(lerp(rand(a), rand(b), uv.x),
                            lerp(rand(c), rand(d), uv.x),
                            uv.y);
            }

            float lines(float2 uv, float b){
                float scale = 10;
                uv += scale;

                return smoothstep(0, 0.5 * b + 0.5, (sin(uv.x * 3.1415) + b * 2.0) * 0.5);
            }

            float4 frag(frag_in i) : COLOR
            {
                float3 c = float3(0,0,0);
                float2 sc = i.uv; //screen coordinates

                //step();           //mudar valores bruscamente
                //smoothestep();    //mudar valores gradualmente
                
                //linhas
                // float eq = sc.x; //equacao linha
                // float p = plot(sc, eq);
                //c = p * float3(0, 1, 0);


                //objectos
                //quadrado
                // float2 b1 = step(float2(0.1, 0.1), sc);
                // float p = b1.x * b1.y;

                // float2 b2 = step(float2(0.1, 0.1), 1-sc);
                // p *= b2.x * b2.y;

                //circulo
                // float raio = 0.2;
                // float2 dist = sc - float2(0.5, 0.5);
                // float p = 1-smoothstep(raio - (raio * 0.01), raio + (raio * 0.01), dot(dist, dist));
                // float p = distance(sc, float2(0.5, 0.5));

                //FORMAS
                // sc = sc * 10;               //divisao do espaco
                // float sc2 = sc * 0.5;

                // float2 sc_i = floor(sc);
                // float2 sc_f = frac(sc);     //tiling

                // float2 pos = float2(0.5, 0.5) - sc_f;
                // pos = mul(roda2D(cos(_Time.y) * 3.1415), pos);
                // float r = length(pos) * 2.0;
                // float a = atan2(pos.y, pos.x);

                // float p = cos(a * 10);
                // p = 1 - smoothstep(p, p + 0.02, r);

                // float2 sc_f2 = frac(sc2);
                // float raio2 = 0.02;
                // float2 dist2 = sc_f2 - float2(0.5, 0.5);
                // float p2 = 1-smoothstep(raio2 - (raio2 * 0.01), raio2 + (raio2 * 0.01), dot(dist2, dist2));

                // c = float3(p + p2, p + p2, p + p2);

                //return float4(c, 1);

                // float r = rand(i.uv);
                // float2 ipos = floor(i.uv);
                // float2 fpos = frac(i.uv);

                // float2 tile;
                // float ii = frac((r - 0.5) * 2.0);

                // if(ii > 0.75){
                //     tile = float2(1,1) - fpos;
                // }
                // else if (ii > 0.5){
                //     tile = float2(1 - fpos.x, fpos.y);
                // }
                // else if (ii > 0.25){
                //     tile = 1- float2(1 - fpos.x, fpos.y);
                // }

                // float p = plot(tile, tile.x);

                //float n = noise2(sc * 100);
                float2 pos = float2(sc.x * 2.0, sc.y * 1.0);
                float p = pos.x;
                pos = mul(roda2D(noise3(pos)), pos);
                p = lines(pos, 0.5);

                c = float3(p, p, p);

                return float4(c, 1);
            }

            ENDCG
        }
    }
}
