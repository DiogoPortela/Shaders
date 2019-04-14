using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Convertion2 : MonoBehaviour
{
    public int textureSize = 256;
    public float alphaScale = 1;
    private RenderTexture alphaBlendRenderTexture;
    private Texture2D alphaBlendTexture;
    private Material currentMaterial;
    
    private void Start()
    {
        currentMaterial = GetComponent<Renderer>().material;
        alphaBlendRenderTexture = new RenderTexture(textureSize, textureSize, 0, RenderTextureFormat.RFloat);
        alphaBlendRenderTexture.enableRandomWrite = true;
        alphaBlendRenderTexture.Create();
        alphaBlendTexture = new Texture2D(textureSize, textureSize);

        GenerateTexture();
    }

    private void GenerateTexture(){
        float offsetX = Random.Range(-alphaScale * 100, 100 *alphaScale);
        float offsetY = Random.Range(-alphaScale * 100, 100* alphaScale);
        RenderTexture.active = alphaBlendRenderTexture;
        alphaBlendTexture.ReadPixels(new Rect(0,0, alphaBlendRenderTexture.width, alphaBlendRenderTexture.height), 0, 0);
        for(float y = 0; y < alphaBlendRenderTexture.height; y++)
            for(float x = 0; x < alphaBlendRenderTexture.width; x++){
                float xCoord = (x + offsetX) / (float)alphaBlendRenderTexture.width * alphaScale;
                float yCoord = (y + offsetY) / (float)alphaBlendRenderTexture.height * alphaScale;
                float sample = Mathf.Max(0.01f, Mathf.PerlinNoise(xCoord, yCoord) + Mathf.PerlinNoise(xCoord * 2, yCoord * 2));
                sample = 0.9f;
                alphaBlendTexture.SetPixel((int)x, (int)y, new Color(sample, sample, sample));
            }
        alphaBlendTexture.Apply(); 
        RenderTexture.active = null;

        currentMaterial.SetTexture("_AlphaText", alphaBlendTexture);
    }
}
