using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlobManager : MonoBehaviour
{
    public List<Transform> garbage;
    private List<Transform> allBlobInstances; 

    private Material material;

    void Start()
    {
        allBlobInstances = garbage;
        material = GetComponent<Renderer>().material;
    }

    void Update()
    {
        material.SetFloat("arrayCount", allBlobInstances.Count);
        material.SetFloat("_meshSize", this.transform.localScale.x);
        SendPositionsToGPU();
    }

    private void SendPositionsToGPU(){
        ComputeBuffer blobInstanceArrayBuffer = new ComputeBuffer(allBlobInstances.Count, sizeof(float) * 2);
        List<Vector2> blobInstanceVectors = new List<Vector2>();
        foreach(Transform t in allBlobInstances){
            blobInstanceVectors.Add(new Vector2(t.transform.position.x - this.transform.position.x, t.transform.position.z - this.transform.position.z));
        }
        blobInstanceArrayBuffer.SetData(blobInstanceVectors);
        material.SetBuffer("blobInstanceArray", blobInstanceArrayBuffer);
    }
}
