using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetCam : MonoBehaviour
{
    public Texture tex;
    public Material mat;
    void Start()
    {
      
    }

    // Update is called once per frame
    void Update()
    {
        tex = mat.GetTexture("_MainTex");
    }
}
