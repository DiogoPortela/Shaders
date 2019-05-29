﻿Shader "Shaders/BlobShader"
{
    Properties
    {
        _blobRadius ("Blob Radius", float) = 0.1
        _blobThickness("Thickness", float) = 1
        _meshSize("MeshSize", float) = 1
    }
    SubShader
    {

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform StructuredBuffer<float2> blobInstanceArray;
            uniform float _blobRadius, _blobThickness, arrayCount, _meshSize;


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
                for(int i = 0; i < arrayCount; i++){
                    blob += CalculateMetaball(blobInstanceArray[i], uv);
                }

                //return blob;
                return color;
            }

            ENDCG
        }
    }
}
