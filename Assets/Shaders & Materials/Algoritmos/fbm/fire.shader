// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "fbm/fire"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        RenderTyp
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct vert_in{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct frag_in{
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            uniform sampler2D _MainTex;

            float rand(float2 v)
            {
                return frac(sin(cos(dot(v, float2(3.1415, 12.1414)))) * 83758.5453);
            }

            float noise(float2 v){
                float2 d = float2(0,1);
                float2 b = floor(v);
                float2 f = smoothstep(float2(0,0), float2(1,1), frac(v));
                return lerp(    lerp(rand(b), rand(b + d.yx), f.x),
                                lerp(rand(b + d.xy), rand(b+d.yy), f.x),
                                f.y);
            }
            
            float fbm(float2 v)
            {
                float total = 0.0;
                float amplitude = 1.0;
                int octaves = 5;
                float gain = 0.47;
                float lacunarity = 1.7;

                for(int i = 0; i < octaves; i++)
                {
                    total += noise(v) * amplitude;
                    v += v*lacunarity;
                    amplitude *= gain;

                }

                return total;
            }

            frag_in vert (vert_in i)
            {
                frag_in o;
                o.vertex = UnityObjectToClipPos(i.vertex);
                o.uv = i.uv;
                return o;
            }

            float4 frag(frag_in i) : COLOR
            {

                const float3 c1 = float3(0.5, 0.0, 0.1);
                const float3 c2 = float3(0.9, 0.1, 0.0);
                const float3 c3 = float3(0.2, 0.1, 0.7);
                const float3 c4 = float3(1.0, 0.9, 0.1);
                const float3 c5 = float3(0.1, 0.1, 0.1);
                const float3 c6 = float3(0.9, 0.9, 0.9);

                float time = _Time.y;
                float2 speed = float2(0.1, 0.9);
                float shift = 1.327 + sin(time) / 2.4;
                float alpha = 1.0;

                float dist = 3.5 - sin(time + 0.4) / 1.89;
                float2 uv = float2(i.uv.x, 1-i.uv.y);
                float2 p = uv * dist;
                p += sin(p.yx * 4.0 + float2(0.2, -0.3) * time) * 0.04;
                p += sin(p.yx * 8.0 + float2(0.6, 0.1) * time) * 0.01;

                p.x -= time / 1.1;

                //curvas
                float q = fbm(p - time* 0.3 + 1.0 * sin(time + 0.5) / 2.0);
                float qb = fbm(p - time* 0.4 + 0.1 * sin(time) / 2.0);
                float q2 = 0.4 * (fbm(p - time* 0.44 - 5.0 * sin(time) / 2.0) - 6.0);
                float q3 = 2 *(fbm(p - time* 0.0 - 10.0 * sin(time) / 15.0) - 4.0);
                float q4 = 0.6 *(fbm(p - time* 1.4 + 20.0 * sin(time) / 14.0) + 2.0);
                q = (q + qb - q2 - q3 + q4) / 3.8;

                float2 r = float2(fbm(p + q * 0.5 + time * speed.x -p.x - p.y),
                                    fbm(p + q - time * speed.y));
                float3 cores =  lerp(c1, c2, fbm(p + r)) + 
                                lerp(c3, c4, r.x) - 
                                lerp(c5, c6, r.y);
                float3 color = cores * 0.3;
                color += float3(1.0 / (pow(color + 1.61, float3(4.0, 4.0, 4.0))) * cos(shift * (1 - i.uv.y)));
				color += float3(1.0, 0.2, 0.05) / (pow((r.y + r.y)* max(.0,p.y) + 0.1, 4.0));;
				color += (tex2D(_MainTex,uv*0.6 + float2(.5,.1)).xyz*0.01*pow((r.y + r.y)*.65,5.0) + 0.055)*lerp(float3(.9,.4,.3), float3(.7,.5,.2), uv.y);
                color = color / (1.0 + max(float3(0,0,0), color));

                return float4(color, alpha);
            }
           
            ENDCG
        }
    }
}
