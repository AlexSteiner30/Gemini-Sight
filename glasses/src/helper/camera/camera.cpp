#include "esp_camera.h"
#include "glasses.hpp"

#define CAMERA_MODEL_XIAO_ESP32S3 
#include "camera_pins.h"

/**
 * Initialize camera
 */
void Glasses::setup_camera() {
  Serial.begin(115200);
  Serial.setDebugOutput(true);
  Serial.println();

  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sccb_sda = SIOD_GPIO_NUM;
  config.pin_sccb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.frame_size = FRAMESIZE_WQXGA;
  config.pixel_format = PIXFORMAT_JPEG;  
  config.grab_mode = CAMERA_GRAB_LATEST;
  config.fb_location = CAMERA_FB_IN_PSRAM;
  config.jpeg_quality = 0;
  config.fb_count = 2;

  // camera init
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    return;
  }

  sensor_t *s = esp_camera_sensor_get();
  // initial sensors are flipped vertically and colors are a bit saturated
  if (s->id.PID == OV3660_PID) {
    s->set_vflip(s, 1);        // flip it back
    s->set_brightness(s, 1);   // up the brightness just a bit
    s->set_saturation(s, -2);  // lower the saturation
  }
}

/**
 * Take picture and send over to dart ws
*/
void Glasses::take_picture(){
  camera_fb_t *fb = NULL;
  esp_err_t res = ESP_OK;

  fb = esp_camera_fb_get();

  if(!fb){
    Serial.println("Camera capture failed");
    invoke_error("Camera capture failed");
    esp_camera_fb_return(fb);
    return;
  }

  string textMessage = "take_picture|" + string(AUTH_KEY)+ "|";

  size_t textSize = textMessage.length();
  size_t totalSize = textSize + fb->len;

  uint8_t* combinedBuffer = new uint8_t[totalSize];

  memcpy(combinedBuffer, textMessage.c_str(), textSize);
  memcpy(combinedBuffer + textSize, fb->buf, fb->len);

  client.sendBIN(combinedBuffer, totalSize);

  delete[] combinedBuffer;
  esp_camera_fb_return(fb);    
}

/** 
 * Record video, send frames to dart ws while is_recording
 * Then stop recording and send stop message to dart ws
*/
void Glasses::record_video() {
  camera_fb_t *fb = NULL;
  esp_err_t res = ESP_OK;
    
  string textMessage = "record_video|" + string(AUTH_KEY) + "|";
  size_t textSize = textMessage.length();
    
  while (is_recording) {
    fb = esp_camera_fb_get();
    if (!fb) {
      Serial.println("Camera capture failed");
      invoke_error("Camera capture failed");
      continue;
    }
        
    size_t totalSize = textSize + fb->len;
    uint8_t* combinedBuffer = new uint8_t[totalSize];
    memcpy(combinedBuffer, textMessage.c_str(), textSize);
    memcpy(combinedBuffer + textSize, fb->buf, fb->len);
        
    client.sendBIN(combinedBuffer, totalSize);
        
    delete[] combinedBuffer;
    esp_camera_fb_return(fb);
  }
    
  string endMessage = "stop_recording|" + string(AUTH_KEY) + "|";
  client.sendBIN((uint8_t*)endMessage.c_str(), endMessage.length());
}