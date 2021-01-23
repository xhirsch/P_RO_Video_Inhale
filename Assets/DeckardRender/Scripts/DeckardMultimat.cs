using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DeckardMultimat : MonoBehaviour {
    public Material[] materials;
    public Renderer renderer;
	// Use this for initialization
	void Awake () {
        renderer = GetComponent<Renderer>();
	}
}
