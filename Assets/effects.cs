using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class effects : MonoBehaviour {

    private Material mat;
    public int times;

    private void Awake()
    {
        mat = new Material(Shader.Find("Shaders/effects"));
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture tmp = RenderTexture.GetTemporary(source.width, source.height);

        for(int i = 0; i < times; i++)
        {
            Graphics.Blit(source, tmp, mat);
            Graphics.Blit(tmp, source, mat);
        }
        Graphics.Blit(source, destination, mat);
    }
}
