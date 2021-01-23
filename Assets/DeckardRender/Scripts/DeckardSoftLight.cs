using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DeckardRender;
using UnityEditor;

[ExecuteInEditMode]
[RequireComponent(typeof(Light))]
public class DeckardSoftLight : MonoBehaviour
{


    [HideInInspector]
    public Vector3 lightPos;
    [HideInInspector]
    public Quaternion lightRot;
    public Vector2 lightSize = new Vector2(0.1f, 0.1f);
    [HideInInspector]
    public Light lightL;
    // public bool AOLight = false;
    public float shadowBias;
    public float normalBias;
    public Color lightColor;
    public MeshFilter mFilter;
    public MeshRenderer mRenderer;
    public bool AddLightMesh = true;
    public Material lightMat;
    public Mesh lightShape;
    public MaterialPropertyBlock propBlock;
    public float deckardShadowBias = 0f;
    public float deckardNormalBias;
    public Mesh mesh;






    // Use this for initialization
    void Start()
    {
        lightL = gameObject.GetComponent<Light>();
        shadowBias = lightL.shadowBias;
        normalBias = lightL.shadowNormalBias;
        lightPos = gameObject.transform.position;
        lightRot = gameObject.transform.rotation;
        if (AddLightMesh)
        {
            if (mRenderer == null)
            {
                if (gameObject.GetComponent<MeshRenderer>() == null)
                {
                    mRenderer = gameObject.AddComponent<MeshRenderer>();
                    lightMat.SetColor(" _EmissionColor", lightColor);
                }
            }
            if (mFilter == null)
            {
                if (gameObject.GetComponent<MeshFilter>() == null)
                {
                    mFilter = gameObject.AddComponent<MeshFilter>();
                    lightShape = Resources.Load("DeckardLightCookie.asset") as Mesh;
                    mFilter.mesh = lightShape;
                }
            }
        }

        propBlock = new MaterialPropertyBlock();

    }

    // Update is called once per frame
    //private void OnDrawGizmos()
    //{
    //    Gizmos.DrawMesh(mesh);
    //    Gizmos.color = Color.yellow;
    //    Gizmos.DrawWireCube(transform.position, new Vector3(lightSize.x, 0.02f, lightSize.y));

    //}
    private void Update()
    {

        lightColor = lightL.color;

        if (AddLightMesh && lightL.type == LightType.Spot)
        {
            if (mRenderer == null)
            {
                mRenderer = gameObject.AddComponent<MeshRenderer>();
                lightMat.SetColor(" _EmissionColor", lightColor);
            }
            if (mFilter == null)
            {
                mFilter = gameObject.AddComponent<MeshFilter>();
                lightMat = Resources.Load("Deckard_DeckardCookie") as Material;
                lightShape = Resources.Load("DeckardLightCookie") as Mesh;
                mRenderer.material = lightMat;

                mFilter.mesh = lightShape;


            }
            if (propBlock == null)
            {
                propBlock = new MaterialPropertyBlock();
                mRenderer.SetPropertyBlock(propBlock);
            }

            propBlock.SetColor("_DeckardLightColor", lightColor);
            propBlock.SetVector("_DeckardLightScale", new Vector4(lightSize.x, lightSize.y, 0f, 0f));
            propBlock.SetFloat("_DeckardLightIntenisty", lightL.intensity);
            propBlock.SetVector("_DeckardLightOffset", lightPos);
            mRenderer.SetPropertyBlock(propBlock);
            if (mRenderer.shadowCastingMode == UnityEngine.Rendering.ShadowCastingMode.On || mRenderer.shadowCastingMode == UnityEngine.Rendering.ShadowCastingMode.TwoSided) mRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        }
        else
        {
            if (mRenderer != null)
                DestroyImmediate(mRenderer);
            if (mFilter != null)
                DestroyImmediate(mFilter);
        }


    }
    void LateUpdate()
    {
        if (lightL == null) lightL = gameObject.GetComponent<Light>();
        lightPos = gameObject.transform.position;
        lightRot = gameObject.transform.rotation;
    }
    private void OnDestroy()
    {
        lightL.shadowBias = shadowBias;
        lightL.shadowNormalBias = normalBias;
    }
    public void SetBias()
    {
        shadowBias = lightL.shadowBias;
        normalBias = lightL.shadowNormalBias;
        lightL.shadowBias = deckardShadowBias;
        lightL.shadowNormalBias = deckardNormalBias;
    }

    public void RestoreBias()
    {
        lightL.shadowBias = shadowBias;
        lightL.shadowNormalBias = normalBias;
    }




}




//[CustomEditor(typeof(DeckardSoftLight))]
//public class DeckardSoftLightEditor : Editor
//{
//    public override void OnInspectorGUI()
//    {
//        DeckardSoftLight VRP = (DeckardSoftLight)target;
//        VRP.lightSize.x = EditorGUILayout.FloatField(new GUIContent("Light Width", "Light width"), VRP.lightSize.x);
//        VRP.lightSize.y = EditorGUILayout.FloatField(new GUIContent("Light Height", "Light width"), VRP.lightSize.y);
//    }



//    void OnSceneGUI()
//    {
//        DeckardSoftLight t = (DeckardSoftLight)target;
//        Vector3 pos = t.transform.position;
//        Quaternion rotation = t.gameObject.transform.rotation;


//        if (Event.current.type == EventType.Repaint)
//        {
//            Handles.color = Color.red;



//            Vector3[] verts = new Vector3[] {
//            rotation * new Vector3 (pos.x - t.lightSize.x, pos.y, pos.z - t.lightSize.x),
//            rotation * new Vector3(pos.x - t.lightSize.x, pos.y, pos.z + t.lightSize.x),
//            rotation * new Vector3(pos.x + t.lightSize.x, pos.y, pos.z + t.lightSize.x),
//            rotation * new Vector3(pos.x + t.lightSize.x, pos.y, pos.z - t.lightSize.x)
//             };

//            Handles.DrawSolidRectangleWithOutline(verts, new Color(0.5f, 0.5f, 0.5f, 0.1f), new Color(0, 0, 0, 1));

//            foreach (Vector3 posCube in verts)
//            {
//                t.lightSize.x = Handles.ScaleValueHandle(t.lightSize.x,
//                    posCube,
//                    Quaternion.identity,
//                    1.0f,
//                    Handles.CubeHandleCap,
//                    1.0f);
//            }

//        }
//    }

//}

