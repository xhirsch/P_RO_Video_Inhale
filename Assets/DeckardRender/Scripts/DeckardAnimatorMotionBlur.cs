using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class DeckardAnimatorMotionBlur : MonoBehaviour
{
    
    public Animator animator;
    
    public float animatorTime;
    
    public float oldAnimatorTime;



    // Use this for initialization
    private void Awake()
    {
        animator = gameObject.GetComponent<Animator>();
    }
    void Start()
    {
        
    }

    // Update is called once per frame
    public void LateUpdate()
    {

    }




    public void jumpToTime(string name, float nTime)
    {
        animator.Play(name, 0, nTime);
        animator.StartPlayback();
    }

    public string currentAnimationName()

    {
        var currAnimName = "";
        foreach (AnimationClip clip in animator.runtimeAnimatorController.animationClips)
        {
            if (animator.GetCurrentAnimatorStateInfo(0).IsName(clip.name))
            {
                currAnimName = clip.name.ToString();
            }
        }

        return currAnimName;

    }
}

