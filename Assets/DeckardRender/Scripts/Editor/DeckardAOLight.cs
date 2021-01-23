using UnityEngine;
using UnityEditor;


namespace DeckardRender
{
    public class DeckardAOLight : MonoBehaviour
    {
        //	private GameObject VRPano;
        [MenuItem("GameObject/Deckard/Deckard Outdoor Ambient Light", false, 10)]
        static void CreateDeckardCameraObject(MenuCommand menuCommand)
        {


            GameObject VRPano = PrefabUtility.InstantiatePrefab(Resources.Load("Deckard_AO_Light")) as GameObject;
            VRPano.name = "Deckard Ambient Light";
            PrefabUtility.DisconnectPrefabInstance(VRPano);


            GameObjectUtility.SetParentAndAlign(VRPano, menuCommand.context as GameObject);


            Undo.RegisterCreatedObjectUndo(VRPano, "Create " + VRPano.name);
            Selection.activeObject = VRPano;
        }
    }
}
