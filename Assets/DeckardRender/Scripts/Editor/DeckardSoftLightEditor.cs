using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;

namespace DeckardRender
{
    [CustomEditor(typeof(DeckardSoftLight))]

    public class DeckardSoftLightEditor : Editor
    {

        public float size = 0.1f;

        // Use this for initialization




        public override void OnInspectorGUI()
        {



            DeckardSoftLight VRP = (DeckardSoftLight)target;

            GUILayout.BeginVertical("box");
            VRP.lightSize = EditorGUILayout.Vector2Field("Light Size", VRP.lightSize);
            if (VRP.lightL.type == LightType.Spot)
                VRP.AddLightMesh = EditorGUILayout.Toggle("Add Light Mesh", VRP.AddLightMesh);
            else VRP.AddLightMesh = false;

            VRP.deckardShadowBias = EditorGUILayout.FloatField("Deckard Shadow Bias", VRP.deckardShadowBias);

            if (GUI.changed)
            {
                EditorUtility.SetDirty(VRP);
#if UNITY_5_4_OR_NEWER
                EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
#endif
                DeckardRender.editorInteractiveChange = true;

            }
            if (!GUI.changed)
            {
                DeckardRender.editorInteractiveChange = false;

            }


            GUILayout.EndVertical();
        }

        void OnSceneGUI()
        {
            DeckardSoftLight t = (DeckardSoftLight)target;
            Vector3 pos = t.transform.position;
            Quaternion rot = t.transform.localRotation;

            Vector3[] verts = new Vector3[]
            {
            rot * (new Vector3(pos.x - t.lightSize.x/2f, pos.y - t.lightSize.y/2f, pos.z) - pos) + pos,
            rot * (new Vector3(pos.x - t.lightSize.x/2f, pos.y  + t.lightSize.y/2f, pos.z) - pos) + pos,
            rot * (new Vector3(pos.x + t.lightSize.x/2f, pos.y + t.lightSize.y/2f, pos.z ) -pos) + pos,
            rot * (new Vector3(pos.x + t.lightSize.x/2f, pos.y  - t.lightSize.y/2f, pos.z) - pos) + pos
            };

            Handles.DrawSolidRectangleWithOutline(verts, new Color(0.5f, 0.5f, 0.5f, 0.1f), new Color(0, 0, 0, 1));

            foreach (Vector3 posCube in verts)
            {
                t.lightSize.x = Handles.ScaleValueHandle(t.lightSize.x,
                    posCube,
                    Quaternion.identity,
                    1.0f,
                    Handles.CubeHandleCap,
                    1.0f);
            }
        }
    }

}

