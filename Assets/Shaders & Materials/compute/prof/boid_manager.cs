using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class boid_manager : MonoBehaviour
{
	public int resolution = 256;
	public int numBoids = 100;
	//boid manager stuff
	public float deltaMod = 22.0f;		
	public float weight = 20.0f;	
	public float repelWeight = 1000.0f;	
	public float alignWeight = 200.0f;	
	public float cohesionWeight = 20.0f;	
	public float maxSpeed = 12.0f;	
	public float repelDist = 3.0f;
	public float alignDist = 15.0f;
	public float cohesionDist = 50.0f;	
	public float maxForce = 15.0f;

	struct boidData
	{
		public Vector2 pos;
		public Vector2 dir;		
		public Vector4 color; // color.rgb + alive
	};

	public ComputeShader shader;
	ComputeBuffer boidBuffer;
	ComputeBuffer boidBuffer2;
	uint[] ids;
	bool ping_pong = false;

	public int nthreads = 10;
	public bool pause = false;
	public Material mat;

	BoxCollider box;
	void Start()
	{
		box = GetComponent<BoxCollider>();
		boidBuffer = new ComputeBuffer(	numBoids, 
										sizeof(float)*8, 
										ComputeBufferType.Append);
		boidBuffer2 = new ComputeBuffer(numBoids, 
										sizeof(float)*8, 
										ComputeBufferType.Append);
		ids = new uint[numBoids];
		for(uint i=0; i < numBoids; i++)
		{
			ids[i] = i;
		}
	}

	void setValues()
	{
		shader.SetInt("resolution", resolution);
		shader.SetInt("numBoids", numBoids);
		shader.SetFloat("deltaMod", deltaMod);
		shader.SetFloat("weight", weight);
		shader.SetFloat("repelWeight", repelWeight); 
		shader.SetFloat("alignWeight", alignWeight);
		shader.SetFloat("cohesionWeight", cohesionWeight);
		shader.SetFloat("maxSpeed", maxSpeed);
		shader.SetFloat("repelDist", repelDist);
		shader.SetFloat("alignDist", alignDist);
		shader.SetFloat("cohesionDist", cohesionDist);
		shader.SetFloat("maxForce", maxForce);
		shader.SetFloat("deltaTime", Time.deltaTime);
	}

	void reset()
	{
		boidData[] tmp = new boidData[numBoids];
		for(int i=0; i<numBoids; i++)
		{
			tmp[i].pos = new Vector2(	Random.value * resolution, 
										Random.value * resolution);
			tmp[i].dir = Random.insideUnitCircle * maxSpeed;
			tmp[i].color = new Vector4(	Random.value, 
										Random.value, 
										Random.value, 
										1.0f);
		}
		boidBuffer.SetData(tmp);
		boidBuffer.SetCounterValue((uint)numBoids);
		ping_pong = false;
	}

	void dispatchCompute()
	{
		int index = shader.FindKernel("CSMain");
		setValues();

		ComputeBuffer idsBuff = new ComputeBuffer(	numBoids, 
													sizeof(uint), 
													ComputeBufferType.Append);
		idsBuff.SetData(ids);
		idsBuff.SetCounterValue((uint)numBoids);

		if(ping_pong)
		{
			boidBuffer.SetCounterValue(0);
			shader.SetBuffer(index, "boidBuffer", boidBuffer2);
			shader.SetBuffer(index, "boidBuffer2", boidBuffer);
		}
		else
		{
			boidBuffer2.SetCounterValue(0);
			shader.SetBuffer(index, "boidBuffer", boidBuffer);
			shader.SetBuffer(index, "boidBuffer2", boidBuffer2);
		}
		shader.SetBuffer(index, "idsBuff", idsBuff);
		shader.Dispatch(index, numBoids / nthreads, 1, 1);

		idsBuff.Dispose();
		ping_pong = !ping_pong;
	}

	void Update()
	{
		if(Input.GetKeyDown(KeyCode.Alpha1)) //pausa ou não
		{
			pause = !pause;
		}
		if(Input.GetKeyDown(KeyCode.Alpha2)) //reset
		{
			reset();
		}
		if(!pause)
		{
			dispatchCompute(); //dispatch do compute shader
		}
	}

	void OnDestroy()
	{
		boidBuffer.Release();
		boidBuffer2.Release();
	}

	void OnRenderObject()
	{
		mat.SetPass(0);
		mat.SetMatrix("my_mat", transform.localToWorldMatrix);
		if(ping_pong)
		{
			mat.SetBuffer("boidBuffer", boidBuffer);
		}
		else
		{
			mat.SetBuffer("boidBuffer", boidBuffer2);
		}
		mat.SetVector("bounds", new Vector4(box.size.x, 
											box.size.y, 
											box.size.z, 
											0));		
		mat.SetVector("invbounds", new Vector4(	box.size.x/resolution, 
												box.size.y/resolution, 
												box.size.z/resolution, 
												1));
		Graphics.DrawProcedural(MeshTopology.Triangles,4*3,numBoids);
	}
}
