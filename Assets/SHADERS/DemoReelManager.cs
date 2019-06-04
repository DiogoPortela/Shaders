using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DemoReelManager : MonoBehaviour
{
    public GameObject CardEffect;
    public GameObject BlobEffect;
    //ADD MORE EFFECTS HERE

    private GameObject currentEffect;



    private void Awake() {
        currentEffect = CardEffect;
    }
    void Update()
    {
        if(CheckEffect(KeyCode.Alpha1, CardEffect)) {}
        else if(CheckEffect(KeyCode.Alpha2, BlobEffect)) {}
        //else if(CheckEffect(KeyCode.Alpha3, ...)) {}

    }

    private bool CheckEffect(KeyCode key, GameObject effect){
        if(Input.GetKeyDown(key) && currentEffect != effect){
            currentEffect.SetActive(false);
            effect.SetActive(true);
            currentEffect = effect;
            return true;
        }
        return false;
    }
}
