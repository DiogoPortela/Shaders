Shader "Shaders/BlobShader"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _blobRadius ("Blob Radius", float) = 0.1
        _meshSize("MeshSize", float) = 1
        _arraycount("nao mexer", float ) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Background" }
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            //uniform sampler2D _MainTex;
            uniform StructuredBuffer<float2> blobInstanceArray;
            uniform float _blobRadius, _arraycount, _meshSize;


            float CalculateMetaball(float2 metaballCenter, float2 uv){
                return _blobRadius / dot(uv - metaballCenter, uv- metaballCenter);
            }

            struct vert_in{
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct frag_in{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            frag_in vert(vert_in i){
                frag_in o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.uv = i.uv;
                return o;
            }

            float4 frag(frag_in i) : COLOR {
                float4 color = float4(0, 0, 0, 1);
                float2 uv = i.uv * _meshSize - float2(_meshSize, _meshSize) / 2;

                float blob = 0;
                for(int i = 0; i < _arraycount; i++){
                    blob += CalculateMetaball(blobInstanceArray[i], uv);
                }

                if(blob >= 1)
                color.x = blob;
                return color;
            }

            ENDCG
        }
    }
}
