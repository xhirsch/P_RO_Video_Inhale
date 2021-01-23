using UnityEngine;
using UnityEditor;


namespace DeckardRender
{
    public class DeckardRenderMenu : MonoBehaviour
    {
        //	private GameObject VRPano;
        [MenuItem("GameObject/Deckard/Deckard Render Physical Camera", false, 10)]
        static void CreateDeckardCameraObject(MenuCommand menuCommand)
        {


            GameObject VRPano = PrefabUtility.InstantiatePrefab(Resources.Load("Deckard Physical Camera")) as GameObject;
            VRPano.name = "Deckard Physical Camera";
            PrefabUtility.DisconnectPrefabInstance(VRPano);


            GameObjectUtility.SetParentAndAlign(VRPano, menuCommand.context as GameObject);


            Undo.RegisterCreatedObjectUndo(VRPano, "Create " + VRPano.name);
            Selection.activeObject = VRPano;
        }
    }
}

