using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class particle_manager2 : MonoBehaviour
{
	public ComputeShader shader;
	RenderTexture rt;
	Renderer rend;
	//particles
	public int resolution = 256;
	public int numParticles = 1000;

	public bool pause = true;

	struct particle
	{
		public Vector2 pos;
		public Vector2 dir;
		public Vector3 color;
		public float alive;
	};
	ComputeBuffer particleBuffer;

	void Start()
	{
		rt = new RenderTexture(resolution, resolution, 24);
		rt.enableRandomWrite = true;
		rt.Create();

		particleBuffer = new ComputeBuffer( numParticles, 
											sizeof(float)*8, 
											ComputeBufferType.Default);
		rend = GetComponent<Renderer>();
		rend.enabled = true;
	}

	void rekebisha() //reset
	{
		particle[] ps = new particle[numParticles];
		for(int i=0; i<numParticles; i++)
		{
			particle p = new particle();
			p.pos = new Vector2(Random.Range(10, resolution-10), 
								Random.Range(10, resolution-10));
			p.dir = new Vector2(Random.Range(-50,50), 
								Random.Range(-50,50));
			Color c = Random.ColorHSV(0,1,0.5f,1,0.5f,1);
			p.color = new Vector3(c.r, c.g, c.b);
			p.alive = 0f;
			ps[i] = p;
		}
		particleBuffer.SetData(ps);
	}

	void tuma() //dispatch
	{
		int index = shader.FindKernel("CSMain");
		int index2 = shader.FindKernel("CSClean");
		//limpeza
		shader.SetTexture(index2, "Result", rt);
		shader.Dispatch(index2,resolution/8,resolution/8,1);
		//particulas
		shader.SetTexture(index, "Result", rt);
		shader.SetBuffer(index, "particleBuffer", particleBuffer);
		shader.SetFloat("time", Time.timeSinceLevelLoad);		
		shader.SetFloat("deltatime", Time.deltaTime);
		shader.Dispatch(index,numParticles/100,1,1);

		rend.material.SetTexture("_MainTex", rt);
	}

	void Update()
	{
		if(Input.GetKeyDown(KeyCode.Alpha1)) //pausa ou não
		{
			pause = !pause;
		}
		if(Input.GetKeyDown(KeyCode.Alpha2)) //reset
		{
			rekebisha();
		}
		if(!pause)
		{
			tuma(); //dispatch do compute shader
		}
	}

	void OnDestroy()
	{
		rt.Release();
		particleBuffer.Release();
	}
}
