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
    private RenderTexture firstRenderTexture;
    public float blobRadius;
    private int firstPass, lastPass;

    private ComputeBuffer cornersBuffer, cellsBuffer;
    private float[] corners;
    private int[] cells;


    void Start()
    {
        allBlobInstances = garbage;
        material = GetComponent<Renderer>().material;

        firstPass =  blobGenerator.FindKernel("CSCornerSamples");
        lastPass =  blobGenerator.FindKernel("CSCellData");

        firstRenderTexture = new RenderTexture(32, 32, 0, RenderTextureFormat.ARGB64);
        firstRenderTexture.filterMode = FilterMode.Point;
        firstRenderTexture.enableRandomWrite = true;
        firstRenderTexture.Create();
        //blobGenerator.SetTexture(firstPass, "SmallTexture", firstRenderTexture);
        blobGenerator.SetFloat("textureSize", firstRenderTexture.width);
        
        debugMaterial.SetTexture("_MainTex", firstRenderTexture);
        blobGenerator.SetTexture(firstPass, "SmallTexture", firstRenderTexture);
        blobGenerator.SetTexture(lastPass, "SmallTexture", firstRenderTexture);
    }

    void Update()
    {
        //DEBUG SHIT -- MOVE TO START
        blobGenerator.SetFloat("meshSize", this.transform.localScale.x);
        blobGenerator.SetFloat("blobRadius", blobRadius);

        SendPositionsToGPU();
        GenerateCorners();
        blobGenerator.Dispatch(firstPass, firstRenderTexture.width / 4, firstRenderTexture.height / 4, 1);

        cornersBuffer.GetData(corners);
        blobGenerator.SetBuffer(lastPass, "cornersData", cornersBuffer);
        blobGenerator.Dispatch(lastPass, firstRenderTexture.width / 4, firstRenderTexture.height / 4, 1);
    }

    private void SendPositionsToGPU(){
        blobGenerator.SetFloat("arrayCount", allBlobInstances.Count);
        ComputeBuffer blobInstanceArrayBuffer = new ComputeBuffer(allBlobInstances.Count, sizeof(float) * 2);
        List<Vector2> blobInstanceVectors = new List<Vector2>();
        foreach(Transform t in allBlobInstances){
            blobInstanceVectors.Add(new Vector2(t.localPosition.x, t.localPosition.z));
        }
        blobInstanceArrayBuffer.SetData(blobInstanceVectors);

        blobGenerator.SetBuffer(firstPass, "blobInstanceArray", blobInstanceArrayBuffer);
    }
    private void GenerateCorners(){
        int blobImageSize = 32;
        blobGenerator.SetFloat("arrayData", blobImageSize);

        corners = new float[blobImageSize * blobImageSize];
        cells = new int[(blobImageSize - 1) * (blobImageSize - 1)];

        cornersBuffer = new ComputeBuffer(corners.Length, sizeof(float));
        cellsBuffer = new ComputeBuffer(cells.Length, sizeof(int));

        cornersBuffer.SetData(corners);
        cellsBuffer.SetData(cells);

        blobGenerator.SetBuffer(firstPass, "cornersData", cornersBuffer);
        blobGenerator.SetBuffer(lastPass, "cellsData", cellsBuffer);
    }
}
