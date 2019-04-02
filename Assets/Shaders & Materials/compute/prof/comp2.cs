using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class comp2 : MonoBehaviour
{
	public ComputeShader shader;

	RenderTexture rt;
	public int x = 256, y = 256;
	//draw stuff
	Renderer rend;

	void Start()
	{
		rt = new RenderTexture(x, y, 24);
		rt.enableRandomWrite = true;
		rt.Create();

		rend = GetComponent<Renderer>();
		rend.enabled = true;
	}

	void Update()
	{
		int index = shader.FindKernel("CSSource");		
		int index2 = shader.FindKernel("CSGO");
		shader.SetTexture(index, "Result", rt);
		shader.SetFloat("xSize", x);
		shader.SetFloat("ySize", y);
		shader.Dispatch(index,x/8,y/8,1);

		rend.material.SetTexture("_MainTex", rt);
	}
}
