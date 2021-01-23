using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GBuffers : MonoBehaviour
{

    public RenderTexture rt1;
    public RenderTexture rt2;
    public Material mat;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void LateUpdate()
    {
        Graphics.Blit(rt1, rt2, mat, -1);
    }
}
