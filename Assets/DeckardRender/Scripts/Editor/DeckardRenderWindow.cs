using UnityEditor;
using UnityEngine;
using DeckardRender;
using System.Collections;

namespace DeckardRender
{
    public class DeckardRenderWindow : EditorWindow
    {
        
        bool groupEnabled;
        bool myBool = true;
        float myFloat = 1.23f;
        public DeckardRender deckardRenderComponent;
        public bool mouseMoved = false;
        public float zoom = 1f;
        public Vector2 mousePos = new Vector2(0f, 20f);
        public Vector2 finalMousePos = new Vector2(0f, 0f);
        public Vector2 delta;
        public Texture2D smpte;

        // Add menu item named "My Window" to the Window menu
        [MenuItem("Deckard Render/Deckard View")]



            public static void ShowWindow()
        {
            //Show existing window instance. If one doesn't exist, make one.
            EditorWindow.GetWindow(typeof(DeckardRenderWindow));
            //   DeckardRenderWindow window = (DeckardRenderWindow)EditorWindow.GetWindow(typeof(DeckardRenderWindow));
            

        }




        private void OnDestroy()
        {
            DeckardRender.active = false;
        }
        public void OnGUI()
        {
            
            if (Event.current.type == EventType.MouseMove) mouseMoved = false;
            else mouseMoved = true;

            //  GUILayout.Box(Shader.GetGlobalTexture("_AperturePass"), GUILayout.ExpandWidth(true));
            if (deckardRenderComponent != null && deckardRenderComponent.rtDW != null)
            {
                EditorGUILayout.BeginVertical(GUILayout.ExpandHeight(true));
                //   GUILayout.Box(deckardRenderComponent.rtDW);

                Event e = Event.current;


                if (e.button == 0 && e.isMouse)
                {
                    if (e.mousePosition.y <= position.height - 36 && e.mousePosition.y > 36)
                    {
                        mousePos += delta;
                        delta = Vector2.zero;
                    }

                }



                if (e.type == EventType.MouseDrag)
                {
                    delta = e.delta;
                    // delta.y *= -1;  // GUI is y inverted
                }


                Vector2 finalPos = finalMousePos;

                EditorGUI.DrawPreviewTexture(new Rect(mousePos.x, mousePos.y, deckardRenderComponent.rtDW.width * zoom, deckardRenderComponent.rtDW.height * zoom), deckardRenderComponent.rtDW);


                EditorGUILayout.BeginHorizontal(GUILayout.Width(300));


                zoom = EditorGUILayout.Slider(new GUIContent("Scale", "Scale viewport."), zoom, 0.1f, 10f);
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.EndVertical();


                EditorGUILayout.BeginVertical();
                EditorGUILayout.BeginHorizontal(GUILayout.Width(300));
                deckardRenderComponent.batchGroups = EditorGUILayout.IntSlider(new GUIContent("Batch Groups", "This value defines responsivness in editor mode. Greater value gives faster rendering of Deckard View, while smaller values give better response to Unity Interface."), deckardRenderComponent.batchGroups, 1, deckardRenderComponent.maxInteractiveSteps);
                EditorGUILayout.EndHorizontal();

                //     myBool = EditorGUILayout.Toggle("Interactive Render", myBool);
                if (myBool && !EditorApplication.isPlaying) DeckardRender.active = true;
                else DeckardRender.active = false;

                EditorGUILayout.EndVertical();
                if (deckardRenderComponent.optimizedSpeedRendering)
                {
                    EditorGUI.ProgressBar(new Rect(3, 3, position.width - 6, 2), (DeckardRender.curentOptimizedSteps + 0f) / (deckardRenderComponent.finalSteps * 2f), " ");
                }
                else EditorGUI.ProgressBar(new Rect(3, 3, position.width - 6, 2), (DeckardRender.curentOptimizedSteps + 0f) / (deckardRenderComponent.maxInteractiveSteps * 1f), " ");
                UnityEditorInternal.InternalEditorUtility.RepaintAllViews();
            }

            else
            {
                if (smpte == null)
                    smpte = Resources.Load("testPatternSMPTE") as Texture2D;
                EditorGUI.DrawPreviewTexture(new Rect(mousePos.x, mousePos.y, smpte.width * zoom, smpte.height * zoom), smpte);
                UnityEditorInternal.InternalEditorUtility.RepaintAllViews();

                EditorGUILayout.BeginHorizontal(GUILayout.Width(300));


                zoom = EditorGUILayout.Slider(new GUIContent("Scale", "Scale viewport."), zoom, 0.1f, 10f);
                EditorGUILayout.EndHorizontal();
            }
        }


        public void Update()
        {
            // This is necessary to make the framerate normal for the editor window.
            Repaint();

            if (deckardRenderComponent == null)
            {
                deckardRenderComponent = FindObjectOfType<DeckardRender>();
            }
            //   Debug.Log(deckardRenderComponent +" "+ deckardRenderComponent.active);
        }

        public void OnMouseDrag()
        {
            mousePos += delta;
            Debug.Log(mousePos);
            // This is necessary since the EventType.MouseDrag event in OnGUI
            // is only fired when the mouse moves, so the delta is never 0
            delta = Vector2.zero;
        }
    }
}

