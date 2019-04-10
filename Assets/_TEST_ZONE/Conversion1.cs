using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Conversion1 : MonoBehaviour
{
    private const int heigth = 256, width = 256;

    public ComputeShader computeShader;
    [Range(0, 1)]
    public float value;
    public RenderTexture alphaBlendTexture;

    private Material material;
    private int computeIndex;
    private int clearIndex;

    private ComputeBuffer computeBuffer;
    private List<Vector3> points;
    private void Start()
    {
        material = GetComponent<Renderer>().material;

        alphaBlendTexture = new RenderTexture(width, heigth, 24);    //1320
        alphaBlendTexture.enableRandomWrite = true;
        alphaBlendTexture.Create();

        computeIndex = computeShader.FindKernel("CSMain");
        clearIndex = computeShader.FindKernel("CSClean");

        computeShader.SetTexture(computeIndex, "Result", alphaBlendTexture);
        computeShader.SetTexture(clearIndex, "Result", alphaBlendTexture);

        Restart();

        computeBuffer = new ComputeBuffer(1, sizeof(float) * 3);
        computeBuffer.SetData(points);
        computeShader.SetBuffer(computeIndex, "data", computeBuffer);
    }

    private void Restart()
    {
        points = new List<Vector3>();
        points.Add(new Vector3(Random.Range(0, width), Random.Range(0, heigth), 1));
        computeShader.SetInt("count", 1);
        
        computeShader.Dispatch(clearIndex, width / 8, heigth / 8, 1);
    }

    private void Update()
    {
        for (int i = 0; i < points.Count; i++)
        {
            Vector3 v = points[i];
            v = new Vector3(v.x, v.y, v.z + Time.deltaTime);
        }

        computeShader.SetFloat("value", value);
        computeShader.SetFloat("deltaTime", Time.deltaTime);
        computeShader.Dispatch(computeIndex, width / 8, heigth / 8, 1);
        material.SetTexture("_AlphaText", alphaBlendTexture);

        if (Input.GetKeyDown(KeyCode.Alpha1))
            Restart();
    }
}
