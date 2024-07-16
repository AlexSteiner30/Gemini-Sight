#include <WebSocketsClient.h>

#include "helper/microphone/microphone.hpp"
#include "helper/camera/camera.hpp"
#include "helper/audio/audio.hpp"

#include "helper/wifi.hpp"
#include "helper/helper.hpp"

#include "helper/wake_word/wake_word.h"

WebSocketsClient client;

const char* AUTH_KEY = "9e323100603908714f50f2a254cbf3cab972d40361d83f53dce0d214cc0df1707e1cb0c7c7bd98c4e2135d16abf79527de834abdbeff2ba2bcaa57c82a187dea2306e670a03803374a8d325956961f280350e727e8822f7ae973541f895a6a9e0c5fadc3e15afaa19d583dd50c89ca8d7a8b82713f17d276c4ee4cd5f1831000";

bool isConnected = false;
bool isTalking = false;
int volume = 100;

void micTask() {
  isTalking = true;
  size_t bytesRead = 0;

  while (bytesRead < TOTAL_SAMPLES * SAMPLE_SIZE && isTalking) {
    size_t bytesIn = 0;
    esp_err_t result = i2s_read(I2S_PORT, audioBuffer + (bytesRead / SAMPLE_SIZE), TOTAL_SAMPLES * SAMPLE_SIZE - bytesRead, &bytesIn, portMAX_DELAY);
    if (result == ESP_OK) {
      bytesRead += bytesIn;
    }
  }

  string textMessage = "speech_to_text¬" + string(AUTH_KEY)+ "¬";

  size_t textSize = textMessage.length();
  size_t totalSize = textSize + TOTAL_SAMPLES * SAMPLE_SIZE;

  uint8_t* combinedBuffer = new uint8_t[totalSize];

  memcpy(combinedBuffer, textMessage.c_str(), textSize);
  memcpy(combinedBuffer + textSize, audioBuffer, TOTAL_SAMPLES * SAMPLE_SIZE);

  client.sendBIN(combinedBuffer, totalSize);

  delete[] combinedBuffer;

  audioBuffer = (int16_t*)malloc(TOTAL_SAMPLES * SAMPLE_SIZE);
}

void take_picture(){
  camera_fb_t *fb = NULL;
  esp_err_t res = ESP_OK;

  fb = esp_camera_fb_get();

  if(!fb){
    Serial.println("Camera capture failed");
    esp_camera_fb_return(fb);
    return;
  }

  string textMessage = "take_picture¬" + string(AUTH_KEY)+ "¬";

  size_t textSize = textMessage.length();
  size_t totalSize = textSize + fb->len;

  uint8_t* combinedBuffer = new uint8_t[totalSize];

  memcpy(combinedBuffer, textMessage.c_str(), textSize);
  memcpy(combinedBuffer + textSize, fb->buf, fb->len);

  client.sendBIN(combinedBuffer, totalSize);

  delete[] combinedBuffer;
  esp_camera_fb_return(fb);    
}