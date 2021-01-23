using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Video;
using UnityEngine.Playables;
using UnityEditor;

[ExecuteInEditMode]
public class VideoScrubber : MonoBehaviour
{
    public VideoPlayer videoPlayer;
    public float position;
    public int fps = 25;
    public float scrubTime = 0;
    public int scrubFrame;
    public PlayableDirector timeline;
    public double time;
    public double currentTime;


    // Start is called before the first frame update
    void Start()
    {



            videoPlayer.playbackSpeed = 0;
            videoPlayer.skipOnDrop = true;

    }

    // Update is called once per frame
    void Update()
    {
        
            if (timeline)
            {
                scrubTime = (float)timeline.time;
                scrubFrame = Mathf.FloorToInt(scrubTime * fps);
            }

            if (videoPlayer)
            {
                videoPlayer.playbackSpeed = 0;
                //  SkipToPercent(position);
                SkipToFrame(scrubFrame);
               //   SkipToTime(scrubTime);
                videoPlayer.Play();



            }
     //   Debug.Log(videoPlayer.frameCount);
        
    }
    private void SkipToPercent(float percent)
    {
        var frame = (videoPlayer.frameCount) * percent;
        videoPlayer.frame = (long)frame;
    }

    private void SkipToFrame(int frame)
    {
        videoPlayer.frame = (long)frame;
       // Debug.Log(videoPlayer.frame);
    }

    private void SkipToTime(float time)
    {
        videoPlayer.time = (long)time;
    }

    IEnumerator SyncVideo()
    {
        while (true)
        {
            yield return new WaitForEndOfFrame();
            videoPlayer.StepForward();
            videoPlayer.Pause();

            //currentTime = gameObject.GetComponent<VideoPlayer>().time;
            //if (currentTime >= time)
            //{
            //    videoPlayer.time = 0;
            //   // videoPlayer.Pause();
            //}
        }
    }
}
