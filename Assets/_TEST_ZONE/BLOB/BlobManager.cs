using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlobManager : MonoBehaviour
{
    public List<Transform> garbage;
    private List<Transform> allBlobInstances;
    private Material material;


    //ComputeShader part:
    public ComputeShader blobGenerator;
    public Material debugMaterial;
    public Material debugMaterial2;
    public int initialSampleSize;
    public int finalImageSize;
    private RenderTexture debugRenderTexture;
    private RenderTexture result;
    public float blobRadius;
    private int firstPass, secondPass, thirdPass, lastPass;

    private ComputeBuffer cornersBuffer, cellsBuffer, functionDataBuffer, blobInstanceArrayBuffer;
    private float[] corners;
    private int[] cells;


    void Start()
    {
        allBlobInstances = garbage;
        material = GetComponent<Renderer>().material;

        firstPass =  blobGenerator.FindKernel("CSCornerSamples");
        secondPass =  blobGenerator.FindKernel("CSCellData");
        thirdPass = blobGenerator.FindKernel("CSCalculateFunctionData");
        lastPass = blobGenerator.FindKernel("CSDrawOutLine");

        debugRenderTexture = new RenderTexture(initialSampleSize, initialSampleSize, 0, RenderTextureFormat.Default);
        debugRenderTexture.filterMode = FilterMode.Point;
        debugRenderTexture.enableRandomWrite = true;
        debugRenderTexture.Create();
        blobGenerator.SetFloat("textureSize", debugRenderTexture.width);

        result = new RenderTexture(finalImageSize, finalImageSize, 0, RenderTextureFormat.Default);
        result.enableRandomWrite = true;
        result.Create();
        blobGenerator.SetTexture(lastPass, "Result", result);

        debugMaterial.SetTexture("_MainTex", result);
        debugMaterial2.SetTexture("_MainTex", debugRenderTexture);
        blobGenerator.SetTexture(firstPass, "SmallTexture", debugRenderTexture);
        blobGenerator.SetTexture(secondPass, "SmallTexture", debugRenderTexture);
        blobGenerator.SetTexture(thirdPass, "SmallTexture", debugRenderTexture);
        blobGenerator.SetTexture(lastPass, "SmallTexture", debugRenderTexture);

        blobGenerator.SetFloat("pixelToCorner", (float)initialSampleSize / (float)finalImageSize);
        blobGenerator.SetFloat("cornerToPixel", (float)finalImageSize / (float)initialSampleSize);
    }

    void Update()
    {
        //DEBUG SHIT -- MOVE TO START
        blobGenerator.SetFloat("meshSize", this.transform.localScale.x);
        blobGenerator.SetFloat("blobRadius", blobRadius);

        SendPositionsToGPU();
        GenerateBuffers();
        blobGenerator.Dispatch(firstPass, (initialSampleSize + 4) / 4, (initialSampleSize + 4) / 4, 1);
        blobGenerator.Dispatch(secondPass, initialSampleSize / 4, initialSampleSize / 4, 1);
        blobGenerator.Dispatch(thirdPass, initialSampleSize / 4,initialSampleSize / 4, 1);
        blobGenerator.Dispatch(lastPass, finalImageSize / 8, finalImageSize / 8, 1);

        cornersBuffer.Release();
        cellsBuffer.Release();
        blobInstanceArrayBuffer.Release();
        functionDataBuffer.Release();
    }

    private void SendPositionsToGPU(){
        blobGenerator.SetFloat("blobInstanceArrayCount", allBlobInstances.Count);
        blobInstanceArrayBuffer = new ComputeBuffer(allBlobInstances.Count, sizeof(float) * 2);
        List<Vector2> blobInstanceVectors = new List<Vector2>();
        foreach(Transform t in allBlobInstances){
            blobInstanceVectors.Add(new Vector2(t.localPosition.x, t.localPosition.z));
        }
        blobInstanceArrayBuffer.SetData(blobInstanceVectors);

        blobGenerator.SetBuffer(firstPass, "blobInstanceArray", blobInstanceArrayBuffer);
    }
    private void GenerateBuffers(){
        corners = new float[(initialSampleSize + 1) * (initialSampleSize + 1)];
        cells = new int[initialSampleSize * initialSampleSize];

        cornersBuffer = new ComputeBuffer(corners.Length, sizeof(float));
        cellsBuffer = new ComputeBuffer(cells.Length, sizeof(int));
        functionDataBuffer = new ComputeBuffer(cells.Length, sizeof(float) * 2);

        cornersBuffer.SetData(corners);
        cellsBuffer.SetData(cells);

        blobGenerator.SetBuffer(firstPass, "cornersData", cornersBuffer);
        blobGenerator.SetBuffer(secondPass, "cornersData", cornersBuffer);

        blobGenerator.SetBuffer(secondPass, "cellsData", cellsBuffer);
        blobGenerator.SetBuffer(thirdPass, "cellsData", cellsBuffer);
        blobGenerator.SetBuffer(lastPass, "cellsData", cellsBuffer);

        blobGenerator.SetBuffer(thirdPass, "cellFunction", functionDataBuffer);
        blobGenerator.SetBuffer(lastPass, "cellFunction", functionDataBuffer);
    }
}
