using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DeckardRender;
using UnityEditor;
using System.IO;

//using System;
using System.Linq.Expressions;
using UnityEngine.Playables;
using System;
//using Cinemachine;

//using Kino;


namespace DeckardRender
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    [RequireComponent(typeof(DeckardPreprocess))]
    [AddComponentMenu("Deckard Render/Deckard Render Component")]
    public class DeckardRender : MonoBehaviour
    {


        [Range(1, 150)]
        public int renderQuality = 70;
        [Range(1, 30)]
        public int editorQuality = 8;
        public int finalSteps;
        Vector3 pos;
        Quaternion rot;
        Vector3 oldPos;
        Quaternion oldRot;
        [Range(0, 360)]
        public float shutterAngle = 180f;
        [Range(0, 0.08f)]
        public static float irisRadius;
        public float fStop;
        [Range(0.5f, 1f)]
        public float anamorphicRatio = 1;
        [HideInInspector]
        public Transform focusTransform;

        public RenderTexture rt;
        public RenderTexture rtA;
        private RenderTexture rt3;
        private Texture2D screenShot;

        public RenderTexture rt2;
        [HideInInspector]
        public Camera cam;
        [HideInInspector]
        public Material multipassMat;
        [HideInInspector]
        public Material clearPassMat;

        [HideInInspector]
        public Material finalPassMat;
        // GameObject target;
        [Range(0, 50)]
        public float focusDistance = 5;
        [Range(0.1f, 3)]
        public float antiAliasing = 1;
        [Range(0f, 2)]
        public float sharpen = 0f;
        public float sharpenRadius = 1f;
        public static bool active = true;
        //   public float scaleRenderSize = 1;
        public static bool ready = false;
        [HideInInspector]
        public Material BufferPassMat;
        public Material BufferQuiltPassMat;

        public Material multipassDepthMat;

        [Header("Capture Settings")]
        public int FPS = 24;
        public int NumberOfFramesToRender = 100;
        public int StartFrame = 1;
        public string RenderInfo;
        public string Folder = "Capture";
        public int Mp4Bitrate = 22000;

        private RenderTexture unfilteredRt;
        public int resolution = 1920;
        public int resolutionH = 1080;
        public string sequenceLength;
        private float remainingTime;
        private int minutesRemain;
        private int secondsRemain;

        public enum VRFormatList { JPG, PNG, EXR_HDRI };
        public VRFormatList ImageFormatType;
        public enum SharpnessDetection { DepthTest, Edge_Detection };
        public SharpnessDetection SharpDetectType;

        public enum RenderingType { Image, Stereo_Image, Lightfield };
        public RenderingType RenderType;

        public string formatString;
        public string fullPath;
        public string _prefix = "img";
        public bool encodeToVideo = true;
        private bool openDestinationFolder = true;
        private bool mailme;
        [HideInInspector]
        public float focalDistance;
        public bool useAutoFocus;
        [HideInInspector]
        public static float oldFocalDistance = 3;
        public bool captureOnPlay = false;
        //   private Color[] shresult;
        //    private Vector3[] shdir;
        public bool useHalfResolution = false;
        //public bool supersample = false;
        public int renderFromFrame;
        public bool useCustomResolution = false;
        public float letterbox = 0;
        public static int currentStep = 0;
        //  public Obscurance obscuranceAO;
        public float noise = 0.09f;
        public int precount = 0;
        private float cameraFov;
        private float oldCameraFov;
        public float superSample = 1f;
        public enum FilmResponseType { KodakD55, KodakD60, KodakD65, FujiD55, FujiD60, FujiD65, Canon, BMPCC4K, AlexaARRILogC, REC709, Neutral };
        public FilmResponseType filmResponseType;
        public FilmResponseType oldFilmResponseType;

        public enum VideoCompression { Mp4, Prores };
        public VideoCompression videoCompression;

        public Texture filmResponseTex;
        public float exposure = 1f;
        public float hFieldOfView;
        public float focalmm;
        //public RenderTexture rtTemp;
        private Material depthMat;
        private Material facebookeDepth;
        public static float deckardTime;
        public static float oldDeckardTime;
        public bool useAnimatorForMotionBlur;
        public float filmResponseInfluence = 1f;
        RenderTextureFormat rtFormat;
        int depthBuffer = 0;
        //      float internalTiming = 0;
        int frame = 0;
        public enum FilmSize { _35mm, IMAX, HasselbladMediumFormat, _16mm, APS_C, MicroFourThirds, S9, iPhone, Custom };
        public FilmSize enumFilmSize;
        public FilmSize OldEnumFilmSize;
        float filmSize = 35f;
        public bool updated = false;
        public int maxInteractiveSteps = 30;
        public int minInteractiveSteps = 1;
        public bool progressiveRendering = false;
        public static bool editorInteractiveChange;
        public bool roll1 = true;
        public bool renderQualitySettings = false;
        public bool animationSettings = false;
        public bool exportOptions = false;
        public bool useBloom = false;
        public float bloomRadius = 0f;
        public float bloomIterations = 0f;
        public float bloomIntensity = 0f;
        DeckardPreprocess preProcess;
        public bool focusTest = false;
        public bool depthTest = false;
        public float customFilmSize;
        public float focusSpeed = 0.05f;
        Vector3 oldGPos;
        Quaternion oldGRot;
        GameObject oldSelection;
        float grassSpeed;
        public float tiltShift = 1f;

        public bool timelineSupport = true;
        public PlayableDirector timeline;
        public SkinnedMeshRenderer[] skinnedMeshes;
        public bool overrideEditor = false;
        public bool screenshot = false;
        public float depthScale = 1f;
        public float depthOffset = 0f;
        public static bool facebookExportOptions = false;
        public static bool preferenceOptions = false;
        public static Vector2 fixedRenderingResolution;
        public static Vector2 secondaryMonitorResolution = new Vector2(1980, 1080);
        //  public Transform cineCam;
        public bool cinemachineCut = false;
        Vector3 cinePosition;
        Quaternion cineRotation;
        public bool usingHDRP = false;
        public float timestep;
        public bool useTimeCorrection = false;
        public bool noDynamicObjects = false;
        public float interactiveTimer = 1f;
        public bool somethingChanged = false;


        DParticleMotionBlur[] particles;
        DeckardObjectMotionBlur[] motionObjects;
        DeckardAnimatorMotionBlur[] animatorObjects;
        public float lensVignetteBlur = 0f;
        public int bokehBlades = 6;
        public float bladeCurvature = 1f;
        public float bokehFill = 0.8f;
        public int rememberRenderSteps = 1;
        public bool optimizedSpeedRendering = true;
        public static int curentOptimizedSteps = 0;
        public RenderTexture bufferPass;
        public bool lightFieldRender = false;
        int lightfieldStep = 0;
        public bool customProjectionPlane = false;

        public bool captureAlpha = false;


        public GameObject projectionScreen;
        public bool estimateViewFrustum = true;
        public bool setNearClipPlane = false;
        public float nearClipDistanceOffset = -0.01f;
        public int lightfieldLayoutX = 4;
        public int lightfieldLayoutY = 4;

        private Camera cameraComponent;
        Vector2 currenTile;
        Vector3 oldCustomProjectionScreenPos;
        public RenderTexture rtDW;
        public float whiteBallance = 0f;
        public float filmTint = 0f;



        //  public ICinemachineCamera oldCam;
        //  public ICinemachineCamera newCam;
        public int batchGroups = 2;
        public bool focusAssist = false;
        public bool zebras = false;

        public GameObject followObject;

        public bool captureAudio = false;
        private bool ambisonicsSupportTest;
        public float volume = 1.0f;
        private bool recOutput = false;
        private FileStream fileStream;
        public int bufferSize;
        public int numBuffers;
        private int outputRate = 48000;
        private int headerSize = 44; //default for uncompressed wav
        public bool ambisonics = false;
        public UInt16 achannels;
        public bool mute = true;
        public string version = "2.0";
        public float saturation = 1f;


#if UNITY_EDITOR
        public void Awake()
        {
            //if (oldGPos == null) oldGPos = new Vector3(0f, 0f, 0f);
            //if (oldGRot == null) oldGRot = Quaternion.Euler(0f, 0f, 0f);
            EditorApplication.ExecuteMenuItem("Deckard Render/Deckard View");
            Selection.activeGameObject = gameObject;
            if (oldGPos == null) oldGPos = gameObject.transform.position;
            if (oldGRot == null) oldGRot = gameObject.transform.rotation;
            

            //  cam = gameObject.GetComponent<Camera>();
            if (cam == null) cam = gameObject.GetComponent<Camera>();
            if (timeline == null)
            {
                oldCameraFov = cam.fieldOfView;
                cameraFov = cam.fieldOfView;
            }
            multipassMat = Resources.Load("DeckardMultiPass", typeof(Material)) as Material;
            clearPassMat = Resources.Load("DeckardClearPass", typeof(Material)) as Material;
            finalPassMat = Resources.Load("DeckardFinalPass", typeof(Material)) as Material;
            depthMat = Resources.Load("Deckard_depthBuffer", typeof(Material)) as Material;
            facebookeDepth = Resources.Load("Facebook_Depth", typeof(Material)) as Material;
            multipassDepthMat = Resources.Load("MultiPass_Alpha", typeof(Material)) as Material;

            if (preProcess == null)
            {
                preProcess = GetComponent<DeckardPreprocess>();
                if (preProcess == null)
                {
                    preProcess = gameObject.AddComponent<DeckardPreprocess>();
                }
            }
            // VRAA = Resources.Load("Materials/VRAA", typeof(Material)) as Material;
            if (filmResponseTex == null) LoadLUT();

            //  StartCoroutine(CheckUpdate());

        }

        public IEnumerator CheckUpdate()
        {
            WWW w = new WWW("https://www.dropbox.com/s/a5jjwmsi25ldfcb/DeckardUpdate.txt");
            yield return w;
            if (w.error != null)
            {
                Debug.Log("Error .. " + w.error);
                // for example, often 'Error .. 404 Not Found'
            }
            else
            {
                Debug.Log("Found ... ==>" + w.text + "<==");
                // don't forget to look in the 'bottom section'
                // of Unity console to see the full text of
                // multiline console messages.
            }




        }


        private void OnDestroy()
        {
            Time.timeScale = 1f;
            if (rt != null)
                rt.Release();
            if (rt2 != null)
                rt2.Release();
            if (rt3 != null)
                rt3.Release();
            if (rtA != null)
                rtA.Release();
            if (rtDW != null)
                rtDW.Release();
        }
        private void OnDisable()
        {

            Time.timeScale = 1f;
            DeckardPreprocess pp = gameObject.GetComponent<DeckardPreprocess>();
            if (pp)
            {
                pp.enabled = false;
            }
            if (rt != null)
                rt.Release();
            if (rt2 != null)
                rt2.Release();
            if (rt3 != null)
                rt3.Release();
            if (rtA != null)
                rtA.Release();
            if (rtDW != null)
                rtDW.Release();
        }

        private void OnEnable()
        {
            DeckardPreprocess pp = gameObject.GetComponent<DeckardPreprocess>();
            if (pp && !usingHDRP)
            {
                pp.enabled = true;
            }
            else pp.enabled = true;
        }



        private void OnValidate()
        {
            Time.timeScale = 1f;


        }




        public void Start()
        {
            if (captureAudio)
            {

                if ((int)AudioSettings.speakerMode == 3)
                    ambisonicsSupportTest = true;
                if ((int)AudioSettings.speakerMode == 1) achannels = 1;
                else if ((int)AudioSettings.speakerMode == 2) achannels = 2;
                else if ((int)AudioSettings.speakerMode == 3) achannels = 4;
                else if ((int)AudioSettings.speakerMode == 4) achannels = 5;
                else if ((int)AudioSettings.speakerMode == 5) achannels = 6;
                else if ((int)AudioSettings.speakerMode == 6) achannels = 8;
                UnityEngine.Debug.Log("channels" + (int)AudioSettings.speakerMode + achannels);
                outputRate = AudioSettings.outputSampleRate;
                AudioSettings.GetDSPBufferSize(out bufferSize, out numBuffers);
                AudioListener.volume = volume;

                System.IO.Directory.CreateDirectory(fullPath);
                StartWriting(fullPath + "/" + Folder + ".wav");
                recOutput = true;
                print("rec start");

            }


            else
            {
                if (EditorApplication.isPlaying && captureOnPlay)
                {
                    active = false;
                    Time.timeScale = 0;
                    precount = 0;
                    rememberRenderSteps = renderQuality;
                    renderQuality = 1;
                }
                Time.maximumParticleDeltaTime = 100;
                if (EditorApplication.isPlaying)
                {
                    Terrain[] terrain = FindObjectsOfType<Terrain>();

                    foreach (Terrain t in terrain)
                    {
                        grassSpeed = t.terrainData.wavingGrassStrength;
                        float speed = (grassSpeed / (renderQuality * 2f));
                        t.terrainData.wavingGrassStrength = speed;

                    }

                    if (useTimeCorrection)
                    {
                        Time.fixedDeltaTime = 0.002f;
                        Time.maximumParticleDeltaTime = 0.03f;
                    }
                }
                else
                {
                    Terrain[] terrain = FindObjectsOfType<Terrain>();

                    foreach (Terrain t in terrain)
                    {
                        grassSpeed = t.terrainData.wavingGrassStrength;
                        float speed = grassSpeed * renderQuality * 2f;
                        t.terrainData.wavingGrassStrength = speed;

                    }
                }
                //7Test for cinemachine shots



                if (cam == null) cam = gameObject.GetComponent<Camera>();
                if (timeline == null)
                {
                    cameraFov = cam.fieldOfView;
                    oldCameraFov = cam.fieldOfView;
                }
                rtFormat = RenderTextureFormat.ARGBFloat;
                depthBuffer = 24;

                oldPos = pos;
                DynamicGI.updateThreshold = -100;
                ///if scene is in play mode, deactivate rendering until scene stabilizes
                if (EditorApplication.isPlaying && captureOnPlay)
                {
                    active = false;
                    Time.timeScale = 0;
                    precount = 0;
                }
                else Time.timeScale = 1;

                //    UnityEngine.Rendering.SphericalHarmonicsL2 sh2;
                //    LightProbes.GetInterpolatedProbe(new Vector3(0.0f, 0.0f, 0.0f), null, out sh2);


                //    Vector3[] directions = new Vector3[]
                //    {
                //new Vector3(0.0f, 1.0f, 0.5f),
                //new Vector3(0.25f, 1.0f, 0.5f),
                //new Vector3(0.5f, 1.0f, 0.5f),
                //new Vector3(1.0f, 1.0f, 0.5f)
                //    };
                //    Color[] results = new Color[4];

                //    sh2.Evaluate(directions, results);
                //   shdir = directions;
                //   shresult = results;


                if (EditorApplication.isPlaying && captureOnPlay)
                {
                    fullPath = Path.GetFullPath(string.Format(@"{0}/", Folder));


                    Application.runInBackground = true;
                    StartFrame = Time.frameCount;


                    VideoRenderPrepare();
                }
                multipassMat = Resources.Load("DeckardMultiPass") as Material;
                clearPassMat = Resources.Load("DeckardClearPass") as Material;
                finalPassMat = Resources.Load("DeckardFinalPass") as Material;
                BufferPassMat = Resources.Load("DeckardBuffer", typeof(Material)) as Material;
                BufferQuiltPassMat = Resources.Load("DeckardQuiltBuffer", typeof(Material)) as Material;
                depthMat = Resources.Load("Deckard_depthBuffer", typeof(Material)) as Material;
                multipassDepthMat = Resources.Load("MultiPassAlpha", typeof(Material)) as Material;

                pos = gameObject.transform.position;
                rot = gameObject.transform.rotation;
                if (!useHalfResolution)
                    rt = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                else rt = RenderTexture.GetTemporary(Screen.width / 2, Screen.height / 2, depthBuffer, rtFormat);

                rt.useMipMap = false;

                cam = gameObject.GetComponent<Camera>();
                cam.targetTexture = rt;

                if (preProcess == null && !usingHDRP)
                {
                    preProcess = GetComponent<DeckardPreprocess>();
                    if (preProcess == null)
                    {
                        preProcess = gameObject.AddComponent<DeckardPreprocess>();
                    }
                }


                ///// obscurance Part
                //    obscuranceAO = GetComponent<Obscurance>();
                //////

                rt2 = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                rt2.useMipMap = false;
                rtDW = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                if (captureAlpha)
                {
                    rtA = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                    rtA.useMipMap = false;
                }

                Shader.SetGlobalTexture("_AperturePass", rt2);
                Shader.SetGlobalTexture("_AlphaPass", rtA);
                //   rtTemp = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                //   Shader.SetGlobalTexture("_DeckardTemp", rtTemp);


                oldPos = gameObject.transform.position;

                if (noDynamicObjects)
                {
                    particles = FindObjectsOfType<DParticleMotionBlur>();
                    motionObjects = FindObjectsOfType<DeckardObjectMotionBlur>();


                    animatorObjects = FindObjectsOfType<DeckardAnimatorMotionBlur>();
                }
            }
        }


        public void SkinMotionBlur()
        {
            if (timeline != null && UnityEditor.EditorApplication.isPlaying && cinemachineCut == false)
            {
                timeline.time = Time.time - Shader.GetGlobalVector("_DeckardTime").y + (float)timeline.initialTime;
                timeline.Evaluate();

                float tt = Time.time + Shader.GetGlobalVector("_DeckardTime").y + (float)timeline.initialTime;
                //     print("Time" + Time.time + Shader.GetGlobalVector("_DeckardTime").y + timeline.initialTime + );
            }
            if (timeline != null && UnityEditor.EditorApplication.isPlaying && cinemachineCut == true)
            {
                timeline.time = Time.time + timeline.initialTime;
                timeline.Evaluate();
                Debug.Log("Cinemachine cuytted");
            }

            if (followObject != null)
            {
                gameObject.transform.position = followObject.transform.position;
                gameObject.transform.rotation = followObject.transform.rotation;
            }
            //   Debug.Log(Shader.GetGlobalVector("_DeckardTime").y);
        }

        public void Update()
        {
            if (!captureAudio)
            {

                frame++;
                if ((frame - 25) >= renderFromFrame && captureOnPlay && EditorApplication.isPlaying)
                {
                    renderQuality = rememberRenderSteps;

                }
                //  internalTiming = internalTiming + (frame * FPS/;

                if (focusAssist) finalPassMat.SetFloat("_DeckardDepthTestEdges", 1f);
                else finalPassMat.SetFloat("_DeckardDepthTestEdges", 0f);

                if (zebras) finalPassMat.SetFloat("_zebras", 0f);
                else finalPassMat.SetFloat("_zebras", 1f);

                ////Test cinemachine shots
                //if (timeline != null && UnityEditor.EditorApplication.isPlaying)
                //{

                //    newCam = gameObject.GetComponent<Cinemachine.CinemachineBrain>().ActiveVirtualCamera;

                //    if (newCam != oldCam) cinemachineCut = true;
                //    else cinemachineCut = false;
                //    //  Debug.Log(cinemachineCut + "  " + oldCam + "  " + newCam);
                //    oldCam = newCam;
                //}

                ///end test

                finalPassMat.SetFloat("_Temp", whiteBallance);
                finalPassMat.SetFloat("_CTint", filmTint);
                multipassMat.SetFloat("_saturation", saturation);


                SkinMotionBlur();

                if (focusTest)
                {
                    Shader.SetGlobalFloat("_DeckardFocusTest", 1f);
                    Shader.SetGlobalFloat("_DeckardFocusDistance", focusDistance);
                    focusDistance = focusDistance;
                }



                else Shader.SetGlobalFloat("_DeckardFocusTest", 0f);

                if (depthTest)
                {
                    Shader.SetGlobalFloat("_DeckardDepthTest", 1f);
                    Shader.SetGlobalFloat("_DeckardDepthScale", depthScale);
                    Shader.SetGlobalFloat("_DeckardDepthOffset", depthOffset);
                }
                else Shader.SetGlobalFloat("_DeckardDepthTest", 0f);

                if (rt == null || rt2 == null || rtDW == null)
                {
                    if (!useHalfResolution)
                        rt = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                    else rt = RenderTexture.GetTemporary(Screen.width / 2, Screen.height / 2, depthBuffer, rtFormat);
                    rt2 = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                    rt2.useMipMap = false;
                    rtDW = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                    Shader.SetGlobalTexture("_AperturePass", rt2);


                }

                if (captureAlpha && rtA == null)
                {
                    rtA = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                    rtA.useMipMap = false;
                    Shader.SetGlobalTexture("_AlphaPass", rtA);
                }

                if (bufferPass == null && optimizedSpeedRendering)
                {
                    bufferPass = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                }

                if (preProcess == null)
                {
                    preProcess = GetComponent<DeckardPreprocess>();
                    if (preProcess == null)
                    {
                        preProcess = gameObject.AddComponent<DeckardPreprocess>();
                    }
                }

                deckardTime = Time.time / FPS;
                hFieldOfView = (2f * Mathf.Atan(Mathf.Tan(Mathf.Deg2Rad * cam.fieldOfView / 2f) * cam.aspect)) * Mathf.Rad2Deg;
                focalmm = (filmSize / (2 * Mathf.Tan(Mathf.Deg2Rad * hFieldOfView / 2f)));
                Shader.SetGlobalFloat("_filmResponseValue", filmResponseInfluence);
                Shader.SetGlobalFloat("_DeckardExposure", exposure);

                irisRadius = focalmm / (fStop * 2f * 1000f);

                //mat.SetFloat("_LUT", exposure);
                if (cam == null) cam = gameObject.GetComponent<Camera>();
                if (EditorApplication.isPlaying && captureOnPlay && active == false)
                {

                    precount++;
                    if (precount < 50)
                    {
                        precount++;
                        lightfieldStep = 0;
                    }
                    else
                    {
                        active = true;
                        Time.timeScale = 1;

                    }
                }

                //    if (obscuranceAO == null) obscuranceAO = GetComponent<Obscurance>();
                ////
                //        float frustumHeight = 2.0f * focusDistance * Mathf.Tan(cam.fieldOfView * 0.5f * Mathf.Deg2Rad);

                if (UnityEditor.EditorApplication.isPlaying == true || overrideEditor == true)
                    finalSteps = renderQuality;
                else finalSteps = editorQuality;

                if (!useHalfResolution && UnityEditor.EditorApplication.isPlaying == false)
                {

                    if (Screen.width != rt.width || Screen.height != rt.height)
                    {

                        rt.Release();
                        rt2.Release();

                        //    if (rtTemp)
                        //         rtTemp.Release();

                        rt = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                        rt2 = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                        rtDW = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                        //   rtTemp = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                        rt.useMipMap = false;
                        rt2.useMipMap = false;
                    }

                }
                if (useHalfResolution && UnityEditor.EditorApplication.isPlaying == false)
                {
                    if (Screen.width / 2 != rt.width || Screen.height / 2 != rt.height)
                    {
                        rt.Release();
                        rt2.Release();

                        rt = RenderTexture.GetTemporary(Screen.width / 2, Screen.height / 2, depthBuffer, rtFormat);
                        rt2 = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                        rtDW = RenderTexture.GetTemporary(Screen.width, Screen.height, depthBuffer, rtFormat);
                        rt.useMipMap = false;
                        rt2.useMipMap = false;

                    }
                }
                if (UnityEditor.EditorApplication.isPlaying == true || overrideEditor == true)
                {
                    if (Mathf.FloorToInt(resolution * superSample) != rt.width || Mathf.FloorToInt(resolutionH * superSample) != rt.height)
                    {
                        rt.Release();
                        rt2.Release();
                        if (!lightFieldRender)
                        {
                            rt = RenderTexture.GetTemporary(Mathf.FloorToInt(resolution * superSample), Mathf.FloorToInt(resolutionH * superSample), depthBuffer, rtFormat);
                            rt2 = RenderTexture.GetTemporary(resolution, resolutionH, depthBuffer, rtFormat);
                            rtDW = RenderTexture.GetTemporary(resolution, resolutionH, depthBuffer, rtFormat);
                        }
                        else
                        {
                            rt = RenderTexture.GetTemporary(Mathf.FloorToInt(resolution * superSample) / lightfieldLayoutX, Mathf.FloorToInt(resolutionH * superSample) / lightfieldLayoutY, depthBuffer, rtFormat);
                            rt2 = RenderTexture.GetTemporary(resolution / lightfieldLayoutX, resolutionH / lightfieldLayoutY, depthBuffer, rtFormat);
                            rtDW = RenderTexture.GetTemporary(resolution / lightfieldLayoutX, resolutionH / lightfieldLayoutY, depthBuffer, rtFormat);
                        }

                        rt.useMipMap = false;
                        rt2.useMipMap = false;
                    }
                }
                RaycastHit hit;
                Ray ray = cam.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0));

                if (Physics.Raycast(ray, out hit, cam.farClipPlane))
                {
                    Debug.DrawLine(transform.position, hit.point, Color.red);

                    focalDistance = hit.distance;
                }
                if (useAutoFocus)
                {

                    focusDistance = Mathf.Lerp(oldFocalDistance, Vector3.Distance(transform.position, hit.point), focusSpeed);
                    oldFocalDistance = focusDistance;
                }
                if (!useAutoFocus && focusTransform != null)
                {
                    focusDistance = Mathf.Lerp(oldFocalDistance, Vector3.Distance(gameObject.transform.position, focusTransform.position), focusSpeed);
                    oldFocalDistance = focusDistance;
                }
                oldDeckardTime = deckardTime;

                InteractiveRefresh();
            }

        }

        private void InteractiveRefresh()
        {

            if (!EditorApplication.isPlaying && progressiveRendering)
            {
                if (!overrideEditor)
                {
                    if (gameObject.transform.position != oldPos || gameObject.transform.rotation != oldRot || editorInteractiveChange) updated = true;
                    else updated = false;


                    GameObject go = Selection.activeGameObject;

                    if ((go != null && go.transform.position != oldGPos) || (go != null && go.transform.rotation != oldGRot) || somethingChanged)
                    {
                        updated = true;
                        interactiveTimer = 0f;
                        somethingChanged = false;

                    }
                    else
                    {
                        updated = false;
                        interactiveTimer = interactiveTimer + 0.1F;
                    }

                    if (updated) finalSteps = Mathf.CeilToInt(Mathf.Lerp(minInteractiveSteps, maxInteractiveSteps, interactiveTimer));

                    else finalSteps = Mathf.CeilToInt(Mathf.Lerp(minInteractiveSteps, maxInteractiveSteps, interactiveTimer));

                    if (oldGPos == null) oldGPos = new Vector3(0f, 0f, 0f);
                    if (oldGRot == null) oldGRot = Quaternion.Euler(0f, 0f, 0f);
                    if (go)
                    {
                        if (oldGPos != null) oldGPos = go.transform.position;
                        if (oldGRot != null) oldGRot = go.transform.rotation;
                    }
                }
            }
        }




        void LateUpdate()
        {

            if (!captureAudio)
            {
                if (lightFieldRender && UnityEditor.EditorApplication.isPlaying)
                {
                    if (lightfieldStep == 0)
                    {
                        Time.timeScale = 1f;

                    }
                    else if (lightfieldStep < (lightfieldLayoutX * lightfieldLayoutY))
                    {
                        Time.timeScale = 0f;

                    }
                    //        Debug.Log(lightfieldStep);
                }

                if (UnityEditor.EditorApplication.isPlaying) optimizedSpeedRendering = false;
                if (!optimizedSpeedRendering)
                    BruteForceRendering();
                else
                {
                    OptimizedRendering();
                }
            }

        }

        private void BruteForceRendering()
        {
            if (active)
            {

                if (projectionScreen != null)
                    oldCustomProjectionScreenPos = projectionScreen.transform.position;

                DeckardPreprocess pp = gameObject.GetComponent<DeckardPreprocess>();
                if (pp && !usingHDRP)
                {
                    pp.enabled = true;
                }
                else pp.enabled = false;

                // cameraFov = cam.fieldOfView;
                float interpolatedTime;
                float particleTime = deckardTime - oldDeckardTime;
#if UNITY_2018_3_OR_NEWER
                skinnedMeshes = FindObjectsOfType<SkinnedMeshRenderer>();
#endif



                currentStep = 0;
                ready = false;


                DeckardSoftLight[] lights = FindObjectsOfType<DeckardSoftLight>();

                if (!noDynamicObjects)
                {
                    particles = FindObjectsOfType<DParticleMotionBlur>();
                    motionObjects = FindObjectsOfType<DeckardObjectMotionBlur>();


                    animatorObjects = FindObjectsOfType<DeckardAnimatorMotionBlur>();
                }

                DeckardMultimat[] multimatObjects = FindObjectsOfType<DeckardMultimat>();

                finalPassMat.SetFloat("_Sharpen", sharpen);
                finalPassMat.SetFloat("_SharpenRadius", sharpenRadius);
                Shader.SetGlobalFloat("_finalStep", 0f);
                Shader.SetGlobalTexture("_AperturePass", rt2);

                if (captureAlpha)
                {
                    Shader.SetGlobalTexture("_AlphaPass", rtA);
                }

                finalPassMat.SetTexture("_RT2", rt2);


                pos = gameObject.transform.position;
                rot = gameObject.transform.rotation;
                if (timeline == null)
                {
                    cameraFov = cam.fieldOfView;
                }

                Shader.SetGlobalFloat("_renderSteps", finalSteps + 0f);


                float aaAngle = cam.fieldOfView / rt.height;

                float shutterAngleClamp = 360f / (360f - (360 - shutterAngle));
                // Graphics.Blit(rt, rt2, clearPassMat);
                //   Graphics.Blit(rt, rtA, clearPassMat);
                rt2.Release();
                if (rtA)
                    rtA.Release();
                rt2.Release();


                Vector3 currentPos = gameObject.transform.position;
                //     int currentBladeStep = 0;
#if UNITY_EDITOR
                if (EditorApplication.isPlaying)
                {
                    foreach (DeckardAnimatorMotionBlur ab in animatorObjects)
                    {
                        if (ab.animator == null) ab.animator = ab.gameObject.GetComponent<Animator>();


                        AnimatorClipInfo[] myAnimatorClip = ab.animator.GetCurrentAnimatorClipInfo(0);
                        ab.animatorTime = Time.time;
                        ab.jumpToTime(ab.currentAnimationName(), ab.animatorTime / myAnimatorClip[0].clip.length);
                    }
                }
#endif




                for (int val = 0; val < finalSteps * 2f; val++)
                {
                    if (somethingChanged && !overrideEditor) break;
                    UnityEngine.Random.seed = val * val;

                    Shader.SetGlobalFloat("_finalStep", 0f);
                    float angle = UnityEngine.Random.Range(0f, 360f) * Mathf.Deg2Rad;
                    //  angle = UnityEngine.Random.Range(0f, 360f) * Mathf.Deg2Rad;
                    var rand = irisRadius * (Mathf.Clamp01(Mathf.Pow(Mathf.Sqrt(UnityEngine.Random.Range(0f, 1f)), bokehFill))) * Mathf.Lerp(1f, bladeCurvature, Mathf.Abs(Mathf.Sin(angle * (bokehBlades / 2f))));
                    var rand2 = (Mathf.Sqrt(UnityEngine.Random.Range(0f, 1f)));
                    //  rand = Mathf.InverseLerp(0f, irisRadius , rand);

                    float irisRadiusT = rand;
                    float xp = Mathf.Cos(angle) * (irisRadiusT);
                    float yp = Mathf.Sin(angle) * (irisRadiusT) * tiltShift;
                    float xb;
                    float yb;
                    xb = Mathf.Cos(angle) * rand2;
                    yb = Mathf.Sin(angle) * rand2;
                    Shader.SetGlobalVector("_DeckardAngle", new Vector4(xb, yb, 0f, 0f));

                    Shader.SetGlobalFloat("_NoiseMove", UnityEngine.Random.Range(0f, 1f));


                    //gameObject.transform.LookAt(focusPoint, gameObject.transform.up);

                    gameObject.transform.position = Vector3.Lerp(oldPos, pos, (1f / finalSteps) * (val / shutterAngleClamp));
                    gameObject.transform.rotation = Quaternion.Slerp(oldRot, rot, (1f / finalSteps) * (val / shutterAngleClamp));



                    if (timeline == null && UnityEditor.EditorApplication.isPlaying)
                    {
                        gameObject.transform.position = Vector3.Lerp(oldPos, pos, (1f / finalSteps) * (val / shutterAngleClamp));
                        gameObject.transform.rotation = Quaternion.Slerp(oldRot, rot, (1f / finalSteps) * (val / shutterAngleClamp));


                    }

                    if (lightFieldRender && UnityEditor.EditorApplication.isPlaying && lightfieldStep < (lightfieldLayoutX * lightfieldLayoutY))
                    {
                        gameObject.transform.Translate(new Vector3((0.1f * (lightfieldStep)) - (((lightfieldLayoutX * lightfieldLayoutY) / 2) * 0.1f), 0, 0), Space.Self);
                    }

                    SkinMotionBlur();

                    if (EditorApplication.isPlaying)
                    {
                        foreach (DeckardAnimatorMotionBlur ab in animatorObjects)
                        {
                            //         AnimatorStateInfo animationState = ab.animator.GetCurrentAnimatorStateInfo(0);

                            AnimatorClipInfo[] myAnimatorClip = ab.animator.GetCurrentAnimatorClipInfo(0);
                            ab.jumpToTime(ab.currentAnimationName(), Mathf.Lerp(ab.oldAnimatorTime / myAnimatorClip[0].clip.length, ab.animatorTime / myAnimatorClip[0].clip.length, (1f / finalSteps) * (val / shutterAngleClamp)));
                        }
                    }





                    Vector3 relativePos = transform.TransformPoint(new Vector3(0, 0, focusDistance));

                    if (!float.IsNaN(gameObject.transform.position.x))
                    {
                        gameObject.transform.Translate(Vector3.Scale(new Vector3(xp, yp, 0), new Vector3(anamorphicRatio, 1, 1)), Space.Self);
                    }

                    if (!customProjectionPlane)
                    {
                        cam.ResetProjectionMatrix();
                    }
                    if (customProjectionPlane)
                    {
                        projectionScreen.transform.Translate(new Vector3(UnityEngine.Random.RandomRange(0f, ((projectionScreen.transform.localScale.x / (rt.width)))), UnityEngine.Random.RandomRange(0f, ((projectionScreen.transform.localScale.y / (rt.height)))), 0));

                        gameObject.transform.LookAt(projectionScreen.transform, gameObject.transform.up);



                        Quaternion targetRotation1 = Quaternion.LookRotation(relativePos - transform.position, gameObject.transform.up);
                        gameObject.transform.rotation = targetRotation1;
                        CustomProjectionPlane();


                    }

                    Quaternion targetRotation = Quaternion.LookRotation(relativePos - transform.position, gameObject.transform.up);
                    gameObject.transform.rotation = targetRotation;
                    gameObject.transform.Rotate(new Vector3((aaAngle / finalSteps) * val * antiAliasing * UnityEngine.Random.Range(-0.5f, 0.5f), (aaAngle / finalSteps) * val * antiAliasing * UnityEngine.Random.Range(-0.5f, 0.5f), ((lensVignetteBlur / finalSteps) * lensVignetteBlur * val) - (lensVignetteBlur / 2f)));
                    if (timeline == null)
                    {
                        cam.fieldOfView = Mathf.Lerp(oldCameraFov, cameraFov, (1 / (finalSteps)) * val);
                    }









                    cinePosition = gameObject.transform.position;
                    cineRotation = gameObject.transform.rotation;

                    foreach (DeckardSoftLight l in lights)
                    {
                        if (l.lightL.type == LightType.Directional)
                        {
                            l.transform.rotation = l.GetComponent<DeckardSoftLight>().lightRot;
                            Vector4 rotVec = Shader.GetGlobalVector("_DeckardAngle");
                            //  l.transform.Rotate(new Vector3(UnityEngine.Random.Range((l.lightSize.x / 2) * -1f, (l.lightSize.x / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2))));
                            l.transform.Rotate(new Vector3(UnityEngine.Random.Range((l.lightSize.x / 2) * -1f, (l.lightSize.x / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2)), UnityEngine.Random.Range(0, (360f))));
                            l.SetBias();
                        }

                        if (l.lightL.type == LightType.Spot)
                        {
                            l.transform.position = l.GetComponent<DeckardSoftLight>().lightPos;
                            l.transform.Translate(new Vector3(UnityEngine.Random.Range((l.lightSize.x / 2) * -1f, (l.lightSize.x / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2))), Space.Self);
                            // l.transform.Rotate(new Vector3(0, 0, UnityEngine.Random.Range(0, 360f)));
                            l.SetBias();
                        }

                        if (l.lightL.type == LightType.Point)
                        {
                            l.transform.position = l.GetComponent<DeckardSoftLight>().lightPos;
                            l.transform.Translate(new Vector3(UnityEngine.Random.Range((l.lightSize.x / 2) * -1f, (l.lightSize.x / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2))), Space.Self);
                            l.SetBias();
                        }
                    }

#if UNITY_EDITOR
                    if (EditorApplication.isPlaying && captureOnPlay)
                    {
                        foreach (DParticleMotionBlur pr in particles)
                        {

                            //p.ps.time = Mathf.Lerp(p.oldTime, p.time, (1 / (finalSteps)) * val);
                            // pr.ps.Simulate(Mathf.Lerp(0, (1f / FPS), (1f / finalSteps) * (val / shutterAngleClamp)) + Time.time, true, true);
                            //  pr.ps.Pause(true);
                            pr.time = Time.time - Shader.GetGlobalVector("_DeckardTime").y;
                            pr.Update();



                        }
                    }
#endif

#if UNITY_EDITOR

                    if (EditorApplication.isPlaying)
                    {

                        foreach (DeckardObjectMotionBlur m in motionObjects)
                        {
                            m.transform.position = Vector3.Lerp(m.oldPos, m.pos, (1f / finalSteps) * (val / shutterAngleClamp));
                            m.transform.rotation = Quaternion.Slerp(m.oldRot, m.rot, (1f / finalSteps) * (val / shutterAngleClamp));
                        }
                    }
#endif

                    foreach (DeckardMultimat m in multimatObjects)
                    {
                        m.renderer.material = m.materials[1];
                    }

                    //      obscuranceAO.radius = (1f / finalSteps) * val;

                    //Set shader timing for motion blur
                    interpolatedTime = Mathf.Lerp(0, (1f / FPS), (1f / (finalSteps * 2f)) * (val / shutterAngleClamp));
                    Shader.SetGlobalVector("_DeckardTime", new Vector4(interpolatedTime / 20, interpolatedTime, interpolatedTime * 2, interpolatedTime * 3));
                    Shader.SetGlobalFloat("_deckardInterpolator", (val + 0f) / (finalSteps * 1f));


                    cam.targetTexture = rt;

                    cam.Render();

                    ready = true;
                    Graphics.Blit(rt, rt2, multipassMat);
#if UNITY_EDITOR
                    if (captureAlpha && EditorApplication.isPlaying)
                        Graphics.Blit(rt, rtA, multipassDepthMat);
#endif
                    //    Graphics.Blit(rt, rtTemp, depthMat);

                    Shader.SetGlobalFloat("_finalStep", 1f);

                    #region renderTO Screen - Replace After render Loop
                    if (active)
                    {
                        multipassMat.SetFloat("_step", currentStep);
                        finalPassMat.SetFloat("_NoiseD_A_Amount", noise);
                        finalPassMat.SetFloat("_letterboxing", 1f - letterbox);
                        Shader.SetGlobalTexture("_AperturePass", rt2);
                        Shader.SetGlobalTexture("_DeckardView", rtDW);


                        if (!optimizedSpeedRendering)
                        {
                            finalPassMat.SetFloat("_PreFinalPAss", 0f);
                            Graphics.Blit(rt2, rtDW, finalPassMat);
                            finalPassMat.SetFloat("_PreFinalPAss", 1f);
                            Graphics.Blit(rt2, rtDW, finalPassMat);

                        }

                    }

                    #endregion

                    cam.targetTexture = null;
                    rt.DiscardContents();
                    rt.Release();
                    currentStep++;
                }


                if (overrideEditor)
                {
                    CaptureDepth();
                }


                gameObject.transform.position = pos;
                gameObject.transform.rotation = rot;

                foreach (DeckardSoftLight l in lights)
                {
                    if (l.lightL.type == LightType.Directional)
                    {
                        l.transform.rotation = l.lightRot;
                        l.RestoreBias();
                    }

                    if (l.lightL.type == LightType.Spot)
                    {
                        l.transform.position = l.lightPos;
                        l.transform.rotation = l.lightRot;
                        l.RestoreBias();
                    }

                    if (l.lightL.type == LightType.Point)
                    {
                        l.transform.position = l.lightPos;
                        l.transform.rotation = l.lightRot;
                        l.RestoreBias();
                    }
                }


                foreach (DeckardObjectMotionBlur m in motionObjects)
                {
                    m.oldPos = m.pos;
                    m.oldRot = m.rot;
                    m.transform.position = m.pos;
                    m.transform.rotation = m.rot;
                }




                oldPos = pos;
                oldRot = rot;
                if (timeline == null)
                {
                    oldCameraFov = cameraFov;
                    cam.fieldOfView = cameraFov;
                }
                oldDeckardTime = deckardTime;

                if (customProjectionPlane)
                {
                    projectionScreen.transform.position = oldCustomProjectionScreenPos;

                }
#if UNITY_EDITOR
                if (EditorApplication.isPlaying)
                {

                    foreach (DeckardAnimatorMotionBlur ab in animatorObjects)
                    {
                        //        AnimatorStateInfo animationState = ab.animator.GetCurrentAnimatorStateInfo(0);
                        AnimatorClipInfo[] myAnimatorClip = ab.animator.GetCurrentAnimatorClipInfo(0);
                        ab.oldAnimatorTime = ab.animatorTime;
                        ab.jumpToTime(ab.currentAnimationName(), ab.animatorTime / myAnimatorClip[0].clip.length);


                    }

                }
#endif

                if (overrideEditor)
                {

                    CaptureScreenshot();
                    overrideEditor = false;
                }
#if UNITY_EDITOR
                if (EditorApplication.isPlaying && captureOnPlay && !lightFieldRender) RenderVideo();
                if (EditorApplication.isPlaying && captureOnPlay && lightFieldRender)
                {
                    RenderLightField();
                }
#endif
                lightfieldStep = lightfieldStep + 1;
                if (lightfieldStep == (lightfieldLayoutX * lightfieldLayoutY)) lightfieldStep = 0;

            }

            else
            {
                DeckardPreprocess pp = gameObject.GetComponent<DeckardPreprocess>();
                if (pp)
                {
                    pp.enabled = false;
                }
            }
        }



        private void OptimizedRendering()
        {

            if (active)
            {

                DeckardPreprocess pp = gameObject.GetComponent<DeckardPreprocess>();
                if (pp && !usingHDRP)
                {
                    pp.enabled = true;
                }

                // cameraFov = cam.fieldOfView;
                float interpolatedTime;
                float particleTime = deckardTime - oldDeckardTime;
#if UNITY_2018_3_OR_NEWER
                skinnedMeshes = FindObjectsOfType<SkinnedMeshRenderer>();
#endif



                currentStep = 0;
                ready = false;


                DeckardSoftLight[] lights = FindObjectsOfType<DeckardSoftLight>();

                if (!noDynamicObjects)
                {
                    particles = FindObjectsOfType<DParticleMotionBlur>();
                    motionObjects = FindObjectsOfType<DeckardObjectMotionBlur>();


                    animatorObjects = FindObjectsOfType<DeckardAnimatorMotionBlur>();
                }

                DeckardMultimat[] multimatObjects = FindObjectsOfType<DeckardMultimat>();

                finalPassMat.SetFloat("_Sharpen", sharpen);
                finalPassMat.SetFloat("_SharpenRadius", sharpenRadius);
                Shader.SetGlobalFloat("_finalStep", 0f);
                Shader.SetGlobalTexture("_AperturePass", rt2);

                finalPassMat.SetTexture("_RT2", rt2);


                pos = gameObject.transform.position;
                rot = gameObject.transform.rotation;
                if (timeline == null)
                {
                    cameraFov = cam.fieldOfView;
                }

                Shader.SetGlobalFloat("_renderSteps", finalSteps + 0f);


                float aaAngle = cam.fieldOfView / rt.height;

                float shutterAngleClamp = 360f / (360f - (360 - shutterAngle));
                if (curentOptimizedSteps == 0)
                {
                    rt2.Release();
                }
                Vector3 currentPos = gameObject.transform.position;
                //     int currentBladeStep = 0;

                if (EditorApplication.isPlaying)
                {
                    foreach (DeckardAnimatorMotionBlur ab in animatorObjects)
                    {
                        if (ab.animator == null) ab.animator = ab.gameObject.GetComponent<Animator>();


                        AnimatorClipInfo[] myAnimatorClip = ab.animator.GetCurrentAnimatorClipInfo(0);
                        ab.animatorTime = Time.time;
                        ab.jumpToTime(ab.currentAnimationName(), ab.animatorTime / myAnimatorClip[0].clip.length);
                    }
                }





                if (curentOptimizedSteps < finalSteps * 2f)
                {

                    for (int i = 0; i < batchGroups; i++)
                    {
                        // if (somethingChanged && !overrideEditor) break;
                        UnityEngine.Random.seed = curentOptimizedSteps * curentOptimizedSteps;

                        Shader.SetGlobalFloat("_finalStep", 0f);
                        float angle = UnityEngine.Random.Range(0f, 360f) * Mathf.Deg2Rad;
                        //  angle = UnityEngine.Random.Range(0f, 360f) * Mathf.Deg2Rad;
                        var rand = irisRadius * (Mathf.Clamp01(Mathf.Pow(Mathf.Sqrt(UnityEngine.Random.Range(0f, 1f)), bokehFill))) * Mathf.Lerp(1f, bladeCurvature, Mathf.Abs(Mathf.Sin(angle * (bokehBlades / 2f))));
                        var rand2 = (Mathf.Sqrt(UnityEngine.Random.Range(0f, 1f)));
                        //  rand = Mathf.InverseLerp(0f, irisRadius , rand);

                        float irisRadiusT = rand;
                        float xp = Mathf.Cos(angle) * (irisRadiusT);
                        float yp = Mathf.Sin(angle) * (irisRadiusT) * tiltShift;
                        float xb;
                        float yb;
                        xb = Mathf.Cos(angle) * rand2;
                        yb = Mathf.Sin(angle) * rand2;
                        Shader.SetGlobalVector("_DeckardAngle", new Vector4(xb, yb, 0f, 0f));

                        Shader.SetGlobalFloat("_NoiseMove", UnityEngine.Random.Range(0f, 1f));


                        //gameObject.transform.LookAt(focusPoint, gameObject.transform.up);

                        gameObject.transform.position = Vector3.Lerp(oldPos, pos, (1f / finalSteps) * (curentOptimizedSteps / shutterAngleClamp));
                        gameObject.transform.rotation = Quaternion.Slerp(oldRot, rot, (1f / finalSteps) * (curentOptimizedSteps / shutterAngleClamp));

                        if (timeline == null && UnityEditor.EditorApplication.isPlaying)
                        {
                            gameObject.transform.position = Vector3.Lerp(oldPos, pos, (1f / finalSteps) * (curentOptimizedSteps / shutterAngleClamp));
                            gameObject.transform.rotation = Quaternion.Slerp(oldRot, rot, (1f / finalSteps) * (curentOptimizedSteps / shutterAngleClamp));
                        }



                        SkinMotionBlur();

                        if (EditorApplication.isPlaying)
                        {
                            foreach (DeckardAnimatorMotionBlur ab in animatorObjects)
                            {
                                //         AnimatorStateInfo animationState = ab.animator.GetCurrentAnimatorStateInfo(0);

                                AnimatorClipInfo[] myAnimatorClip = ab.animator.GetCurrentAnimatorClipInfo(0);
                                ab.jumpToTime(ab.currentAnimationName(), Mathf.Lerp(ab.oldAnimatorTime / myAnimatorClip[0].clip.length, ab.animatorTime / myAnimatorClip[0].clip.length, (1f / finalSteps) * (curentOptimizedSteps / shutterAngleClamp)));
                            }
                        }



                        Vector3 relativePos = transform.TransformPoint(new Vector3(0, 0, focusDistance));

                        if (!float.IsNaN(gameObject.transform.position.x))
                        {
                            gameObject.transform.Translate(Vector3.Scale(new Vector3(xp, yp, 0), new Vector3(anamorphicRatio, 1, 1)), Space.Self);
                        }

                        Quaternion targetRotation = Quaternion.LookRotation(relativePos - transform.position, gameObject.transform.up);
                        gameObject.transform.rotation = targetRotation;

                        //   gameObject.transform.LookAt(target.transform, gameObject.transform.up);


                        gameObject.transform.Rotate(new Vector3((aaAngle / finalSteps) * curentOptimizedSteps * antiAliasing * UnityEngine.Random.Range(-0.5f, 0.5f), (aaAngle / finalSteps) * curentOptimizedSteps * antiAliasing * UnityEngine.Random.Range(-0.5f, 0.5f), ((lensVignetteBlur / finalSteps) * lensVignetteBlur * curentOptimizedSteps) - (lensVignetteBlur / 2f)));
                        if (timeline == null)
                        {
                            cam.fieldOfView = Mathf.Lerp(oldCameraFov, cameraFov, (1 / (finalSteps)) * curentOptimizedSteps);
                        }

                        cinePosition = gameObject.transform.position;
                        cineRotation = gameObject.transform.rotation;

                        foreach (DeckardSoftLight l in lights)
                        {
                            if (l.lightL.type == LightType.Directional)
                            {
                                l.transform.rotation = l.GetComponent<DeckardSoftLight>().lightRot;
                                Vector4 rotVec = Shader.GetGlobalVector("_DeckardAngle");
                                //  l.transform.Rotate(new Vector3(UnityEngine.Random.Range((l.lightSize.x / 2) * -1f, (l.lightSize.x / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2))));
                                l.transform.Rotate(new Vector3(UnityEngine.Random.Range((l.lightSize.x / 2) * -1f, (l.lightSize.x / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2)), UnityEngine.Random.Range(0, (360f))));
                                l.SetBias();
                            }

                            if (l.lightL.type == LightType.Spot)
                            {
                                l.transform.position = l.GetComponent<DeckardSoftLight>().lightPos;
                                l.transform.Translate(new Vector3(UnityEngine.Random.Range((l.lightSize.x / 2) * -1f, (l.lightSize.x / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2))), Space.Self);
                                // l.transform.Rotate(new Vector3(0, 0, UnityEngine.Random.Range(0, 360f)));
                                l.SetBias();
                            }

                            if (l.lightL.type == LightType.Point)
                            {
                                l.transform.position = l.GetComponent<DeckardSoftLight>().lightPos;
                                l.transform.Translate(new Vector3(UnityEngine.Random.Range((l.lightSize.x / 2) * -1f, (l.lightSize.x / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2)), UnityEngine.Random.Range((l.lightSize.y / 2) * -1f, (l.lightSize.y / 2))), Space.Self);
                                l.SetBias();
                            }
                        }


                        if (EditorApplication.isPlaying && captureOnPlay)
                        {
                            foreach (DParticleMotionBlur pr in particles)
                            {

                                //p.ps.time = Mathf.Lerp(p.oldTime, p.time, (1 / (finalSteps)) * val);
                                // pr.ps.Simulate(Mathf.Lerp(0, (1f / FPS), (1f / finalSteps) * (val / shutterAngleClamp)) + Time.time, true, true);
                                //  pr.ps.Pause(true);
                                pr.time = Time.time - Shader.GetGlobalVector("_DeckardTime").y;
                                pr.Update();



                            }
                        }



                        if (EditorApplication.isPlaying)
                        {

                            foreach (DeckardObjectMotionBlur m in motionObjects)
                            {
                                m.transform.position = Vector3.Lerp(m.oldPos, m.pos, (1f / finalSteps) * (curentOptimizedSteps / shutterAngleClamp));
                                m.transform.rotation = Quaternion.Slerp(m.oldRot, m.rot, (1f / finalSteps) * (curentOptimizedSteps / shutterAngleClamp));
                            }
                        }

                        foreach (DeckardMultimat m in multimatObjects)
                        {
                            m.renderer.material = m.materials[1];
                        }

                        //      obscuranceAO.radius = (1f / finalSteps) * val;

                        //Set shader timing for motion blur
                        interpolatedTime = Mathf.Lerp(0, (1f / FPS), (1f / (finalSteps * 2f)) * (curentOptimizedSteps / shutterAngleClamp));
                        Shader.SetGlobalVector("_DeckardTime", new Vector4(interpolatedTime / 20, interpolatedTime, interpolatedTime * 2, interpolatedTime * 3));
                        Shader.SetGlobalFloat("_deckardInterpolator", (curentOptimizedSteps + 0f) / (finalSteps * 1f));


                        cam.targetTexture = rt;

                        cam.Render();

                        ready = true;
                        Graphics.Blit(rt, rt2, multipassMat);


                        //    Graphics.Blit(rt, rtTemp, depthMat);
                        Shader.SetGlobalFloat("_finalStep", 1f);

                        gameObject.transform.position = pos;
                        gameObject.transform.rotation = rot;

                        //    cam.targetTexture = null;






                        rt.DiscardContents();
                        currentStep++;
                        curentOptimizedSteps = curentOptimizedSteps + 1;

                        cam.targetTexture = null;
                    }


                }

                else curentOptimizedSteps = 0;

                if (curentOptimizedSteps == 0) Graphics.Blit(rt2, bufferPass);


                if (overrideEditor)
                {
                    CaptureDepth();
                }


                #region render To Screen - Replace After render Loop
                if (active)
                {
                    multipassMat.SetFloat("_step", currentStep);
                    finalPassMat.SetFloat("_NoiseD_A_Amount", noise);
                    finalPassMat.SetFloat("_letterboxing", 1f - letterbox);
                    Shader.SetGlobalTexture("_AperturePass", rt2);
                    Shader.SetGlobalTexture("_DeckardView", rtDW);


                    if (!optimizedSpeedRendering)
                    {
                        finalPassMat.SetFloat("_PreFinalPAss", 0f);
                        Graphics.Blit(rt2, rtDW, finalPassMat);
                        finalPassMat.SetFloat("_PreFinalPAss", 1f);
                        Graphics.Blit(rt2, rtDW, finalPassMat);

                    }

                    else
                    {
                        //Graphics.Blit(rt, rt2, multipassMat);
                        if (curentOptimizedSteps >= finalSteps * 2 && optimizedSpeedRendering)
                        {

                            finalPassMat.SetFloat("_PreFinalPAss", 0f);
                            Graphics.Blit(rt2, rt3, finalPassMat);
                            finalPassMat.SetFloat("_PreFinalPAss", 1f);
                            Graphics.Blit(rt3, rtDW, finalPassMat);
                            //  Graphics.Blit(rtDW, finalPassMat);



                        }
                        else if (optimizedSpeedRendering)
                        {
                            Graphics.Blit(rt2, rt3, finalPassMat);

                            //  Graphics.Blit(rt3, rtDW);

                        }


                    }
                }

                #endregion



                foreach (DeckardSoftLight l in lights)
                {
                    if (l.lightL.type == LightType.Directional)
                    {
                        l.transform.rotation = l.lightRot;
                        l.RestoreBias();
                    }

                    if (l.lightL.type == LightType.Spot)
                    {
                        l.transform.position = l.lightPos;
                        l.transform.rotation = l.lightRot;
                        l.RestoreBias();
                    }

                    if (l.lightL.type == LightType.Point)
                    {
                        l.transform.position = l.lightPos;
                        l.transform.rotation = l.lightRot;
                        l.RestoreBias();
                    }
                }


                foreach (DeckardObjectMotionBlur m in motionObjects)
                {
                    m.oldPos = m.pos;
                    m.oldRot = m.rot;
                    m.transform.position = m.pos;
                    m.transform.rotation = m.rot;
                }




                oldPos = pos;
                oldRot = rot;
                if (timeline == null)
                {
                    oldCameraFov = cameraFov;
                    cam.fieldOfView = cameraFov;
                }
                oldDeckardTime = deckardTime;





                if (EditorApplication.isPlaying)
                {

                    foreach (DeckardAnimatorMotionBlur ab in animatorObjects)
                    {
                        //        AnimatorStateInfo animationState = ab.animator.GetCurrentAnimatorStateInfo(0);
                        AnimatorClipInfo[] myAnimatorClip = ab.animator.GetCurrentAnimatorClipInfo(0);
                        ab.oldAnimatorTime = ab.animatorTime;
                        ab.jumpToTime(ab.currentAnimationName(), ab.animatorTime / myAnimatorClip[0].clip.length);


                    }

                }




                if (overrideEditor)
                {

                    CaptureScreenshot();
                    //   StartCoroutine(CaptureDepth());
                    overrideEditor = false;
                }





                if (EditorApplication.isPlaying && captureOnPlay) RenderVideo();


            }


            else
            {
                DeckardPreprocess pp = gameObject.GetComponent<DeckardPreprocess>();
                if (pp )
                {
                    pp.enabled = false;
                }
            }




        }


        private void OnPreRender()
        {

            if (!captureAudio)
            {
                if (active && !EditorApplication.isPlaying)
                {
                    gameObject.transform.position = cinePosition;
                    gameObject.transform.rotation = cineRotation;
                }
            }
        }

        private void OnPostRender()
        {
            if (active && !EditorApplication.isPlaying)
            {
                gameObject.transform.position = pos;
                gameObject.transform.rotation = rot;
            }
        }

        //void OnRenderImage(RenderTexture source, RenderTexture destination)
        //{

        //    if (active)
        //    {
        //        multipassMat.SetFloat("_step", currentStep);
        //        finalPassMat.SetFloat("_NoiseD_A_Amount", noise);
        //        finalPassMat.SetFloat("_letterboxing", 1f - letterbox);
        //        Shader.SetGlobalTexture("_AperturePass", rt2);
        //        Shader.SetGlobalTexture("_DeckardView", rtDW);


        //        if (!optimizedSpeedRendering)
        //        {
        //            finalPassMat.SetFloat("_PreFinalPAss", 0f);
        //            Graphics.Blit(source, destination, finalPassMat);
        //            finalPassMat.SetFloat("_PreFinalPAss", 1f);
        //            Graphics.Blit(rt2, rtDW, finalPassMat);

        //        }

        //        else
        //        {
        //            Graphics.Blit(rt, destination);
        //            if (curentOptimizedSteps == finalSteps * 2 && optimizedSpeedRendering)
        //            {

        //                finalPassMat.SetFloat("_PreFinalPAss", 1f);
        //                Graphics.Blit(rt2, rtDW, finalPassMat);
        //                finalPassMat.SetFloat("_PreFinalPAss", 0f);
        //                Graphics.Blit(rt2, destination, finalPassMat);



        //            }
        //            else if (optimizedSpeedRendering)
        //            {
        //                Graphics.Blit(source, destination, finalPassMat);
        //                //  Graphics.Blit(rtDW, destination);

        //            }


        //        }
        //    }

        //    else
        //    {
        //        Shader.SetGlobalTexture("_AperturePass", source);
        //        Graphics.Blit(source, destination, finalPassMat);
        //    }

        //}

        void OnGUI()
        {

            //  Graphics.Blit(source, destination, finalPassMat);
            //   GUI.DrawTexture(new Rect(0, 0, Screen.width, Screen.height), rt2, ScaleMode.ScaleToFit, false, 0f);
        }

        public void CaptureScreenshot()
        {

            //about to save an image capture
            Texture2D screenImage = new Texture2D(resolution, resolutionH, TextureFormat.RGB24, false, false);
            // rt3 = new RenderTexture(resolution, resolutionH, 0, RenderTextureFormat.DefaultHDR, RenderTextureReadWrite.Linear);
            rt3 = new RenderTexture(resolution, resolutionH, 0, RenderTextureFormat.Default, RenderTextureReadWrite.sRGB);
            //RenderTexture.active = rt2;
            RenderTexture.active = unfilteredRt;
            BufferPassMat.mainTexture = unfilteredRt;
            BufferPassMat.SetInt("_U", resolution * 2);
            BufferPassMat.SetInt("_V", resolutionH * 2);


            Graphics.Blit(rt2, rt3, finalPassMat);


            RenderTexture.active = rt3;
            //Get Image from screen
            screenImage.ReadPixels(new Rect(0, 0, rt3.width, rt3.height), 0, 0);
            screenImage.Apply();

            //Convert to jpg
            byte[] imageBytes = screenImage.EncodeToJPG(100);


            //Save image to file
            System.IO.File.WriteAllBytes(Application.dataPath + "/image.jpg", imageBytes);

            RenderTexture.active = null;
            // rt3.Release();
        }

        public void CaptureDepth()
        {
            // yield return new WaitForEndOfFrame();
            //about to save an image capture
            Texture2D screenImage = new Texture2D(resolution, resolutionH, TextureFormat.RGB24, false, false);
            RenderTexture temp = new RenderTexture(resolution, resolutionH, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
            Graphics.Blit(rt3, temp, facebookeDepth);
            RenderTexture.active = temp;
            //Get Image from screen

            screenImage.ReadPixels(new Rect(0, 0, resolution, resolutionH), 0, 0);
            screenImage.Apply();

            Debug.Log(" screenImage.width" + screenImage.width + " texelSize" + screenImage.texelSize);
            //Convert to png
            byte[] imageBytes = screenImage.EncodeToJPG(100);

            // Debug.Log("imagesBytes=" + imageBytes.Length);

            //Save image to file
            System.IO.File.WriteAllBytes(Application.dataPath + "/image_depth.jpg", imageBytes);
            Debug.Log("saved to: " + Application.dataPath + "/image_depth.jpg");
            // overrideEditor = false;
        }

        public void VideoRenderPrepare()
        {

            BufferPassMat = Resources.Load("DeckardBuffer", typeof(Material)) as Material;
            BufferQuiltPassMat = Resources.Load("DeckardQuiltBuffer", typeof(Material)) as Material;
            unfilteredRt = new RenderTexture(resolution, resolutionH, 24, RenderTextureFormat.DefaultHDR, RenderTextureReadWrite.Default);

            if (ImageFormatType == VRFormatList.EXR_HDRI)
            {
                rt3 = new RenderTexture(resolution, resolutionH, 0, RenderTextureFormat.DefaultHDR, RenderTextureReadWrite.Linear);
                screenShot = new Texture2D(resolution, resolutionH, TextureFormat.RGBAHalf, false);
            }
            else
            {
                rt3 = new RenderTexture(resolution, resolutionH, 0, RenderTextureFormat.Default, RenderTextureReadWrite.sRGB);
                screenShot = new Texture2D(resolution, resolutionH, TextureFormat.ARGB32, false);
            }



            if (Application.isPlaying)
            {
                Time.captureFramerate = FPS;
                System.IO.Directory.CreateDirectory(fullPath);
            }
            else
            {
                ClearBar();

            }

        }


        //void OnGUI()
        //{
        //    if (EditorApplication.isPlaying && captureOnPlay) GUI.DrawTexture(new Rect(0.0f, 0.0f, Screen.width, Screen.height), rt2, ScaleMode.ScaleToFit, false, 0);
        //}

        public void RenderVideo()
        {
            float sequenceTime = ((float)NumberOfFramesToRender) / (float)FPS;
            int minutesSeq = (int)sequenceTime / 60;
            int secondsSeq = (int)sequenceTime % 60;

            sequenceLength = (minutesSeq + " min. " + secondsSeq + " sec. ");


            if ((Time.frameCount - StartFrame) < NumberOfFramesToRender + 25)

            {



                RenderInfo = "Rendering";
                if ((Time.frameCount - StartFrame) > 0)
                {
                    if ((frame - 25) >= renderFromFrame)
                    {
                        SaveScreenshotVideo();
                    }
                }

                remainingTime = Time.realtimeSinceStartup / (Time.frameCount - StartFrame) * ((NumberOfFramesToRender) - (Time.frameCount - StartFrame));
                minutesRemain = (int)remainingTime / 60;
                secondsRemain = (int)remainingTime % 60;
#if UNITY_EDITOR
                if (UnityEditor.EditorUtility.DisplayCancelableProgressBar("Rendering frame " + (Time.frameCount - 25) + "/" + (NumberOfFramesToRender), " Remaining time: " + minutesRemain + " min. " + secondsRemain + " sec.", (float)(Time.frameCount - StartFrame - 25) / (float)NumberOfFramesToRender))
                {
                    ClearBar();
                    QuitEditor();
                }
#endif
            }

            else
            {
                ClearBar();

                if (openDestinationFolder)
                {

                    System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo()
                    {
                        FileName = fullPath,
                        UseShellExecute = true,
                        Verb = "open"
                    });
                }

                if (encodeToVideo)
                {
                    //string fullPath = Path.GetFullPath(string.Format(@"{0}/", Folder));
                    string ffmpegPath = Application.dataPath + "\\DeckardRender\\StreamingAssets\\";
                    if (System.IO.File.Exists(fullPath + Folder + ".wav"))
                    {


                        System.Diagnostics.Process.Start(ffmpegPath + "ffmpeg", " -f image2" + " -framerate " + FPS + " -i \"" + fullPath + _prefix + "%05d" + formatString + " -i \"" + fullPath + Folder + ".wav" + "\"" + " -r " + FPS + " -vcodec libx264 -tune grain -y -pix_fmt yuv420p -b:v " + Mp4Bitrate + "k" + " -c:a aac -strict experimental -b:a 192k -shortest " + " \"" + fullPath + Folder + ".mp4\"");

                    }
                    else System.Diagnostics.Process.Start(ffmpegPath + "ffmpeg", " -f image2" + " -framerate " + FPS + " -i \"" + fullPath + _prefix + "%05d" + formatString + " -r " + FPS + " -vcodec libx264 -y -pix_fmt yuv420p -b:v " + Mp4Bitrate + "k \"" + fullPath + Folder + ".mp4\"");
                }

                QuitEditor();

            }

        }




        public void SaveScreenshotVideo()
        {

            Texture2D screenShot = GetVideoScreenshot();

            if (ImageFormatType == VRFormatList.JPG)
            {
                byte[] bytes = screenShot.EncodeToJPG(100);
                string filePathh = string.Format(fullPath + _prefix + "{1:D05}.jpg", Folder, (Time.frameCount - StartFrame - 1 - 24));
                formatString = ".jpg\"";
                //    print(filePathh);
                File.WriteAllBytes(filePathh, bytes);
            }

            else if (ImageFormatType == VRFormatList.PNG)
            {
                byte[] bytes = screenShot.EncodeToPNG();
                string filePathh = string.Format(fullPath + _prefix + "{1:D05}.png", Folder, (Time.frameCount - StartFrame - 1 - 24));
                formatString = ".png\"";
                File.WriteAllBytes(filePathh, bytes);
            }

            else if (ImageFormatType == VRFormatList.EXR_HDRI)
            {

                byte[] bytes = screenShot.EncodeToEXR();
                string filePathh = string.Format(fullPath + _prefix + "{1:D05}.exr", Folder, (Time.frameCount - StartFrame - 1 - 24));
                formatString = ".exr\"";
                File.WriteAllBytes(filePathh, bytes);
            }




        }
        #region LightField Rendering

        public void RenderLightField()
        {
            float sequenceTime = ((float)NumberOfFramesToRender) / (float)FPS;
            int minutesSeq = (int)sequenceTime / 60;
            int secondsSeq = (int)sequenceTime % 60;

            sequenceLength = (minutesSeq + " min. " + secondsSeq + " sec. ");


            if ((Time.frameCount - StartFrame) < (NumberOfFramesToRender * lightfieldLayoutX * lightfieldLayoutY) + 25)

            {



                RenderInfo = "Rendering";
                if (((Time.frameCount * lightfieldLayoutX * lightfieldLayoutY) - StartFrame) > 0)
                {
                    if ((frame - 25) >= renderFromFrame)
                    {

                        SaveScreenshotQuilt();
                    }
                }

                remainingTime = Time.realtimeSinceStartup / ((Time.frameCount / (lightfieldLayoutX * lightfieldLayoutY)) - StartFrame) * (((NumberOfFramesToRender)) - ((Time.frameCount / (lightfieldLayoutX * lightfieldLayoutY)) - StartFrame));
                minutesRemain = (int)remainingTime / 60;
                secondsRemain = (int)remainingTime % 60;
#if UNITY_EDITOR
                if (UnityEditor.EditorUtility.DisplayCancelableProgressBar("Rendering frame " + ((Time.frameCount - 25) / (lightfieldLayoutX * lightfieldLayoutY)) + "/" + (NumberOfFramesToRender), " Remaining time: " + minutesRemain + " min. " + secondsRemain + " sec.", (float)((Time.frameCount * lightfieldLayoutX * lightfieldLayoutY) - StartFrame - 25) / (float)NumberOfFramesToRender / (lightfieldLayoutX * lightfieldLayoutY)))
                {
                    ClearBar();
                    QuitEditor();
                }
#endif
            }

            else
            {
                ClearBar();

                if (openDestinationFolder)
                {

                    System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo()
                    {
                        FileName = fullPath,
                        UseShellExecute = true,
                        Verb = "open"
                    });
                }

                if (encodeToVideo)
                {
                    //string fullPath = Path.GetFullPath(string.Format(@"{0}/", Folder));
                    string ffmpegPath = Application.dataPath + "\\DeckardRender\\StreamingAssets\\";
                    if (System.IO.File.Exists(fullPath + Folder + ".wav"))
                    {


                        System.Diagnostics.Process.Start(ffmpegPath + "ffmpeg", " -f image2" + " -framerate " + FPS + " -i \"" + fullPath + _prefix + "%05d" + formatString + " -i \"" + fullPath + Folder + ".wav" + "\"" + " -r " + FPS + " -vcodec libx264 -tune grain -y -pix_fmt yuv420p -b:v " + Mp4Bitrate + "k" + " -c:a aac -strict experimental -b:a 192k -shortest " + " \"" + fullPath + Folder + ".mp4\"");

                    }
                    else System.Diagnostics.Process.Start(ffmpegPath + "ffmpeg", " -f image2" + " -framerate " + FPS + " -i \"" + fullPath + _prefix + "%05d" + formatString + " -r " + FPS + " -vcodec libx264 -y -pix_fmt yuv420p -b:v " + Mp4Bitrate + "k \"" + fullPath + Folder + ".mp4\"");
                }

                QuitEditor();

            }

        }

        public void SaveScreenshotQuilt()
        {



            Texture2D screenShot = GetVideoScreenshotQuilt();

            if (lightfieldStep == (lightfieldLayoutX * lightfieldLayoutY) - 1)
            {
                if (ImageFormatType == VRFormatList.JPG)
                {
                    byte[] bytes = screenShot.EncodeToJPG(100);
                    string filePathh = string.Format(fullPath + _prefix + "{1:D05}.jpg", Folder, ((Time.frameCount - StartFrame - 1 - 24) / (lightfieldLayoutX * lightfieldLayoutY)));
                    formatString = ".jpg\"";
                    //    print(filePathh);
                    File.WriteAllBytes(filePathh, bytes);
                }

                else if (ImageFormatType == VRFormatList.PNG)
                {
                    byte[] bytes = screenShot.EncodeToPNG();
                    string filePathh = string.Format(fullPath + _prefix + "{1:D05}.png", Folder, ((Time.frameCount - StartFrame - 1 - 24) / (lightfieldLayoutX * lightfieldLayoutY)));
                    formatString = ".png\"";
                    File.WriteAllBytes(filePathh, bytes);
                }

                else if (ImageFormatType == VRFormatList.EXR_HDRI)
                {

                    byte[] bytes = screenShot.EncodeToEXR();
                    string filePathh = string.Format(fullPath + _prefix + "{1:D05}.exr", Folder, ((Time.frameCount - StartFrame - 1 - 24) / (lightfieldLayoutX * lightfieldLayoutY)));
                    formatString = ".exr\"";
                    File.WriteAllBytes(filePathh, bytes);
                }
            }



        }

        public Texture2D GetVideoScreenshotQuilt()
        {
            BufferQuiltPassMat.SetVector("_tiles", new Vector4(lightfieldLayoutX, lightfieldLayoutY, 0, 0));


            //   Debug.Log(currenTile);
            BufferQuiltPassMat.SetFloat("_currentTile", lightfieldStep);
            Graphics.Blit(rt2, rt3, BufferQuiltPassMat);
            Debug.Log(lightfieldStep);



            if (lightfieldStep == (lightfieldLayoutX * lightfieldLayoutY) - 1)
            {

                screenShot.ReadPixels(new Rect(0, 0, resolution, resolutionH), 0, 0);
                rt3.Release();
                rtA.Release();
            }

            return screenShot;

        }
        #endregion

        public Texture2D GetVideoScreenshot()
        {


            RenderTexture.active = unfilteredRt;
            BufferPassMat.mainTexture = unfilteredRt;
            BufferPassMat.SetInt("_U", resolution * 2);
            BufferPassMat.SetInt("_V", resolutionH * 2);

            Graphics.Blit(rtDW, rt3, BufferPassMat, -1);

            screenShot.ReadPixels(new Rect(0, 0, resolution, resolutionH), 0, 0);
            rt3.Release();
            if (rtA)
                rtA.Release();

            return screenShot;

        }




        private static IEnumerator SaveFileJPG(string filePathd, Texture2D SShot, int jpg)
        {
            yield return null;
            byte[] bytes = SShot.EncodeToJPG(jpg);
            File.WriteAllBytes(filePathd, bytes);
            // DestroyImmediate(SShot);
        }

        private static IEnumerator SaveFilePNG(string filePathd, Texture2D SShot)
        {
            yield return null;
            byte[] bytes = SShot.EncodeToPNG();
            File.WriteAllBytes(filePathd, bytes);
        }

        private static IEnumerator SaveFileEXRNew(string filePathd, Texture2D SShot)
        {
            yield return null;
            byte[] bytes = SShot.EncodeToEXR();
            File.WriteAllBytes(filePathd, bytes);
        }

        private static IEnumerator SaveFileEXR(string filePathd, Texture2D SShot)
        {
            yield return null;
            byte[] bytes = SShot.EncodeToPNG();
            File.WriteAllBytes(filePathd, bytes);
        }


        public void QuitEditor()
        {

#if UNITY_EDITOR

            UnityEditor.EditorApplication.isPlaying = false;
#endif

        }

        public void ClearBar()
        {

#if UNITY_EDITOR
            UnityEditor.EditorUtility.ClearProgressBar();
#endif
        }

        private void OnDrawGizmos()
        {


            if (Event.current.type == EventType.MouseMove) somethingChanged = true;
            else somethingChanged = false;

        }


        public void LoadLUT()
        {
            switch (filmResponseType)
            {
                // Check one case
                case FilmResponseType.KodakD55:
                    {
                        filmResponseTex = Resources.Load("ColorScience/KodakD55_Texture3D", typeof(Texture)) as Texture;
                    }
                    break;

                case FilmResponseType.KodakD60:
                    {
                        filmResponseTex = Resources.Load("ColorScience/KodakD60_Texture3D", typeof(Texture)) as Texture;
                    }
                    break;

                case FilmResponseType.KodakD65:
                    {
                        filmResponseTex = Resources.Load("ColorScience/KodakD65_Texture3D", typeof(Texture)) as Texture;
                    }
                    break;

                case FilmResponseType.FujiD55:
                    {
                        filmResponseTex = Resources.Load("ColorScience/FujiD55", typeof(Texture)) as Texture;
                    }
                    break;

                case FilmResponseType.FujiD60:
                    {
                        filmResponseTex = Resources.Load("ColorScience/KodakD60_Texture3D", typeof(Texture)) as Texture;
                    }
                    break;

                case FilmResponseType.FujiD65:
                    {
                        filmResponseTex = Resources.Load("ColorScience/KodakD65_Texture3D", typeof(Texture)) as Texture;
                    }
                    break;

                case FilmResponseType.Canon:
                    {
                        filmResponseTex = Resources.Load("ColorScience/Canon_Texture3D", typeof(Texture)) as Texture;
                    }
                    break;

                case FilmResponseType.AlexaARRILogC:
                    {
                        filmResponseTex = Resources.Load("ColorScience/AlexaLogC", typeof(Texture)) as Texture;
                    }
                    break;

                case FilmResponseType.BMPCC4K:
                    {
                        filmResponseTex = Resources.Load("ColorScience/BMPCC4K_Texture3D", typeof(Texture)) as Texture;
                    }
                    break;

                case FilmResponseType.REC709:
                    {
                        filmResponseTex = Resources.Load("ColorScience/Rec709_Texture3D", typeof(Texture)) as Texture;
                    }
                    break;

                case FilmResponseType.Neutral:
                    {
                        filmResponseTex = Resources.Load("ColorScience/Neutral", typeof(Texture)) as Texture;

                    }
                    break;
            }

            multipassMat.SetTexture("_dLUT", filmResponseTex);
            oldFilmResponseType = filmResponseType;
        }

        void CustomProjectionPlane()
        {
            cameraComponent = GetComponent<Camera>();
            if (null != projectionScreen && null != cameraComponent)
            {
                Vector3 pa =
                   projectionScreen.transform.TransformPoint(
                   new Vector3(-5.0f, 0.0f, -5.0f));
                // lower left corner in world coordinates
                Vector3 pb =
                   projectionScreen.transform.TransformPoint(
                   new Vector3(5.0f, 0.0f, -5.0f));
                // lower right corner
                Vector3 pc =
                   projectionScreen.transform.TransformPoint(
                   new Vector3(-5.0f, 0.0f, 5.0f));
                // upper left corner
                Vector3 pe = transform.position;
                // eye position
                float n = cameraComponent.nearClipPlane;
                // distance of near clipping plane
                float f = cameraComponent.farClipPlane;
                // distance of far clipping plane

                Vector3 va; // from pe to pa
                Vector3 vb; // from pe to pb
                Vector3 vc; // from pe to pc
                Vector3 vr; // right axis of screen
                Vector3 vu; // up axis of screen
                Vector3 vn; // normal vector of screen

                float l; // distance to left screen edge
                float r; // distance to right screen edge
                float b; // distance to bottom screen edge
                float t; // distance to top screen edge
                float d; // distance from eye to screen

                vr = pb - pa;
                vu = pc - pa;
                va = pa - pe;
                vb = pb - pe;
                vc = pc - pe;

                // are we looking at the backface of the plane object?
                if (Vector3.Dot(-Vector3.Cross(va, vc), vb) < 0.0)
                {
                    // mirror points along the z axis (most users 
                    // probably expect the x axis to stay fixed)
                    vu = -vu;
                    pa = pc;
                    pb = pa + vr;
                    pc = pa + vu;
                    va = pa - pe;
                    vb = pb - pe;
                    vc = pc - pe;
                }

                vr.Normalize();
                vu.Normalize();
                vn = -Vector3.Cross(vr, vu);
                // we need the minus sign because Unity 
                // uses a left-handed coordinate system
                vn.Normalize();

                d = -Vector3.Dot(va, vn);
                if (setNearClipPlane)
                {
                    n = d + nearClipDistanceOffset;
                    cameraComponent.nearClipPlane = n;
                }
                l = Vector3.Dot(vr, va) * n / d;
                r = Vector3.Dot(vr, vb) * n / d;
                b = Vector3.Dot(vu, va) * n / d;
                t = Vector3.Dot(vu, vc) * n / d;

                Matrix4x4 p = new Matrix4x4(); // projection matrix 
                p[0, 0] = 2.0f * n / (r - l);
                p[0, 1] = 0.0f;
                p[0, 2] = (r + l) / (r - l);
                p[0, 3] = 0.0f;

                p[1, 0] = 0.0f;
                p[1, 1] = 2.0f * n / (t - b);
                p[1, 2] = (t + b) / (t - b);
                p[1, 3] = 0.0f;

                p[2, 0] = 0.0f;
                p[2, 1] = 0.0f;
                p[2, 2] = (f + n) / (n - f);
                p[2, 3] = 2.0f * f * n / (n - f);

                p[3, 0] = 0.0f;
                p[3, 1] = 0.0f;
                p[3, 2] = -1.0f;
                p[3, 3] = 0.0f;

                Matrix4x4 rm = new Matrix4x4(); // rotation matrix;
                rm[0, 0] = vr.x;
                rm[0, 1] = vr.y;
                rm[0, 2] = vr.z;
                rm[0, 3] = 0.0f;

                rm[1, 0] = vu.x;
                rm[1, 1] = vu.y;
                rm[1, 2] = vu.z;
                rm[1, 3] = 0.0f;

                rm[2, 0] = vn.x;
                rm[2, 1] = vn.y;
                rm[2, 2] = vn.z;
                rm[2, 3] = 0.0f;

                rm[3, 0] = 0.0f;
                rm[3, 1] = 0.0f;
                rm[3, 2] = 0.0f;
                rm[3, 3] = 1.0f;

                Matrix4x4 tm = new Matrix4x4(); // translation matrix;
                tm[0, 0] = 1.0f;
                tm[0, 1] = 0.0f;
                tm[0, 2] = 0.0f;
                tm[0, 3] = -pe.x;

                tm[1, 0] = 0.0f;
                tm[1, 1] = 1.0f;
                tm[1, 2] = 0.0f;
                tm[1, 3] = -pe.y;

                tm[2, 0] = 0.0f;
                tm[2, 1] = 0.0f;
                tm[2, 2] = 1.0f;
                tm[2, 3] = -pe.z;

                tm[3, 0] = 0.0f;
                tm[3, 1] = 0.0f;
                tm[3, 2] = 0.0f;
                tm[3, 3] = 1.0f;

                // set matrices
                cameraComponent.projectionMatrix = p;
                cameraComponent.worldToCameraMatrix = rm * tm;
                // The original paper puts everything into the projection 
                // matrix (i.e. sets it to p * rm * tm and the other 
                // matrix to the identity), but this doesn't appear to 
                // work with Unity's shadow maps.

                if (estimateViewFrustum)
                {
                    // rotate camera to screen for culling to work
                    Quaternion q = new Quaternion();
                    q.SetLookRotation((0.5f * (pb + pc) - pe), vu);
                    // look at center of screen
                    cameraComponent.transform.rotation = q;

                    // set fieldOfView to a conservative estimate 
                    // to make frustum tall enough
                    if (cameraComponent.aspect >= 1.0)
                    {
                        cameraComponent.fieldOfView = Mathf.Rad2Deg *
                           Mathf.Atan(((pb - pa).magnitude + (pc - pa).magnitude)
                           / va.magnitude);
                    }
                    else
                    {
                        // take the camera aspect into account to 
                        // make the frustum wide enough 
                        cameraComponent.fieldOfView =
                           Mathf.Rad2Deg / cameraComponent.aspect *
                           Mathf.Atan(((pb - pa).magnitude + (pc - pa).magnitude)
                           / va.magnitude);
                    }
                }
            }
        }


        public void LoadFilmSize()
        {
            switch (enumFilmSize)
            {
                // Check one case
                case FilmSize.IMAX:
                    {
                        filmSize = 87.91f;
                    }
                    break;

                case FilmSize._35mm:
                    {
                        filmSize = 35f;
                    }
                    break;

                case FilmSize.HasselbladMediumFormat:
                    {
                        filmSize = 87.91f;
                    }
                    break;

                case FilmSize.APS_C:
                    {
                        filmSize = 23.6f;
                    }
                    break;

                case FilmSize.MicroFourThirds:
                    {
                        filmSize = 17.3f;
                    }
                    break;

                case FilmSize._16mm:
                    {
                        filmSize = 10.26f;
                    }
                    break;

                case FilmSize.S9:
                    {
                        filmSize = 5.5f;
                    }
                    break;

                case FilmSize.iPhone:
                    {
                        filmSize = 4.80f;
                    }
                    break;
                case FilmSize.Custom:
                    {
                        filmSize = customFilmSize;
                    }
                    break;






            }


            OldEnumFilmSize = enumFilmSize;
        }


        void StartWriting(string name)
        {
            fileStream = new FileStream(name, FileMode.Create);
            byte emptyByte = new byte();

            for (int i = 0; i < headerSize; i++) //preparing the header
            {
                fileStream.WriteByte(emptyByte);
            }
        }

        void OnAudioFilterRead(float[] data, int channels)
        {
            if (recOutput)
            {
                if (ambisonics && ambisonicsSupportTest)
                {

                    for (int i = 0; i < data.Length; i += 4)
                    {
                        float fl = data[i];
                        float fr = data[i + 1];
                        float rl = data[i + 2];
                        float rr = data[i + 3];
                        //	Alternative mormalization mode
                        //						float frontSum = fl + fr;
                        //						float backSum = rl + rr;
                        //						float frontDiff = fl - fr;
                        //						float backDiff = rl - rr;

                        //			float w = (frontSum / 1.414214f + backSum)/4.828427f;
                        //			float ch2 = (frontSum - backSum) / 2.414214f;
                        //			float ch3 = (frontDiff + backDiff) / 3.146264f;
                        //			float ch4 = 0;


                        float w = 0.5f * (fl + rl + fr + rr);
                        float x = 0.5f * ((fl - rl) + (fr - rr));
                        float y = 0.5f * ((fl - rr) - (fr - rl));
                        float z = 0.5f * ((fl - rl) + (rr - fr));




                        data[i] = w;
                        data[i + 1] = y;
                        data[i + 2] = z;
                        data[i + 3] = x;
                    }
                }



                ConvertAndWrite(data);
            }
        }

        void ConvertAndWrite(float[] dataSource)
        {

            Int16[] intData = new Int16[dataSource.Length];


            Byte[] bytesData = new Byte[dataSource.Length * 2];


            int rescaleFactor = 32767;

            for (int i = 0; i < dataSource.Length; i++)
            {
                intData[i] = (short)(dataSource[i] * rescaleFactor);
                Byte[] byteArr = new Byte[2];
                byteArr = BitConverter.GetBytes(intData[i]);
                byteArr.CopyTo(bytesData, i * 2);
            }

            fileStream.Write(bytesData, 0, bytesData.Length);
        }

        void WriteHeader()
        {

            fileStream.Seek(0, SeekOrigin.Begin);

            Byte[] riff = System.Text.Encoding.UTF8.GetBytes("RIFF");
            fileStream.Write(riff, 0, 4);

            Byte[] chunkSize = BitConverter.GetBytes(fileStream.Length - 8);
            fileStream.Write(chunkSize, 0, 4);

            Byte[] wave = System.Text.Encoding.UTF8.GetBytes("WAVE");
            fileStream.Write(wave, 0, 4);

            Byte[] fmt = System.Text.Encoding.UTF8.GetBytes("fmt ");
            fileStream.Write(fmt, 0, 4);

            Byte[] subChunk1 = BitConverter.GetBytes(16);
            fileStream.Write(subChunk1, 0, 4);

            //		UInt16 two = 2;
            UInt16 one = 1;
            UInt16 six = achannels;

            Byte[] audioFormat = BitConverter.GetBytes(one);
            fileStream.Write(audioFormat, 0, 2);

            Byte[] numChannels = BitConverter.GetBytes(six);
            fileStream.Write(numChannels, 0, 2);

            Byte[] sampleRate = BitConverter.GetBytes(outputRate);
            fileStream.Write(sampleRate, 0, 4);

            Byte[] byteRate = BitConverter.GetBytes(outputRate * 2 * achannels);


            fileStream.Write(byteRate, 0, 4);

            UInt16 four = (UInt16)(achannels + achannels);
            Byte[] blockAlign = BitConverter.GetBytes(four);
            fileStream.Write(blockAlign, 0, 2);

            UInt16 sixteen = 16;
            Byte[] bitsPerSample = BitConverter.GetBytes(sixteen);
            fileStream.Write(bitsPerSample, 0, 2);

            Byte[] dataString = System.Text.Encoding.UTF8.GetBytes("data");
            fileStream.Write(dataString, 0, 4);

            Byte[] subChunk2 = BitConverter.GetBytes(fileStream.Length - headerSize);
            fileStream.Write(subChunk2, 0, 4);

            fileStream.Close();
        }



#endif
    }

}

