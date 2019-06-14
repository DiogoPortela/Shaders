using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlobDemoReel : MonoBehaviour
{
    BlobManager manager;  
    public int createQuanitity;
    public GameObject template;
    public Transform parent;
    private List<GameObject> spawnedObjs;

    // Start is called before the first frame update
    void Start()
    {
        manager = GetComponent<BlobManager>();

        spawnedObjs = new List<GameObject>();
        Generate();
    }

    private void Update() {
        if(Input.GetMouseButtonDown(0)){
            Generate();
        }
    }

    private void Generate(){
        if(spawnedObjs.Count > 0){
            foreach (var o in spawnedObjs)
            {
                Destroy(o);
            }
            spawnedObjs.Clear();
        }

        List<Transform> data = new List<Transform>();
        for(int i = 0; i < createQuanitity; i++){
            var obj = Instantiate(template);
            obj.transform.SetParent(parent);
            obj.transform.localPosition = new Vector3(Random.Range(-1.9f, 1.9f), 0.02f,  Random.Range(-1.9f, 1.9f));
            obj.transform.localRotation = Quaternion.identity;
            obj.transform.localScale = Vector3.one * 0.02f;
            spawnedObjs.Add(obj);

            //if(Random.Range(0, 100) > 75){
            data.Add(obj.transform);
            //}
        }

        manager.SetObjects(data);
    }
}
