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
    private void Start() {
        material = GetComponent<Renderer>().material;

        alphaBlendTexture = new RenderTexture(600, 1320, 24);
        alphaBlendTexture.enableRandomWrite = true;
        alphaBlendTexture.Create();

        computeIndex = computeShader.FindKernel("CSMain");
        computeShader.SetTexture(computeIndex, "Result", alphaBlendTexture);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest) {
        material.SetTexture("Alpha Texture", alphaBlendTexture);
        computeShader.Dispatch(computeIndex, 600 / 8, 1320 / 8, 1);

        Graphics.Blit(src, dest);
    }
}
