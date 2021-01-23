using System;
using UnityEngine;
using DeckardRender;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]

public class DeckardPreprocess : MonoBehaviour
{

    public Material material;
    public Material depthMat;
    public RenderTexture rt;
    void Awake()
    {
        material = Resources.Load("Deckard_PreProcess", typeof(Material)) as Material;
        depthMat = Resources.Load("Deckard_depthBuffer", typeof(Material)) as Material;

    }

    void Start()
    {
        if (material == null) material = Resources.Load("Deckard_PreProcess", typeof(Material)) as Material;
        if (depthMat == null) depthMat = Resources.Load("Deckard_depthBuffer", typeof(Material)) as Material;

        if (!SystemInfo.supportsImageEffects || null == material ||
           null == material.shader || !material.shader.isSupported)
        {
            enabled = false;
            return;
        }
        if (rt == null) rt = RenderTexture.GetTemporary(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
        Shader.SetGlobalTexture("_DeckardDepth", rt);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, rt, depthMat);

        Graphics.Blit(source, destination, material);
    }

    void OnDisable()
    {
        rt.Release();
    }

    void OnDestroy()
    {
        rt.Release();
    }
}
