using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PoseSkeleton
{
    // The list of key point GameObjects that make up the pose skeleton
    public Vector3[] keypoints;

    // Declare MissingKeypoint as readonly
    private  Vector3 MissingKeypoint = new Vector3(0,0,0);

    // The names of the body parts that will be detected by the PoseNet model
    private static string[] partNames = new string[]{
        "nose", "leftEye", "rightEye", "leftEar", "rightEar", "leftShoulder",
        "rightShoulder", "leftElbow", "rightElbow", "leftWrist", "rightWrist",
        "leftHip", "rightHip", "leftKnee", "rightKnee", "leftAnkle", "rightAnkle"
    };

    private static int NUM_KEYPOINTS = partNames.Length;

    // The pairs of key points that should be connected on a body

    public PoseSkeleton()
    {
        this.keypoints = new Vector3[NUM_KEYPOINTS];
        // Initialize key points to zero vector or any default value if needed
        for (int i = 0; i < NUM_KEYPOINTS; i++)
        {
            this.keypoints[i] = Vector3.zero;
        }
    }

    // Add a getter method for keypoints
    public Vector3[] GetKeyPoints()
    {
        return keypoints;
    }

    public void UpdateKeyPointPositions(Utils.Keypoint[] keypoints, Vector2Int imageDims)
    {
        for (int k = 0; k < keypoints.Length; k++)
        {
            if (keypoints[k].score >0.0f)
            {
                Vector2 coords = keypoints[k].position/ imageDims;
                this.keypoints[k] = new Vector3(coords.x, 1 - coords.y, keypoints[k].score);
            }
            else
            {
                this.keypoints[k] = MissingKeypoint;
            }  
           
        }
    }
}
