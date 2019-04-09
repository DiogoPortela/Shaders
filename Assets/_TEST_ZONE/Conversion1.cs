using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Conversion1 : MonoBehaviour
{
    public ComputeShader computeShader;
    [Range(0, 1)]
    public float value;
    public RenderTexture alphaBlendTexture;

    private Material material;
    private int computeIndex;
    private int clearIndex;
    private void Start() {
        material = GetComponent<Renderer>().material;

        alphaBlendTexture = new RenderTexture(256, 256, 24);    //1320
        alphaBlendTexture.enableRandomWrite = true;
        alphaBlendTexture.Create();

        computeIndex = computeShader.FindKernel("CSMain");
        clearIndex = computeShader.FindKernel("CSClean");

        computeShader.SetTexture(computeIndex, "Result", alphaBlendTexture);
        computeShader.SetTexture(clearIndex, "Result", alphaBlendTexture);

        computeShader.Dispatch(clearIndex, 256 / 8, 256 / 8, 1);
    }

    private void Update() {
        computeShader.SetFloat("value", value);
        computeShader.SetFloat("deltaTime", Time.deltaTime);
        computeShader.Dispatch(computeIndex, 256 / 8, 256 / 8, 1);
        material.SetTexture("_AlphaText", alphaBlendTexture);

        if(Input.GetKeyDown(KeyCode.Alpha1))
            computeShader.Dispatch(clearIndex, 256 / 8, 256 / 8, 1);
    }
}
