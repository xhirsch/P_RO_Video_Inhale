using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProjectiorCustom : MonoBehaviour
{

    public Camera cam;
    public Material mat;

    // Update is called once per frame
    void Update()
    {
        mat.SetMatrix("_ProjectionMatrix", cam.projectionMatrix);
        mat.SetMatrix("_WorldToCameraMatrix", cam.worldToCameraMatrix);
    }
}
