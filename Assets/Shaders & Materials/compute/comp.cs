using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class comp : MonoBehaviour {

	public ComputeShader shader;
	RenderTexture rt;
	public int x = 256, y = 256;
	Renderer render;

	public void Start()
    {
        rt = new RenderTexture(x, y, 24);
        rt.enableRandomWrite = true;
        rt.Create();

        render = GetComponent<Renderer>();
        render.enabled = true;
    }

    public void Update()
    {
        int index = shader.FindKernel("CSSource");
        shader.SetTexture(index, "Result", rt);
        shader.SetFloat("xSize", x);
        shader.SetFloat("ySize", y);
        shader.Dispatch(index, x/8, y/8, 1);

        render.material.SetTexture("_MainTex", rt);
    }
}
