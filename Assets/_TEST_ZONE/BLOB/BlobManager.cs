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

    void Start()
    {
        allBlobInstances = garbage;
        material = GetComponent<Renderer>().material;

        firstPass =  blobGenerator.FindKernel("CSTextureRender");
        lastPass =  blobGenerator.FindKernel("CSMarchingSquares");


        firstRenderTexture = new RenderTexture(32, 32, 0, RenderTextureFormat.R8);
        firstRenderTexture.filterMode = FilterMode.Point;
        firstRenderTexture.enableRandomWrite = true;
        firstRenderTexture.Create();
        blobGenerator.SetTexture(firstPass, "SmallTexture", firstRenderTexture);
        blobGenerator.SetFloat("textureSize", firstRenderTexture.width);
        
        debugMaterial.SetTexture("_MainTex", firstRenderTexture);
    }

    void Update()
    {
        //DEBUG SHIT -- MOVE TO START
        blobGenerator.SetFloat("meshSize", this.transform.localScale.x);
        blobGenerator.SetFloat("blobRadius", blobRadius);

        blobGenerator.SetFloat("arrayCount", allBlobInstances.Count);
        SendPositionsToGPU2();
        blobGenerator.Dispatch(firstPass, firstRenderTexture.width / 4, firstRenderTexture.height / 4, 1);
    }

    private void SendPositionsToGPU2(){

        ComputeBuffer blobInstanceArrayBuffer = new ComputeBuffer(allBlobInstances.Count, sizeof(float) * 2);
        List<Vector2> blobInstanceVectors = new List<Vector2>();
        foreach(Transform t in allBlobInstances){
            blobInstanceVectors.Add(new Vector2(t.localPosition.x, t.localPosition.z));
        }
        blobInstanceArrayBuffer.SetData(blobInstanceVectors);

        blobGenerator.SetBuffer(firstPass, "blobInstanceArray", blobInstanceArrayBuffer);
    }
}
