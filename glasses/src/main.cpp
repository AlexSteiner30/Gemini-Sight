#include <WebSocketsClient.h>
#include <driver/i2s.h>
#include "helper/camera/camera.hpp"
#include "helper/microphone.hpp"
#include "helper/wifi.hpp"
#include "helper/helper.hpp"

const char* AUTH_KEY = "9e323100603908714f50f2a254cbf3cab972d40361d83f53dce0d214cc0df1707e1cb0c7c7bd98c4e2135d16abf79527de834abdbeff2ba2bcaa57c82a187dea2306e670a03803374a8d325956961f280350e727e8822f7ae973541f895a6a9e0c5fadc3e15afaa19d583dd50c89ca8d7a8b82713f17d276c4ee4cd5f1831000";

WebSocketsClient client;
bool isConnected = false;
bool isTalking = false;
int volume = 100;

void micTask(void* parameter) {
  i2s_install();
  i2s_setpin();
  i2s_start(I2S_PORT);

  isTalking = true;
  size_t bytesRead = 0;
  while (bytesRead < TOTAL_SAMPLES * SAMPLE_SIZE && isTalking) {
    size_t bytesIn = 0;
    esp_err_t result = i2s_read(I2S_PORT, audioBuffer + (bytesRead / SAMPLE_SIZE), TOTAL_SAMPLES * SAMPLE_SIZE - bytesRead, &bytesIn, portMAX_DELAY);
    if (result == ESP_OK) {
      bytesRead += bytesIn;
    }
  }

  send_data(client, "microphone", AUTH_KEY, (char*)audioBuffer, TOTAL_SAMPLES * SAMPLE_SIZE);
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
  
  if(fb->format != PIXFORMAT_JPEG){
    Serial.println("Non-JPEG data not implemented");
    return;
  }
  
  client.sendBIN((const uint8_t*) fb->buf, fb->len);
  esp_camera_fb_return(fb);    
  //send_data(client, "take_picture", AUTH_KEY, fb->buf, fb->len);
}

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
  vector<string> message_parts = split((char*)payload, "¬");
	switch(type) {
		case WStype_DISCONNECTED:
			Serial.println("[WSc] Disconnected!\n");
			break;
		case WStype_CONNECTED:
			Serial.print("\n[WSc] Connected to url: ");
      Serial.println((char*)payload);

			client.sendTXT(AUTH_KEY);
      delay(5000);

      isConnected = true;
      //xTaskCreatePinnedToCore(micTask, "micTask", 10000, NULL, 1, NULL, 1);
      take_picture();
			break;
		case WStype_TEXT:
      if(message_parts[1] == AUTH_KEY){
        if(message_parts[0] == "start_recording"){
          break;
        }else if(message_parts[0] == "get_recording"){
          break;
        }else if(message_parts[0] == "take_picture"){
          take_picture();
          break;
        }else if(message_parts[0] == "volume"){
          volume = stoi(message_parts[2]);
        }else if(message_parts[0] == "play"){
          // string to bytes
          // play bytes
          break;
        }
      }
			break;
		case WStype_BIN:
      Serial.println("payload");
			break;
	}
}

void setup() {
  Serial.begin(115200);
  Serial.println("Running");

  audioBuffer = (int16_t*)malloc(TOTAL_SAMPLES * SAMPLE_SIZE);

  setup_camera();
  connect_wifi("3Pocket_66B9808B", "LWS36G3Hsx");

  client.begin("192.168.0.183", 4040, "/ws");
	client.onEvent(webSocketEvent);
}

void loop() {
  client.loop();
}

void record_audio(){
}