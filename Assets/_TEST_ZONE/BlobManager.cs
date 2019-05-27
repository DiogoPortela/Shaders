using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlobManager : MonoBehaviour
{
    public List<Transform> garbage;
    private List<Transform> allBlobInstances; 
    public ComputeShader computeShader;
    private ComputeBuffer computeBuffer;
    public RenderTexture blobTexture;
    private int imageIndex;

    private void Start() {
        allBlobInstances = new List<Transform>();
        allBlobInstances = garbage;

        imageIndex = computeShader.FindKernel("CSMain");
        blobTexture = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.Default);
        blobTexture.enableRandomWrite = true;
        computeShader.SetTexture(imageIndex, "Result", blobTexture);
        computeShader.SetVector("size", new Vector4(Screen.width, Screen.height, 0, 0));
    }

    public void AddTransform(Transform t){
        allBlobInstances.Add(t);
    }
    public void RemoveTransform(Transform t){
        allBlobInstances.Remove(t);
    }

    private void Update() {
        computeBuffer = new ComputeBuffer(allBlobInstances.Count, sizeof(float) * 3);
        List<Vector3> allPositions = new List<Vector3>();
        foreach (var t in allBlobInstances)
        {
            allPositions.Add(Camera.main.WorldToScreenPoint(t.position));
        }
        computeBuffer.SetData(allPositions);
        computeShader.SetFloat("positionCount", allPositions.Count);
        computeShader.SetBuffer(imageIndex, "positionBuffer", computeBuffer);
        computeShader.Dispatch(imageIndex, blobTexture.width, blobTexture.height, 1);
    }
}
