using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Assets.PC
{
    public class Dissolve : MonoBehaviour
    {
        public int textureSize = 256;
        public float alphaScale = 1;
        private RenderTexture alphaBlendRenderTexture;
        private Texture2D alphaBlendTexture;
        private Material currentMaterial;
        private Action blendAction;

        [Range(0, 2)]
        public float mergeSpeed;
        private float clipValue = 0;
        private bool isVisible = true;


        public void Start()
        {
            currentMaterial = GetComponent<Renderer>().material;
            alphaBlendRenderTexture = new RenderTexture(textureSize, textureSize, 0, RenderTextureFormat.Default);
            alphaBlendRenderTexture.enableRandomWrite = true;
            alphaBlendRenderTexture.Create();
            alphaBlendTexture = new Texture2D(textureSize, textureSize);

            GenerateTexture();
        }

        private void Update()
        {
            if (Input.GetMouseButtonDown(0))
                Toogle();
            blendAction?.Invoke();
        }

        public void Toogle()
        {
            if (isVisible && clipValue <= 0)
            {
                blendAction += BlendAdd;
                isVisible = false;
                GenerateTexture();
            }
            else if (!isVisible && clipValue >= 1)
            {
                blendAction += BlendSubtract;
                isVisible = true;
                GenerateTexture();
            }
        }

        private void BlendSubtract()
        {
            if (clipValue <= 0)
            {
                blendAction -= BlendSubtract;
                return;
            }
            clipValue -= mergeSpeed * Time.deltaTime;
            currentMaterial.SetFloat("_MergeClipValue", clipValue);
        }

        private void BlendAdd()
        {
            if (clipValue >= 1)
            {
                blendAction -= BlendAdd;
                return;
            }
            clipValue += mergeSpeed * Time.deltaTime;
            currentMaterial.SetFloat("_MergeClipValue", clipValue);
        }

        private void GenerateTexture()
        {
            float offsetX = UnityEngine.Random.Range(-alphaScale * 100, 100 * alphaScale);
            float offsetY = UnityEngine.Random.Range(-alphaScale * 100, 100 * alphaScale);
            RenderTexture.active = alphaBlendRenderTexture;
            alphaBlendTexture.ReadPixels(new Rect(0, 0, alphaBlendRenderTexture.width, alphaBlendRenderTexture.height), 0, 0);
            for (float y = 0; y < alphaBlendRenderTexture.height; y++)
                for (float x = 0; x < alphaBlendRenderTexture.width; x++)
                {
                    float xCoord = (x + offsetX) / (float)alphaBlendRenderTexture.width * alphaScale;
                    float yCoord = (y + offsetY) / (float)alphaBlendRenderTexture.height * alphaScale;
                    float sample = Mathf.Max(0.01f, Mathf.PerlinNoise(xCoord, yCoord) * 0.5f + Mathf.PerlinNoise(xCoord * 0.5f, yCoord * 0.5f) * 0.5f);
                    alphaBlendTexture.SetPixel((int)x, (int)y, new Color(sample, sample, sample));
                }
            alphaBlendTexture.Apply();
            RenderTexture.active = null;

            currentMaterial.SetTexture("_AlphaText", alphaBlendTexture);
        }
    }
}
