using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using System.IO;
using UnityEngine.Playables;

namespace DeckardRender
{
    [CustomEditor(typeof(DeckardRender))]
    public class DeckardRenderEditor : Editor
    {
        private Texture banner;
        private GUILayoutOption[] style;
        public float fDistance;



        // Use this for initialization

        void OnEnable()
        {
            banner = Resources.Load("DeckardHeader") as Texture;
        }


        public override void OnInspectorGUI()
        {

            EditorGUI.BeginChangeCheck();

            DeckardRender VRP = (DeckardRender)target;
            if (PlayerSettings.colorSpace == ColorSpace.Gamma)
            {
                GUILayout.BeginVertical("box");
                GUILayout.Label("WARNING! For best visual appearance");
                GUILayout.Label("switch Your project to Linear Color Space");
                if (GUILayout.Button("OK! Switch!"))
                {
                    PlayerSettings.colorSpace = ColorSpace.Linear;
                }
                GUILayout.EndVertical();
            }




            if (VRP.ImageFormatType == DeckardRender.VRFormatList.JPG)
            {
                VRP.formatString = ".jpg\"";

            }

            else if (VRP.ImageFormatType == DeckardRender.VRFormatList.PNG)
            {
                VRP.formatString = ".png\"";

            }

            else
            {
                VRP.formatString = ".exr\"";

            }


            VRP.fullPath = Path.GetFullPath(string.Format(@"{0}/", VRP.Folder));


            GUILayout.Box(banner, GUILayout.ExpandWidth(true));

            if (!VRP.cam.allowHDR || VRP.cam.renderingPath == RenderingPath.Forward || VRP.cam.renderingPath == RenderingPath.UsePlayerSettings)
            {
                if (!VRP.usingHDRP)
                {
                    GUILayout.Label("For best appearance");
                    GUILayout.Label("switch your camera to Deferred HDR Rendering");
                    if (GUILayout.Button("OK, switch it"))
                    {
                        VRP.cam.renderingPath = RenderingPath.DeferredShading;
                        VRP.cam.allowHDR = true;
                        VRP.cam.allowMSAA = false;
                    }

                    if (GUILayout.Button("Don't switch, I'm using HDRP"))
                    {
                        VRP.usingHDRP = true;
                    }
                }
            }

            //  GUILayout.BeginVertical();
#if UNITY_EDITOR_WIN
            if (!System.IO.File.Exists(Application.dataPath + "/DeckardRender/StreamingAssets/ffmpeg.exe"))
            {
                GUILayout.Label("For correct functioning, VR Panorama requires FFMPEG");
                GUILayout.Label("to be placed in Assetes/DeckardRender/StreamingAssets");
                GUILayout.Label("Download FFMPEG package by going to:");
                if (GUILayout.Button("Download FFMPEG"))
                {
                    Application.OpenURL("https://www.dropbox.com/s/7z7ivsydt5waa95/FFMPEG_Custom.unitypackage?dl=0");
                }
                GUILayout.Label("Please read Install_Readme file");
            }

#endif

#if UNITY_EDITOR_OSX
            if (!System.IO.File.Exists(Application.dataPath + "/DeckardRender/StreamingAssets/ffmpeg"))
            {
                GUILayout.Label("For corect functioning, VR Panorama requires FFMPEG");
            GUILayout.Label("to be placed in Assetes/DeckardRender/StreamingAssets");
                GUILayout.Label("Download FFMPEG package by going to:");
                if (GUILayout.Button("Download FFMPEG"))
                {
                    Application.OpenURL("https://www.dropbox.com/s/7z7ivsydt5waa95/FFMPEG_Custom.unitypackage?dl=0");
                }
                GUILayout.Label("Please read Install_Readme file");
            }

# endif
            //VRP.active = EditorGUILayout.Toggle("Use Deckard Render", VRP.active);
            if (GUILayout.Button("Open Deckard View"))
            {
                EditorApplication.ExecuteMenuItem("Deckard Render/Deckard View");
            }




            EditorGUILayout.LabelField("Render", GUI.skin.horizontalSlider);
            VRP.roll1 = EditorGUILayout.Foldout(VRP.roll1, new GUIContent("PHYSICAL CAMERA CONTROL", "Here you can set Physical Modelling and Syntetic Aperture properties for Deckard camera."), true);
            if (VRP.roll1)
            {
                VRP.cam.fieldOfView = EditorGUILayout.Slider("Focal length: " + (Mathf.Floor(VRP.focalmm)) + "mm", VRP.cam.fieldOfView, 1f, 179f);
                VRP.fStop = EditorGUILayout.Slider("Aperture: " + "f/" + (VRP.focalmm / (DeckardRender.irisRadius * 2f * 1000f)), VRP.fStop, 0.6f, 32f);
                VRP.focusDistance = EditorGUILayout.FloatField("Focal Distance", VRP.focusDistance);
                if (VRP.focusDistance < 0.1f) VRP.focusDistance = 0.1f;
                VRP.focusTest = EditorGUILayout.Toggle("Show focus fields", VRP.focusTest);
                VRP.focusAssist = EditorGUILayout.Toggle("Show focus peaking", VRP.focusAssist);



                VRP.useAutoFocus = EditorGUILayout.Toggle("Use Auto Focus", VRP.useAutoFocus);
                if (!VRP.useAutoFocus)
                {
                    VRP.focusTransform = EditorGUILayout.ObjectField("Focus on ", VRP.focusTransform, typeof(Transform), true) as Transform;
                    if (VRP.focusTransform != null)
                        VRP.focusSpeed = EditorGUILayout.Slider("Focus Speed", VRP.focusSpeed, 0.0001f, 1f);
                }


                else VRP.focusSpeed = EditorGUILayout.Slider("Focus Speed", VRP.focusSpeed, 0.0001f, 1f);

                VRP.customProjectionPlane = EditorGUILayout.Toggle("Custom Projection Plane", VRP.customProjectionPlane);
                if (VRP.customProjectionPlane)
                    VRP.projectionScreen = EditorGUILayout.ObjectField("Focus on projection plane", VRP.projectionScreen, typeof(GameObject), true) as GameObject;
                VRP.enumFilmSize = (DeckardRender.FilmSize)EditorGUILayout.EnumPopup(new GUIContent("Sensor Size", "Set sensor size for your camera"), VRP.enumFilmSize);
                if (VRP.enumFilmSize != VRP.OldEnumFilmSize)
                {
                    VRP.LoadFilmSize();
                    VRP.OldEnumFilmSize = VRP.enumFilmSize;
                }
                if (VRP.enumFilmSize == DeckardRender.FilmSize.Custom)
                {
                    VRP.customFilmSize = EditorGUILayout.FloatField("CustomF sensor size", VRP.customFilmSize);
                    VRP.LoadFilmSize();
                }
                VRP.anamorphicRatio = EditorGUILayout.Slider("Anamorphic ratio", VRP.anamorphicRatio, 0.5f, 1f);

                VRP.tiltShift = EditorGUILayout.Slider("Tilt Shift", VRP.tiltShift, 1f, 6f);
                VRP.lensVignetteBlur = EditorGUILayout.Slider("Lense Vinette Blur", VRP.lensVignetteBlur, 0f, 1.5f);
                VRP.bokehBlades = EditorGUILayout.IntSlider("Blades Count", VRP.bokehBlades, 5, 9);
                VRP.bladeCurvature = EditorGUILayout.Slider("Blades Curvature", VRP.bladeCurvature, 0.8f, 1.0f);
                VRP.bokehFill = EditorGUILayout.Slider("Bokeh Fill", VRP.bokehFill, 0f, 1.0f);
                VRP.filmResponseType = (DeckardRender.FilmResponseType)EditorGUILayout.EnumPopup(new GUIContent("Film Response Type", "Here you can select Color Science for your video. This list uses some of the most used film processes and cameras in film industry"), VRP.filmResponseType);



                if (VRP.filmResponseType != VRP.oldFilmResponseType)
                {
                    VRP.LoadLUT();
                    VRP.oldFilmResponseType = VRP.filmResponseType;
                }






                VRP.filmResponseInfluence = EditorGUILayout.Slider("Film color amount", VRP.filmResponseInfluence, 0f, 1f);
                VRP.shutterAngle = EditorGUILayout.Slider("Shutter Angle", VRP.shutterAngle, 0, 360);
                if (!VRP.usingHDRP)
                {

                    VRP.exposure = EditorGUILayout.Slider("Exposure", VRP.exposure, 0, 10f);



                }
                VRP.zebras = EditorGUILayout.Toggle("Show Zebras", VRP.zebras);
                VRP.whiteBallance = EditorGUILayout.Slider("White Ballance", VRP.whiteBallance, -1f, 1f);
                VRP.filmTint = EditorGUILayout.Slider("Film Tint", VRP.filmTint, -1f, 1f);
                VRP.saturation = EditorGUILayout.Slider("Saturation", VRP.saturation, 0f, 2f);


                VRP.noise = EditorGUILayout.Slider("Noise: film/digital", VRP.noise, -0.5f, 0.5f);

                VRP.sharpen = EditorGUILayout.Slider("Post Sharpen", VRP.sharpen, 0f, 2f);
                VRP.sharpenRadius = EditorGUILayout.Slider("Sharpen Radius", VRP.sharpenRadius, 0f, 2f);
                //   VRP.noise = EditorGUILayout.Slider("Filmic Noise", VRP.noise, 0f, 2f);

                VRP.letterbox = EditorGUILayout.Slider("Letterbox", VRP.letterbox, 0f, 1f);

                //VRP.bloomIntensity = EditorGUILayout.Slider("Bloom Intenisty", VRP.bloomIntensity, 0f, 10f);
                //VRP.bloomRadius = EditorGUILayout.Slider("Bloom Radius", VRP.bloomRadius, 0f, 0.02f);

            }


            //if (VRP.ImageFormatType == DeckardRender.VRFormatList.JPG)
            //{
            //    VRP.jpgQuality = EditorGUILayout.IntSlider("JPG Quality", VRP.jpgQuality, 1, 100);
            //}
            EditorGUILayout.LabelField("Render", GUI.skin.horizontalSlider);
            VRP.renderQualitySettings = EditorGUILayout.Foldout(VRP.renderQualitySettings, new GUIContent("RENDER QUALITY SETTINGS", "Here we can set render quality settings and tune performance for in-editor work."), true);
            if (VRP.renderQualitySettings)
            {
                VRP.optimizedSpeedRendering = EditorGUILayout.Toggle(new GUIContent("Responsive Rendering Mode", "This instructs Deckard to use Responsive Rendering Mode. This mode updates rendering slower than default rendering mode, but it prevents editor from having a slow response. Experimental Feature."), VRP.optimizedSpeedRendering);
                VRP.useHalfResolution = EditorGUILayout.Toggle(new GUIContent("Use Half Resolution", "Here we can set Deckard to use half resolutin for rendering in Editor. It can improove framerates while working in Editor while giving a preview of correct DOF"), VRP.useHalfResolution);
                VRP.progressiveRendering = EditorGUILayout.Toggle(new GUIContent("Use Editor Progressive Rendering", "Here we can set Deckard to use progressive rendering in editor. It can improove framerates while working in Editor and moving camera"), VRP.progressiveRendering);
                if (!VRP.progressiveRendering) {
                    VRP.batchGroups = EditorGUILayout.IntSlider(new GUIContent("Batch Groups", "This value defines responsivness in editor mode. Greater value gives faster rendering of Deckard View, while smaller values give better response to Unity Interface."), VRP.batchGroups, 1, VRP.editorQuality);
                    VRP.editorQuality = EditorGUILayout.IntSlider(new GUIContent("Editor quality", "This value defines how many times we should sample Syntetic Aperture and Motion Blur while using Unity Editor in Edit mode. Higher values give overall better quality, but slower rendering speed. Default is 10"), VRP.editorQuality, 1, 30);
                    
                }
                else
                {

                    VRP.batchGroups = EditorGUILayout.IntSlider(new GUIContent("Batch Groups", "This value defines responsivness in editor mode. Greater value gives faster rendering of Deckard View, while smaller values give better response to Unity Interface."), VRP.batchGroups, 1, VRP.maxInteractiveSteps);
                    VRP.minInteractiveSteps = EditorGUILayout.IntSlider(new GUIContent("Min progressive Quality", "This value defines how many times we should sample Syntetic Aperture and Motion Blur while using Unity Editor in Edit mode. Higher values give overall better quality, but slower rendering speed. Default is 1"), VRP.minInteractiveSteps, 1, 10);

                    VRP.maxInteractiveSteps = EditorGUILayout.IntSlider(new GUIContent("Max progressive Quality", "This value defines how many times we should sample Syntetic Aperture and Motion Blur while using Unity Editor in Edit mode. Higher values give overall better quality, but slower rendering speed. Default is 30"), VRP.maxInteractiveSteps, 1, 80);
                }
                VRP.renderQuality = EditorGUILayout.IntSlider(new GUIContent("Render quality", "This value defines how many times we should sample Syntetic Aperture and Motion Blur. Higher values give overall better quality, but slower rendering speed. Default is 75"), VRP.renderQuality, 1, 150);
                VRP.antiAliasing = EditorGUILayout.Slider(new GUIContent("Antialiasing bias", "This value defines how much of antialiasing/blurring is applied at in-focus range of DOF. Default is 1.0"), VRP.antiAliasing, -2f, 2f);
                VRP.superSample = EditorGUILayout.Slider(new GUIContent("Supersample", "Supersampling value defines if we should actually render higher resolution image that will be resized down to final resolution. This process can eliminate aliasing issues with vertical or horizontal lines. This is a costly operation, so it should be used only if you have any issues with aliasing. Default is 1.0"), VRP.superSample, 0.5f, 2f);
                VRP.useTimeCorrection = EditorGUILayout.Toggle(new GUIContent("Use precise timing", "Use precize timing for Physics and particles"), VRP.useTimeCorrection);
            }
            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);


            VRP.animationSettings = EditorGUILayout.Foldout(VRP.animationSettings, new GUIContent("ANIMATION/TIMELINE SETTINGS", "HEre you can set video resolutions and framerate for your movie"), true);
            if (VRP.animationSettings)
            {
                //  GUILayout.BeginHorizontal();       
                VRP.timeline = EditorGUILayout.ObjectField("Timeline Playable ", VRP.timeline, typeof(PlayableDirector), true) as PlayableDirector;
                VRP.followObject = EditorGUILayout.ObjectField("Follow Object ", VRP.followObject, typeof(GameObject), true) as GameObject;
                VRP.resolution = EditorGUILayout.IntField(new GUIContent("frame Width", "Frame Width"), VRP.resolution);
                VRP.resolutionH = EditorGUILayout.IntField(new GUIContent("frame Height", "Frame Height"), VRP.resolutionH);
                //  GUILayout.EndHorizontal();
                VRP.FPS = EditorGUILayout.IntField(new GUIContent("Frame Rate", "Framerate"), VRP.FPS);
                VRP.NumberOfFramesToRender = EditorGUILayout.IntField(new GUIContent("Number of frames to render", "Number of frames to render"), VRP.NumberOfFramesToRender);
                VRP.renderFromFrame = EditorGUILayout.IntField(new GUIContent("Resume fromframe", "Resume rendering from frame. This has to be used as resume option after crash or user cancel"), VRP.renderFromFrame);


                float sequenceTime = ((float)VRP.NumberOfFramesToRender - (float)VRP.renderFromFrame) / (float)VRP.FPS;
                int minutesSeq = (int)sequenceTime / 60;
                int secondsSeq = (int)sequenceTime % 60;

                int frames = (VRP.NumberOfFramesToRender - VRP.renderFromFrame) - (minutesSeq * VRP.FPS * 60 + secondsSeq * VRP.FPS);

                string sequenceLength = (minutesSeq + " min. " + secondsSeq + " sec. " + frames + " frames");


                GUILayout.Label("Sequence Length: " + sequenceLength);

                GUILayout.Label("RESOLUTION PRESETS:");

                GUILayout.BeginHorizontal();
                GUILayout.BeginVertical();
                if (GUILayout.Button("HD 720p"))
                {
                    VRP.resolution = 1280;
                    VRP.resolutionH = 720;
                    VRP.Mp4Bitrate = 5000;
                }
                if (GUILayout.Button("HD 1080p"))
                {
                    VRP.resolution = 1920;
                    VRP.resolutionH = 1080;
                    VRP.Mp4Bitrate = 8000;
                }

                if (GUILayout.Button("QHD/ 2K"))
                {
                    VRP.resolution = 2560;
                    VRP.resolutionH = 1440;
                    VRP.Mp4Bitrate = 16000;
                }

                GUILayout.EndVertical();
                GUILayout.BeginVertical();
                if (GUILayout.Button("UHD 4K"))
                {
                    VRP.resolution = 3840;
                    VRP.resolutionH = 2160;
                    VRP.Mp4Bitrate = 35000;
                }

                if (GUILayout.Button("DCI 4K"))
                {
                    VRP.resolution = 4096;
                    VRP.resolutionH = 2048;
                    VRP.Mp4Bitrate = 50000;
                }

                if (GUILayout.Button("Youtube 8K"))
                {
                    VRP.resolution = 7680;
                    VRP.resolutionH = 4320;
                    VRP.Mp4Bitrate = 100000;
                }
                GUILayout.EndVertical();

                GUILayout.EndHorizontal();

            }
            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

            VRP.exportOptions = EditorGUILayout.Foldout(VRP.exportOptions, new GUIContent("VIDEO EXPORT OPTIONS", "Here you can set video Export options."), true);
            if (VRP.exportOptions)
            {
                VRP.ImageFormatType = (DeckardRender.VRFormatList)EditorGUILayout.EnumPopup("Sequence Format", VRP.ImageFormatType);


                VRP.Folder = EditorGUILayout.TextField("Sequence File Name", VRP.Folder);

                VRP.videoCompression = (DeckardRender.VideoCompression)EditorGUILayout.EnumPopup("Video Format", VRP.videoCompression);
                if (VRP.videoCompression == DeckardRender.VideoCompression.Mp4)
                    VRP.Mp4Bitrate = EditorGUILayout.IntField(new GUIContent("H.264 Bitrate", "MP4 Bitrate"), VRP.Mp4Bitrate);

                VRP.captureOnPlay = EditorGUILayout.Toggle(new GUIContent("Capture on Play", "Start capturing on Scene play"), VRP.captureOnPlay);
                VRP.encodeToVideo = EditorGUILayout.Toggle(new GUIContent("Encode H.264 video after rendering", "Encode H.246 video after rendering finishes"), VRP.encodeToVideo);
                VRP.captureAlpha = EditorGUILayout.Toggle(new GUIContent("Export Alpha channel (experimental)", "Export Alpha channel (experimental)"), VRP.captureAlpha);

            }
            //	string fullPath = Path.GetFullPath(string.Format(@"{0}/", VRP.Folder));
            string ffmpegPath = Application.dataPath + "\\DeckardRender\\StreamingAssets\\";
            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
            DeckardRender.facebookExportOptions = EditorGUILayout.Foldout(DeckardRender.facebookExportOptions, new GUIContent("Facebook Screenshot options", "Here you can set screenshot option for facebook 3D images."), true);
            if (DeckardRender.facebookExportOptions)
            {
                if (!VRP.usingHDRP)
                {
                    VRP.depthTest = EditorGUILayout.Toggle("Show Depth Map", VRP.depthTest);
                    VRP.depthScale = EditorGUILayout.FloatField("Depth Scale", VRP.depthScale);
                    VRP.depthOffset = EditorGUILayout.FloatField("Depth Offset", VRP.depthOffset);
                }
                else
                {
                    GUILayout.Label("Facebook Depth export not available in HDRP!");
                }
            }

            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

            DeckardRender.preferenceOptions = EditorGUILayout.Foldout(DeckardRender.preferenceOptions, new GUIContent("Global Preferences", "Here you can set some global Deckard Preferences"), true);
            if (DeckardRender.preferenceOptions)
            {
               // VRP.depthTest = EditorGUILayout.Toggle("Show Depth Map", VRP.depthTest);
               
                //if (GUILayout.Button("Save Fixed Preview Resolution"))
                //{
                //    PlayerPrefs.SetInt("FixedRender_W", 50);
                //    PlayerPrefs.SetInt("FixedRender_H", 50);
                //}
                DeckardRender.secondaryMonitorResolution = EditorGUILayout.Vector2Field("Depth Scale", DeckardRender.secondaryMonitorResolution);
                if (GUILayout.Button("Set Resolution")) 
                {
                    PlayerPrefs.SetInt("MonitorRes_W", Mathf.RoundToInt (DeckardRender.secondaryMonitorResolution.x));
                    PlayerPrefs.SetInt("MonitorRes_H", Mathf.RoundToInt(DeckardRender.secondaryMonitorResolution.y));
                }
            }

            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
            //GUILayout.BeginVertical("box");
            //GUILayout.Label("Audio");

            //VRP.volume = EditorGUILayout.Slider("Audio Volume", VRP.volume, 0, 1);
            //if ((int)AudioSettings.speakerMode == 3)
            //    VRP.ambisonics = EditorGUILayout.Toggle(new GUIContent("Export Ambisonics 4.0", ""), VRP.ambisonics);
            //else
            //{
            //    GUILayout.BeginVertical("box");
            //    GUILayout.Label("Ambisonics audio unavailable!");
            //    GUILayout.Label("Please, set default speaker mode to QUAD.");

            //    GUILayout.EndVertical();
            //}
            //VRP.mute = EditorGUILayout.Toggle(new GUIContent("Mute while Rendering", ""), VRP.mute);




            //GUILayout.EndVertical();



            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

            if (GUILayout.Button("Encode Video From Existing sequence "))
            {

                if (System.IO.File.Exists(VRP.Folder + "/" + VRP.Folder + ".wav"))
                {

                    System.Diagnostics.Process.Start(ffmpegPath + "ffmpeg", " -f image2" + " -framerate " + VRP.FPS + " -i \"" + VRP.fullPath + VRP._prefix + "%05d" + VRP.formatString + " -i \"" + VRP.fullPath + VRP.Folder + ".wav" + "\"" + " -r " + VRP.FPS + " -vcodec libx264 -y -pix_fmt yuv420p -b:v " + VRP.Mp4Bitrate + "k" + " -c:a aac  -strict experimental  -b:a 192k -shortest " + " \"" + VRP.fullPath + VRP.Folder + ".mp4\"");
                }
                else System.Diagnostics.Process.Start(ffmpegPath + "ffmpeg", " -f image2" + " -framerate " + VRP.FPS + " -i \"" + VRP.fullPath + VRP._prefix + "%05d" + VRP.formatString + " -r " + VRP.FPS + " -vcodec libx264 -y -pix_fmt yuv420p -b:v " + VRP.Mp4Bitrate + "k" + " \"" + VRP.fullPath + VRP.Folder + ".mp4\"");
            }


            if (GUILayout.Button("Create GIF animation "))
            {


                System.Diagnostics.Process.Start(ffmpegPath + "ffmpeg", " -f image2" + " -framerate " + VRP.FPS + " -i \"" + VRP.fullPath + VRP._prefix + "%05d" + VRP.formatString + "" + " \"" + VRP.fullPath + VRP.Folder + ".gif\"");
            }



            if (GUILayout.Button("Delete All Images"))
            {
                var list = System.IO.Directory.GetFiles(VRP.fullPath, "*.jpg");
                foreach (var item in list)
                {
                    System.IO.File.Delete(item);
                }
                var listPNG = System.IO.Directory.GetFiles(VRP.fullPath, "*.png");
                foreach (var item in listPNG)
                {
                    System.IO.File.Delete(item);
                }
                var listEXR = System.IO.Directory.GetFiles(VRP.fullPath, "*.exr");
                foreach (var item in listEXR)
                {
                    System.IO.File.Delete(item);
                }
            }

            if (GUILayout.Button("Render animation", style))
            {
                if (VRP.captureOnPlay)
                    UnityEditor.EditorApplication.isPlaying = true;
                else Debug.LogWarning("CAN'T RENDER! Please, be sure to check that Capture on Play value in Export Options is set to TRUE");
            }

            //if (GUILayout.Button("Capture Audio", style))
            //{
            //    VRP.captureAudio = true;
            //    UnityEditor.EditorApplication.isPlaying = true;
            //}


            if (GUILayout.Button("Open destination folder"))
            {
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo()
                {
                    FileName = VRP.fullPath,
                    UseShellExecute = true,
                    Verb = "open"
                });
            }

            if (GUILayout.Button("Save Screenshot"))
            {
                bool optimizedSR = VRP.optimizedSpeedRendering;
                bool progressiveState = VRP.progressiveRendering;
                VRP.optimizedSpeedRendering = false;
                VRP.progressiveRendering = false;
                VRP.depthTest = false;
                VRP.overrideEditor = true;

                // VRP.Update();
                //   VRP.screenshot = true;

                // VRP.Update();
                Debug.Log("Updated");

                VRP.optimizedSpeedRendering = optimizedSR;
               VRP.progressiveRendering = progressiveState;

            }

            if (EditorGUI.EndChangeCheck())
            {

                Undo.RecordObject(VRP, "UndoDeckard");

            }




            if (GUI.changed)
            {
                EditorUtility.SetDirty(VRP);
#if UNITY_5_4_OR_NEWER
                EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
#endif
                DeckardRender.editorInteractiveChange = true;
                VRP.somethingChanged = true;



            }
            if (!GUI.changed)
            {
                DeckardRender.editorInteractiveChange = false;

            }


        }
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }


        private void OnGUI()
        {
            Handles.BeginGUI();
            DeckardRender VRP = (DeckardRender)target;
            if (DeckardRender.active)
            {
                if (GUILayout.Button("Deckard Render ON"))
                {
                    DeckardRender.active = false;
                    Update();
                }
            }
            if (!DeckardRender.active)
            {
                if (GUILayout.Button("Deckard Render OFF"))
                {
                    DeckardRender.active = true;
                    Update();
                }
            }
            Handles.EndGUI();
        }


        //void OnSceneGUI()
        //{
        //    DeckardRender VRP = (DeckardRender)target;
        //    if (VRP.active)
        //    {
        //        if (GUILayout.Button("Deckard Render ON"))
        //        {
        //            VRP.active = false;
        //            Update();
        //        }
        //    }
        //    if (!VRP.active)
        //    {
        //        if (GUILayout.Button("Deckard Render OFF"))
        //        {
        //            VRP.active = true;
        //            Update();
        //        }
        //    }
        //}

        void OnSceneGUI()
        {
            DeckardRender VRP = (DeckardRender)target;
            Handles.BeginGUI();
            if (DeckardRender.active)
            {
                if (GUI.Button(new Rect(0, 0, 100, 25), "Deckard ON"))
                {
                    DeckardRender.active = false;
                    VRP.Update();
                }
            }

            if (!DeckardRender.active)
            {
                if (GUI.Button(new Rect(0, 0, 100, 25), "Deckard OFF"))
                {
                    DeckardRender.active = true;
                    VRP.Update();
                }
            }
            Handles.EndGUI();
        }

        
    }
}
