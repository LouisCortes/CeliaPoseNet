using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PersPos : MonoBehaviour
{

    public PoseNetCompo script;

    public GameObject GO;
    public float RandomY = 0.5f;    


    [Header("Zone posenet")]
    public float inputMin;
    public float inputMax;

    [Header("Zone desifnition")]
    public float outputMin;
    public float outputMax;

    [Header("Source")]
    //public float[] posePositionsArray;
    public float hipCenterX = 0f;

    [Header("Smoothing")]
    public float smoothSpeed = 5f;

    [Header("Stability Filter")]
    public float delayThreshold = 0.5f;

    [Header("Outlier Filter")]
    public bool excludeOutliers = true;
    public float positionThreshold = 0.1f;

    public float persistAfterInactive = 0.5f;
    private float[] deactivationTimers;

    public float[] positions; // Construit dynamiquement à partir de posePositionsArray
    private float[] activationTimers;
    private List<GameObject> cubes = new List<GameObject>();
    private List<float> smoothedX = new List<float>();

    void Start()
    {

    }

    void Update()
    {

        // positions = script.posePositionsArray

        if (script != null)
        {/*
            List<float> allPersonMessageData = new List<float>();
           // List<float> generalData = new List<float>();

            for (int i = 0; i < script.posePositionsArray.Length; i++)
            {
                if (script.pers[i] > 0.4f)
                {
                    // Send all pose points (address1)
                    for (int j = 0; j < script.posePositionsArray[i].Length; j++)
                    {
                        allPersonMessageData.Add(script.posePositionsArray[i][j].x);
                        allPersonMessageData.Add(script.posePositionsArray[i][j].y);
                    }

                    // Get hip center
                    Vector3 leftHip = script.posePositionsArray[i][11];
                    Vector3 rightHip = script.posePositionsArray[i][12];
                    Vector2 hipCenter = (leftHip + rightHip) * 0.5f;

                    // Get foot center (just for Y)
                    Vector3 leftFoot = script.posePositionsArray[i][15];
                    Vector3 rightFoot = script.posePositionsArray[i][16];
                    float footCenterY = (leftFoot.y + rightFoot.y) * 0.5f;

                    // Add to generalData
                    generalData.Add(hipCenter.x);
                  //  generalData.Add(hipCenter.y);
                  //  generalData.Add(footCenterY);

                }
            }

            // Send pose data (address1)
            if (allPersonMessageData.Count > 0)
            {
            //    _oscOut.Send(address1, allPersonMessageData.Cast<object>().ToArray());
            }

            // Send number of people (address2)
           // _oscOut.Send(address2, script.pers.Count(p => p > 0.4f));

            // Send general pose summary (address3)
            if (generalData.Count > 0)
            {
              //  _oscOut.Send(address3, generalData.Cast<object>().ToArray());***************************
            }
            */

            if (script.pers == null) return;

            // Initialiser les timers d'activation si taille change
            if (activationTimers == null || activationTimers.Length != script.pers.Length)
                activationTimers = new float[script.pers.Length];
                deactivationTimers = new float[script.pers.Length];

            // Construire la liste des positions valides (≠ 0, après délai, avec filtre)
            List<float> validPositions = new List<float>();


            for (int i = 0; i < script.pers.Length; i++)
            {
                float val = script.pers[i];

                if (val > 0.11f)
                {
                    activationTimers[i] += Time.deltaTime;
                    deactivationTimers[i] = 0f;

                    if (activationTimers[i] >= delayThreshold)
                    {
                        // Appliquer filtre de distance si activé
                        if (excludeOutliers)
                        {
                            int index = validPositions.Count;

                            bool passesOutlierCheck = true;

                            if (excludeOutliers && index < smoothedX.Count)
                            {
                                passesOutlierCheck = Mathf.Abs(hipCenterX - smoothedX[index]) < positionThreshold;
                            }

                            if (passesOutlierCheck)
                            {
                                validPositions.Add(val);
                            }
                        }
                        else
                        {
                            validPositions.Add(val);
                        }
                    }
                }
                else
                {
                    activationTimers[i] = 0f;
                    deactivationTimers[i] = 0f;

                    if (deactivationTimers[i] <= persistAfterInactive && i < cubes.Count)
                    {
                        validPositions.Add(0.01f); // Maintenir temporairement le cube existant
                    }
                }
            }

            // Mettre à jour positions[]
            positions = validPositions.ToArray();

            // Boucle centrale sur positions.Length
            for (int i = 0; i < positions.Length; i++)
            {
                Vector3 leftHip = script.posePositionsArray[i][11];
                Vector3 rightHip = script.posePositionsArray[i][12];
                Vector2 hipCenter = (leftHip + rightHip) * 0.5f;
                float newHip = Remap(hipCenter.x, inputMin, inputMax, outputMin, outputMax);
                // Créer le cube s'il n'existe pas encore
                if (i >= cubes.Count)
                {
                    GameObject cube = Instantiate(GO);
                    float y = i + Random.Range(-RandomY,RandomY);
                    cube.transform.position = new Vector3(newHip, y, 0f);
                    cubes.Add(cube);
                    smoothedX.Add(newHip);
                }

                // Appliquer le smoothing de la position X
                float smoothX = Mathf.Lerp(smoothedX[i], newHip, Time.deltaTime * smoothSpeed);
                smoothedX[i] = smoothX;

                // Mise à jour position du cube
                Vector3 pos = cubes[i].transform.position;
                cubes[i].transform.position = new Vector3(smoothX, pos.y, pos.z);
            }

            // Supprimer les cubes en trop
            while (cubes.Count > positions.Length)
            {
                Destroy(cubes[cubes.Count - 1]);
                cubes.RemoveAt(cubes.Count - 1);
                smoothedX.RemoveAt(smoothedX.Count - 1);
            }
        }
    }
        // Mettre à jour les positions des cubes
        /* for (int i = 0; i < positions.Length; i++)
         {
             // Get hip center
             Vector3 leftHip = script.posePositionsArray[i][11];
             Vector3 rightHip = script.posePositionsArray[i][12];
             Vector2 hipCenter = (leftHip + rightHip) * 0.5f;

             positions[i] = hipCenter.x;
             // float targetX = Remap(positions[i], inputMin, inputMax, outputMin, outputMax);

             float smoothX = Mathf.Lerp(smoothedX[i], hipCenterX, Time.deltaTime * smoothSpeed);
             smoothedX[i] = smoothX;

             // Appliquer un lissage
             //float smoothedX = Mathf.Lerp(lastValidX[i], targetX, Time.deltaTime * smoothSpeed);
             //lastValidX[i] = smoothedX;

             Vector3 pos = cubes[i].transform.position;
             cubes[i].transform.position = new Vector3(smoothX, pos.y, pos.z);
         }*/

            // Met à jour la position X de chaque cube (en temps réel)
            /* for (int i = 0; i < positions.Length; i++)
             {

                 // Get hip center
                 Vector3 leftHip = script.posePositionsArray[i][11];
                 Vector3 rightHip = script.posePositionsArray[i][12];
                 Vector2 hipCenter = (leftHip + rightHip) * 0.5f;

                 positions[i] = hipCenter;
                 //float newX = Remap(((script.Positions[i][11] + Positions[i][12]) * 0.5f).x, inputMin, inputMax, outputMin, outputMax);
                 float newX = Remap(positions[i].x, inputMin, inputMax, outputMin, outputMax);
                 //script.posePositionsArray
                 if (excludeOutliers && Mathf.Abs(newX - lastValidX[i]) > positionThreshold)
                 {
                     // Ignore cette valeur — bruit probable
                     continue;
                 }

                 // Mise à jour de la valeur validée
                 lastValidX[i] = newX;

                 // Position cible
                 Vector3 currentPos = cubes[i].transform.position;
                 Vector3 targetPos = new Vector3(newX, currentPos.y, currentPos.z);
                 cubes[i].transform.position = Vector3.Lerp(currentPos, targetPos, Time.deltaTime * smoothSpeed);

             }

               if(cubes != null)
               {
                   Vector3 PersPosition = hipCenter.x * multiplier;

                   float x = RemapClamped(PosnetPos.x, PosnetMin.x, posnetMax.x, worldMin.x, worldMax.x);

                   Vector3 targetPos = new Vector3(x, y, z);
                   targetObject.position = Vector3.Lerp(cubes[i].position, targetPos, Time.deltaTime * smoothSpeed);

                   // Reset du timer de retour
                   nobodyTimer = 0f;
                   PersonWasPresentLastFrame = true;
               }*/

            /*
            if (generalData != null && generalData.Count > 0)
            {
                // Crée un cube
                GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);

                // Récupère la position X de la première valeur du tableau
                //float xPosition = generalData[0].x;
                float xPosition = script.posePositionsArray[0][0].x;

                // Positionne le cube (en gardant Y et Z à 0)
                cube.transform.position = new Vector3(xPosition, 0f, 13f);
            }*/

        //}
    

    float Remap(float value, float inMin, float inMax, float outMin, float outMax)
    {
        return Mathf.Lerp(outMin, outMax, Mathf.InverseLerp(inMin, inMax, value));
    }
}

