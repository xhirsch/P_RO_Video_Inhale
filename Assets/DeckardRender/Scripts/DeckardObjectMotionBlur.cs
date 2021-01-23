using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DeckardObjectMotionBlur : MonoBehaviour {

    
    public Vector3 pos;
    
    public Vector3 oldPos;
    
    public Quaternion rot;
    
    public Quaternion oldRot;

	// Use this for initialization
	void Start () {
        pos = gameObject.transform.position;
        oldPos = pos;
        rot = gameObject.transform.rotation;
        oldRot = rot;

    }

    // Update is called once per frame
    void LateUpdate()
    {
        pos = gameObject.transform.position;
        rot = gameObject.transform.rotation;
        
    }
}
