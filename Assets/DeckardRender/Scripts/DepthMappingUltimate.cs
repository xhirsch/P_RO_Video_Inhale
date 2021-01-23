using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthMappingUltimate : MonoBehaviour {
    public GameObject quad;
    public int iterations = 256;
    public float scale = 1;
	// Use this for initialization
	void Start () {
        for (int i = 0; i < iterations; i++)
        {
            GameObject go = Instantiate<GameObject>(quad);
            go.transform.Translate(new Vector3(0, 0, (1.0f / iterations) * i));
            float scaleMe = i * scale;
            go.transform.localScale = (new Vector3(scaleMe, scaleMe, scaleMe));

        }
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
