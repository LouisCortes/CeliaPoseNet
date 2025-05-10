using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UltraFace;
using UnityEngine;


namespace OscSimpl.Examples
{
	public class SedingOscSpout : MonoBehaviour
	{
		[SerializeField] OscOut _oscOut;

        public GameObject GO;

		OscMessage _message2; // Cached message.
        
        private int Nbr_portOut;
        //"nose",lefteye, right eye, left ear, right ear, "leftShoulder", "rightShoulder", "leftElbow", "rightElbow", "leftWrist", "rightWrist", "leftHip", "rightHip", "leftKnee", "rightKnee", "leftAnkle", "rightAnkle"

        public string address1 = "/p";
        public string address2 = "/pnb";
        public string address3 = "/pGeneral";
        public PoseNetCompo script;
        private string LocalIPTarget;
        void Start()
		{
            LocalIPTarget = _oscOut.remoteIpAddress;
            Nbr_portOut = _oscOut.port;
            if ( !_oscOut ) _oscOut = gameObject.AddComponent<OscOut>();
            _oscOut.Open(Nbr_portOut, LocalIPTarget);
           


        }

        void Update()
        {
            if (script != null)
            {
                List<float> allPersonMessageData = new List<float>();
                List<float> generalData = new List<float>();

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
                        generalData.Add(hipCenter.y);
                        generalData.Add(footCenterY);

                      //  Vector3 pos = GO.transform.position;
                      //  pos.x = hipCenter.x;
                       // GO.transform.position = pos;
                    }
                }

                // Send pose data (address1)
                if (allPersonMessageData.Count > 0)
                {
                    _oscOut.Send(address1, allPersonMessageData.Cast<object>().ToArray());
                }

                // Send number of people (address2)
                _oscOut.Send(address2, script.pers.Count(p => p > 0.4f));

                // Send general pose summary (address3)
                if (generalData.Count > 0)
                {
                    _oscOut.Send(address3, generalData.Cast<object>().ToArray());
                }


                if (generalData != null && generalData.Count > 0)
                {
                    // Crée un cube
                    GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);

                    // Récupère la position X de la première valeur du tableau
                    //float xPosition = generalData[0].x;
                    float xPosition = script.posePositionsArray[0][0].x;

                    // Positionne le cube (en gardant Y et Z à 0)
                    cube.transform.position = new Vector3(xPosition, 0f, 13f);
                }
                else
                {
                    Debug.LogWarning("Le tableau 'positions' est vide ou nul.");
                }


            }
        }


    }
}