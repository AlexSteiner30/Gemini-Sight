#include "camera_recording.h"

CameraRecording::CameraRecording(){
  setup_camera();
}

void CameraRecording::take_picture(Glasses glasses){
  camera_fb_t *fb = NULL;
  esp_err_t res = ESP_OK;

  fb = esp_camera_fb_get();

  if(!fb){
    Serial.println("Camera capture failed");
    esp_camera_fb_return(fb);
    return;
  }

  string textMessage = "take_picture¬" + string(glasses.AUTH_KEY)+ "¬";

  size_t textSize = textMessage.length();
  size_t totalSize = textSize + fb->len;

  uint8_t* combinedBuffer = new uint8_t[totalSize];

  memcpy(combinedBuffer, textMessage.c_str(), textSize);
  memcpy(combinedBuffer + textSize, fb->buf, fb->len);

  glasses.client.sendBIN(combinedBuffer, totalSize);

  delete[] combinedBuffer;
  esp_camera_fb_return(fb);    
}