
using UnityEngine;
using RenderHeads.Media.AVProLiveCamera;

public class CameraSetup : MonoBehaviour
{
    [Range(0f,1f)]
    public float Gain = 0;
    void Start()
   // void Update()
    {
        AVProLiveCameraDevice LiveCamera = AVProLiveCameraManager.Instance.GetDevice(0);
        AVProLiveCameraDevice LiveCamera2 = AVProLiveCameraManager.Instance.GetDevice(1);
        AVProLiveCameraDevice LiveCamera3 = AVProLiveCameraManager.Instance.GetDevice(2);
        AVProLiveCameraDevice LiveCamera4 = AVProLiveCameraManager.Instance.GetDevice(3);

        for (int j = 0; j < LiveCamera.NumSettings; j++)
        {
            AVProLiveCameraSettingBase settingBase = LiveCamera.GetVideoSettingByIndex(j);
            settingBase.IsAutomatic = false;
            settingBase.SetDefault();
            AVProLiveCameraSettingBase settingBase2 = LiveCamera2.GetVideoSettingByIndex(j);
            settingBase2.IsAutomatic = false;
            settingBase2.SetDefault();
            AVProLiveCameraSettingBase settingBase3 = LiveCamera3.GetVideoSettingByIndex(j);
            settingBase3.IsAutomatic = false;
            settingBase3.SetDefault();
            AVProLiveCameraSettingBase settingBase4 = LiveCamera4.GetVideoSettingByIndex(j);
            settingBase4.IsAutomatic = false;
            settingBase4.SetDefault();

        }

    }
     void Update()
    {
        AVProLiveCameraDevice LiveCamera = AVProLiveCameraManager.Instance.GetDevice(0);
        AVProLiveCameraSettingBase gainSetting = LiveCamera.GetVideoSettingByIndex(6);
        AVProLiveCameraSettingFloat settingFloat = (AVProLiveCameraSettingFloat)gainSetting;
        settingFloat.CurrentValue = 70 * Gain;
        AVProLiveCameraDevice LiveCamera2 = AVProLiveCameraManager.Instance.GetDevice(1);
        AVProLiveCameraSettingBase gainSetting2 = LiveCamera2.GetVideoSettingByIndex(6);
        AVProLiveCameraSettingFloat settingFloat2 = (AVProLiveCameraSettingFloat)gainSetting2;
        settingFloat2.CurrentValue = 70 * Gain;
        AVProLiveCameraDevice LiveCamera3 = AVProLiveCameraManager.Instance.GetDevice(2);
        AVProLiveCameraSettingBase gainSetting3 = LiveCamera3.GetVideoSettingByIndex(6);
        AVProLiveCameraSettingFloat settingFloat3 = (AVProLiveCameraSettingFloat)gainSetting3;
        settingFloat3.CurrentValue = 70 * Gain;
        AVProLiveCameraDevice LiveCamera4 = AVProLiveCameraManager.Instance.GetDevice(3);
        AVProLiveCameraSettingBase gainSetting4 = LiveCamera4.GetVideoSettingByIndex(6);
        AVProLiveCameraSettingFloat settingFloat4 = (AVProLiveCameraSettingFloat)gainSetting4;
        settingFloat4.CurrentValue = 70 * Gain;
        

        /*if(Time.time>0.1f)
        {
            LiveCamera.UpdateSettings = false;
            LiveCamera2.UpdateSettings = false;
            LiveCamera3.UpdateSettings = false;
        } */

    }
}