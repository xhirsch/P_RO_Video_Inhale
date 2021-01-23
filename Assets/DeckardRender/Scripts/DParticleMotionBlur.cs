using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


public class DParticleMotionBlur : MonoBehaviour
{
    public ParticleSystem ps;

    float[] simulationTimes;

    public float time;
    public float oldTime;
#if UNITY_EDITOR
    void Initialize()
    {
        ps = gameObject.GetComponent<ParticleSystem>();
        oldTime = Time.time;

    }

    void OnEnable()
    {
        if (ps == null)
        {
            Initialize();
        }
#if UNITY_EDITOR
        if (EditorApplication.isPlaying)
        {
            ps.Simulate(time, true, false, true);
        }
#endif
    }
    public void Update()
    {
        if (EditorApplication.isPlaying)
        {
            ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            bool useAutoRandomSeed = ps.useAutoRandomSeed;
            ps.useAutoRandomSeed = false;

            ps.Play(false);
            float currentSimulationTime = time - oldTime;

            ps.Simulate(currentSimulationTime, false, false, true);
            ps.useAutoRandomSeed = useAutoRandomSeed;

            //if (currentSimulationTime < 0.0f)
            //{
            //    particleSystems[i].Play(false);
            //    particleSystems[i].Stop(false, ParticleSystemStopBehavior.StopEmittingAndClear);
            //}
        }

    }
#endif
}
