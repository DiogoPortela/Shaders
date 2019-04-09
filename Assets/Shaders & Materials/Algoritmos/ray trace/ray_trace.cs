using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ray_trace : MonoBehaviour
{
    public ComputeShader shader;
    public Texture skybox;
    public Light sourceLight;
    public Camera cam;

    //setup spheres
    public int numSpheres;
    public float placementRadius;
    public float sphereRadius;
 
    struct sphere{
        public float radius;
        public Vector3 center;
        public Vector3 color;
    };

    ComputeBuffer sphereBuffer;
    RenderTexture renderTexture;

    void Start()
    {
        renderTexture = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
        renderTexture.enableRandomWrite = true;
        renderTexture.Create();

        createSpheres();
    }

    void createSpheres(){
        List<sphere> sp = new List<sphere>();

        for(int i = 0; i < numSpheres; i++){
            sphere s = new sphere();
            s.radius = sphereRadius + Random.Range(1 - sphereRadius, sphereRadius * 0.5f);
            s.center = new Vector3( Random.Range(-placementRadius, placementRadius), 
                                    Random.Range(-placementRadius, placementRadius), 
                                    Random.Range(0, placementRadius / 10));
            Color c = Random.ColorHSV();
            s.color = new Vector3(c.r, c.g, c.b);
            sp.Add(s);
        }

        sphereBuffer = new ComputeBuffer(sp.Count, sizeof(float) * 7);
        sphereBuffer.SetData(sp);
    }

    void renderScene(RenderTexture dest)
    {
        int index = shader.FindKernel("CSMain");
        shader.SetTexture(index, "skybox", skybox);
        shader.SetMatrix("_CameraToWorld", cam.cameraToWorldMatrix);
        shader.SetMatrix("_CameraInverseProjection", cam.projectionMatrix.inverse);

        shader.SetVector("light", new Vector4(sourceLight.transform.forward.x, sourceLight.transform.forward.y, sourceLight.transform.forward.z, sourceLight.intensity));
        shader.SetBuffer(index, "spheres", sphereBuffer);
        shader.SetTexture(index, "Result", renderTexture);

        //dispatch
        shader.Dispatch(index, Screen.width / 8, Screen.height / 8, 1);

        Graphics.Blit(renderTexture, dest);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        renderScene(dest);
    }
}
