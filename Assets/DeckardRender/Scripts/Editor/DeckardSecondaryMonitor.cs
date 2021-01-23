using UnityEngine;
using UnityEditor;
using DeckardRender;
using System.Collections;

namespace DeckardRender
{
    public class DeckardSecondaryMonitor : EditorWindow
    {

        bool groupEnabled;
        bool myBool = true;
        float myFloat = 1.23f;
        public DeckardRender deckardRenderComponent;
        public bool mouseMoved = false;
        public float zoom = 1f;
        public Vector2 mousePos = new Vector2(0f, 0f);
        public Vector2 finalMousePos = new Vector2(0f, 0f);
        public Vector2 delta;
        public Texture2D smpte;
        static bool active = true;
        static Vector2 monitorRes;


        [MenuItem("Deckard Render/Secondary Monitor Display")]
        public static void Init()
        {
            if (PlayerPrefs.HasKey("MonitorRes_W"))
            {
                monitorRes.x = PlayerPrefs.GetInt("MonitorRes_W");
                monitorRes.y = PlayerPrefs.GetInt("MonitorRes_H");
                
            }
            else {
                monitorRes = new Vector2(1920, 1080);
            }
            Debug.Log(Display.displays[0].systemWidth + " " + Display.displays[0].systemHeight);

            DeckardSecondaryMonitor window = ScriptableObject.CreateInstance<DeckardSecondaryMonitor>();
            window.position = new Rect(-monitorRes.x, 0, monitorRes.x, monitorRes.y);
            window.ShowPopup();
        }

        void OnGUI()
        {
           EditorGUILayout.LabelField("Fullscreen Preview.ShowPopup", EditorStyles.wordWrappedLabel);
            //  GUILayout.Space(70);

            if (deckardRenderComponent != null && deckardRenderComponent.rtDW != null)
            {
                EditorGUI.DrawPreviewTexture(new Rect(0, 0, monitorRes.x, monitorRes.y), deckardRenderComponent.rtDW);
            }
            else
            {
                if (smpte == null)

                    smpte = Resources.Load("testPatternSMPTE") as Texture2D;
                EditorGUI.DrawPreviewTexture(new Rect(0, 0, monitorRes.x, monitorRes.y), smpte);
                UnityEditorInternal.InternalEditorUtility.RepaintAllViews();
            }

         //   if (GUILayout.Button("Turn Off Monitor View")) this.Close();

            Event e = Event.current;


                if (e.mousePosition.y < 64 && e.mousePosition.x < monitorRes.x)
                {
                    if (GUILayout.Button("Turn Off Monitor View")) this.Close();
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
