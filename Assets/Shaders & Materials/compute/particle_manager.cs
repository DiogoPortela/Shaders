using UnityEngine;

public class particle_manager : MonoBehaviour
{

    public ComputeShader shader;
    RenderTexture renderTexture;
    Renderer rend;
    public int resolution = 256;
    public int numParticles = 1000;
    public bool pause = true;

    struct particle
    {
        public Vector2 pos;
        public Vector2 dir;
        public Vector3 color;
        public float alive;
    };
    ComputeBuffer particleBuffer;

    void Start()
    {
        renderTexture = new RenderTexture(resolution, resolution, 24);
        renderTexture.enableRandomWrite = true;
        renderTexture.Create();

        particleBuffer = new ComputeBuffer(numParticles, sizeof(float) * 8, ComputeBufferType.Default);

        rend = GetComponent<Renderer>();
        rend.enabled = true;
    }

    void ResetShrug()
    {
        particle[] ps = new particle[numParticles];
        for (int i = 0; i < numParticles; i++)
        {
            particle p = new particle();

            p.pos = new Vector2(Random.Range(10, resolution - 10),
                                Random.Range(10, resolution - 10));
            p.dir = new Vector2(Random.Range(-50, 50),
                                Random.Range(-50, 50));
            Color c = Random.ColorHSV(0, 1, 0.5f, 1, 0.5f, 1);
            p.color = new Vector3(c.r, c.g, c.b);
            p.alive = 0f;

            ps[i] = p;
        }
        particleBuffer.SetData(ps);
    }

    void DispatchShrug()
    {
        int index = shader.FindKernel("CSMain");
        shader.SetTexture(index, "Result", renderTexture);
        shader.SetBuffer(index, "particleBuffer", particleBuffer);
        shader.SetFloat("time", Time.timeSinceLevelLoad);
        shader.SetFloat("deltatime", Time.deltaTime);
        shader.Dispatch(index, numParticles / 10, 1, 1);

        rend.material.SetTexture("_MainTex", renderTexture);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            pause = !pause;
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            ResetShrug();
        }
        if (!pause)
        {
            DispatchShrug();
        }
    }

    void OnDestroy()
	{
		renderTexture.Release();
		particleBuffer.Release();
	}
}
