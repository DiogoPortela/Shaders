using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Environment : MonoBehaviour {

    private Camera cam;
    private RenderTexture rt;
    private int cubemapSize = 256;
    private Material mat;

    private void Start()
    {
        mat = new Material(Shader.Find("Shaders/environment"));
        if (!cam)
        {
            GameObject c = new GameObject("cubemap_cam", typeof(Camera));
            c.hideFlags = HideFlags.HideAndDontSave;
            c.transform.position = transform.position;
            c.transform.rotation = transform.rotation;
            cam = c.GetComponent<Camera>();
            cam.farClipPlane = 100;
            cam.enabled = false;
        }
        if (!rt)
        {
            rt = new RenderTexture(cubemapSize, cubemapSize, 16);
            rt.dimension = UnityEngine.Rendering.TextureDimension.Cube;
            rt.hideFlags = HideFlags.HideAndDontSave;
            GetComponent<Renderer>().material = mat;
            mat.SetTexture("_Cube", rt);
        }
        cam.RenderToCubemap(rt, 63);
    }

    private void Update()
    {
        if (transform.hasChanged)
        {
            cam.transform.position = transform.position;
            cam.transform.rotation = transform.rotation;
            cam.RenderToCubemap(rt, 63);
        }
    }
}
