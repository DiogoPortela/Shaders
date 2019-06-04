using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Conversion1 : MonoBehaviour
{
    public int heigth = 256, width = 256;
    public int minHolesCount;
    public int maxHolesCount;
    [Range(0, 5)] public float value;
    public ComputeShader computeShader;
    public RenderTexture alphaBlendTexture;

    private Material material;
    private int computeIndex;
    private int clearIndex;
    private ComputeBuffer computeBuffer;
    private List<Vector4> points;

    private void Start()
    {
        material = GetComponent<Renderer>().material;

        alphaBlendTexture = new RenderTexture(width, heigth, 0, RenderTextureFormat.RFloat);
        alphaBlendTexture.enableRandomWrite = true;
        alphaBlendTexture.Create();

        computeIndex = computeShader.FindKernel("CSFade");
        clearIndex = computeShader.FindKernel("CSClean");

        computeShader.SetTexture(computeIndex, "Result", alphaBlendTexture);
        computeShader.SetTexture(clearIndex, "Result", alphaBlendTexture);
        computeShader.SetBool("isFadeIn", false);

        Restart();        
    }

    private void Restart()
    {
        computeBuffer?.Release();
        points = new List<Vector4>();
        int randomValue = Random.Range(minHolesCount, maxHolesCount);
        for(int i = 0; i < randomValue; i++){
            points.Add(new Vector4(Random.Range(width/4, width/2), Random.Range(0, heigth/2), 0,        Random.Range(20, 100)));
            points.Add(new Vector4(Random.Range(width/4, width/2), Random.Range(heigth/2, heigth), 0,   Random.Range(20, 100)));
            points.Add(new Vector4(Random.Range(0, width/4), Random.Range(0, heigth/2), 0,              Random.Range(20, 100)));
            points.Add(new Vector4(Random.Range(0, width/4), Random.Range(heigth/2, heigth), 0,         Random.Range(20, 100)));
        }
        computeBuffer = new ComputeBuffer(randomValue * 4, sizeof(float) * 4);
        computeBuffer.SetData(points);
        computeShader.SetBuffer(computeIndex, "data", computeBuffer);
        
        computeShader.SetInt("count", randomValue * 4);
        computeShader.Dispatch(clearIndex, width / 8, heigth / 8, 1);
    }

    private void Update()
    {
       DecreaseOpacity();

        if (Input.GetKeyDown(KeyCode.Alpha1))
            Restart();
    }

    private void DecreaseOpacity(){
        for (int i = 0; i < points.Count; i++)
        {
            points[i] += new Vector4(0, 0, points[i].w * value * Time.deltaTime, 0);
        }
        computeBuffer.SetData(points);
        computeShader.SetBuffer(computeIndex, "data", computeBuffer);

        computeShader.Dispatch(computeIndex, width / 8, heigth / 8, 1);
        material.SetTexture("_AlphaText", alphaBlendTexture);
    }
}