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
    private RenderTexture firstRenderTexture;
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

        firstRenderTexture = new RenderTexture(32, 32, 0, RenderTextureFormat.Default);
        firstRenderTexture.filterMode = FilterMode.Point;
        firstRenderTexture.enableRandomWrite = true;
        firstRenderTexture.Create();
        blobGenerator.SetFloat("textureSize", firstRenderTexture.width);

        result = new RenderTexture(256, 256, 0, RenderTextureFormat.Default);
        result.enableRandomWrite = true;
        result.Create();
        blobGenerator.SetTexture(lastPass, "Result", result);



        debugMaterial.SetTexture("_MainTex", result);
        debugMaterial2.SetTexture("_MainTex", firstRenderTexture);
        blobGenerator.SetTexture(firstPass, "SmallTexture", firstRenderTexture);
        blobGenerator.SetTexture(secondPass, "SmallTexture", firstRenderTexture);
        blobGenerator.SetTexture(thirdPass, "SmallTexture", firstRenderTexture);
        blobGenerator.SetTexture(lastPass, "SmallTexture", firstRenderTexture);
    }

    void Update()
    {
        //DEBUG SHIT -- MOVE TO START
        blobGenerator.SetFloat("meshSize", this.transform.localScale.x);
        blobGenerator.SetFloat("blobRadius", blobRadius);

        SendPositionsToGPU();
        GenerateBuffers();
        blobGenerator.Dispatch(firstPass, (firstRenderTexture.width + 4) / 4, (firstRenderTexture.height + 4) / 4, 1);
        blobGenerator.Dispatch(secondPass, firstRenderTexture.width / 4, firstRenderTexture.height / 4, 1);
        blobGenerator.Dispatch(thirdPass, firstRenderTexture.width / 4, firstRenderTexture.height / 4, 1);
        blobGenerator.Dispatch(lastPass, (result.width ) / 8, (result.height) / 8, 1);

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
        int blobImageSize = 32;

        corners = new float[(blobImageSize + 1) * (blobImageSize + 1)];
        cells = new int[blobImageSize * blobImageSize];

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
