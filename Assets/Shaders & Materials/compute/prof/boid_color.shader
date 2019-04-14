Shader "boid/boid_color"
{
    Properties
    {
    }
    SubShader
    {
        Pass
        {
        	Blend SrcAlpha OneMinusSrcAlpha
        	Cull Off

            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct boid
			{
				float2 pos;
				float2 dir;
				float4 color;
			};
			StructuredBuffer<boid> boidBuffer;
			float4 invbounds;
			float4 bounds;
			float4x4 my_mat;

			struct fs_input
			{
				float4 pos : SV_POSITION;
				float4 color : COLOR;	
			};

			fs_input vert(uint id : SV_VertexID, uint inst : SV_InstanceID)
			{
				fs_input o;
				boid b = boidBuffer[inst];

				float3 worldPos = float3(	b.pos.x * invbounds.x - bounds.x*0.5f, 
											b.pos.y * invbounds.y - bounds.y*0.5f, 
											0);

				float3 worldDir = float3(b.dir.x, b.dir.y, 0)*0.002f;
				float3 upDir = float3(0, 0, -1) * 0.01f;
				float3 rightDir = normalize(cross(worldDir, float3(0,0,1))) * 0.01f;

				[branch] switch (id)
				{
					case 0: worldPos = worldPos - worldDir; break;
					case 1: worldPos = worldPos + upDir; break;
					case 2: worldPos = worldPos + rightDir; break;
					case 3: worldPos = worldPos - worldDir; break;
					case 4: worldPos = worldPos + upDir; break;
					case 5: worldPos = worldPos - rightDir; break;
					case 6: worldPos = worldPos - worldDir; break;
					case 7: worldPos = worldPos + rightDir; break;
					case 8: worldPos = worldPos - rightDir; break;
					case 9: worldPos = worldPos + upDir; break;
					case 10: worldPos = worldPos + rightDir; break;
					case 11: worldPos = worldPos - rightDir; break;
				}

				o.pos = mul( UNITY_MATRIX_VP, mul(my_mat, float4(worldPos, 1.0f)));
				o.color = b.color;
				return o;
			}

			float4 frag(fs_input i) : COLOR
			{
				return i.color;
			}
            ENDCG
        }
    }
}
