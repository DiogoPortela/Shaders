// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TEST/Conversion1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondTex ("Faded Texture", 2D) = "white" {}
        _AlphaText("Alpha Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
            #include "UnityCG.cginc"
            uniform sampler2D _MainTex, _SecondTex, _AlphaText;

           struct vertex_in{
               float4 position : POSITION;
               float2 uv : TEXCOORD0;
           };
           struct fragment_in{
               float4 position : SV_POSITION;
               float2 uv : TEXCOORD0;
           };

            fragment_in vert(vertex_in i){
                fragment_in o;

                o.position = UnityObjectToClipPos(i.position);
                o.uv = i.uv;

                return o;
            }
            float4 frag(fragment_in i) : COLOR {
                float alphaValue = tex2D(_AlphaText, i.uv);
                //float4 result = tex2D(_MainTex, i.uv) * alphaValue + tex2D(_SecondTex, i.uv) * (1 - alphaValue);
                return float4(tex2D(_MainTex, i.uv).xyz, alphaValue);
            }
            ENDCG
        }
    }
}
