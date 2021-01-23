using System;
using UnityEngine;
using DeckardRender;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]

public class DeckardBloom : MonoBehaviour
{

    public Material material;
    public Material depthMat;
    public static RenderTexture rt;
    public static RenderTexture rt2;
    void Awake()
    {
        //   material = Resources.Load("Deckard_PreProcess", typeof(Material)) as Material;
        //  depthMat = Resources.Load("Deckard_depthBuffer", typeof(Material)) as Material;

    }

    void Start()
    {
        if (material == null) material = Resources.Load("Deckard_BlurHQ", typeof(Material)) as Material;
        if (depthMat == null) depthMat = Resources.Load("Deckard_InternalEffects_CompositeBlur", typeof(Material)) as Material;

        if (!SystemInfo.supportsImageEffects || null == material ||
           null == material.shader || !material.shader.isSupported)
        {
            enabled = false;
            return;
        }
        if (rt == null) rt = RenderTexture.GetTemporary(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
        //  Shader.SetGlobalTexture("_DeckardDepth", rt);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {

        if (rt == null) rt = RenderTexture.GetTemporary(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
        if (rt2 == null) rt2 = RenderTexture.GetTemporary(Screen.width / 4, Screen.height / 4, 0, RenderTextureFormat.ARGBFloat);
        Shader.SetGlobalTexture("_DeckardBlurRT", rt2);

        material.SetVector("_blurOffset", new Vector4(0.004f, 0, 0, 0));
        Graphics.Blit(source, rt, material);
        material.SetVector("_blurOffset", new Vector4(0, 0.004f, 0, 0));
        Graphics.Blit(rt, rt2, material);

        material.SetVector("_blurOffset", new Vector4(0.006f, -0.006f, 0, 0));
        Graphics.Blit(rt2, rt, material);
        material.SetVector("_blurOffset", new Vector4(-0.006f, 0.006f, 0, 0));
        Graphics.Blit(rt, rt2, material);

        material.SetVector("_blurOffset", new Vector4(-0.006f, 0, 0, 0));
        Graphics.Blit(rt2, rt, material);
        material.SetVector("_blurOffset", new Vector4(0, -0.006f, 0, 0));
        Graphics.Blit(rt, rt2, material);

        Graphics.Blit(source, destination, depthMat);


    }



}

