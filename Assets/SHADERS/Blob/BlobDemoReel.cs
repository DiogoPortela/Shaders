using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlobDemoReel : MonoBehaviour
{
    BlobManager manager;  
    public int createQuanitity;
    public GameObject template;
    public Transform parent;

    // Start is called before the first frame update
    void Start()
    {
        manager = GetComponent<BlobManager>();

        List<Transform> data = new List<Transform>();
        for(int i = 0; i < createQuanitity; i++){
            var obj = Instantiate(template);
            obj.transform.SetParent(parent);
            obj.transform.localPosition = new Vector3(Random.Range(-0.5f, 0.5f), 0.1f,  Random.Range(-0.5f, 0.5f));
            obj.transform.localRotation = Quaternion.identity;
            obj.transform.localScale = Vector3.one * 0.02f;
            data.Add(obj.transform);
        }

        manager.SetObjects(data);
    }
}
