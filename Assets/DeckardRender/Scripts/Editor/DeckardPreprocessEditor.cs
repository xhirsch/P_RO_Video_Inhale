using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using System.IO;

namespace DeckardRender
{
    [CustomEditor(typeof(DeckardPreprocess))]
    public class DeckardPreprocessEditor : Editor
    {



        // Use this for initialization




        public override void OnInspectorGUI()
        {



            DeckardPreprocess VRP = (DeckardPreprocess)target;

            GUILayout.BeginVertical("box");
            GUILayout.Label("WARNING! Place all image effects between ");
            GUILayout.Label("Deckard Preprocess and Deckard Render script");

            GUILayout.EndVertical();
        }
    }
}
