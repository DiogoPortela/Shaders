Shader "Shaders/normalMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex("Normal", 2D) = "bump" {}
    }
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform sampler2D _MainTex, _NormalTex;

            #include "UnityCG.cginc"

            struct vertexIn{
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
                float2 uv : TEXCOORD0;

            };
            struct fragmentIn{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
                float3 bitangent : TEXCOORD1;
            };

            fragmentIn vert (vertexIn i){
                fragmentIn o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.uv = i.uv;

                o.normal = UnityObjectToWorldNormal(i.normal);
                o.tangent = UnityObjectToWorldNormal(i.tangent);
                o.bitangent = cross(o.tangent, o.normal);

                return o;
            }

            float4 frag (fragmentIn i) : COLOR {
                float3 tangentNormal = tex2D(_NormalTex, i.uv) * 2 - 1;
                float3 surfaceNormal = i.bitangent;
                
				float3 worldNormal = float3(i.tangent * tangentNormal.r + i.bitangent * tangentNormal.g + i.normal * tangentNormal.b);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float4 diffuseIntensity = dot(worldNormal, lightDirection);
                return tex2D(_MainTex, i.uv) * diffuseIntensity;
            }
            ENDCG
        }
    }
}
