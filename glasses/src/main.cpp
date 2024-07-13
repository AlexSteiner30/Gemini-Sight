#include <WebSocketsClient.h>
#include <driver/i2s.h>
#include "helper/camera/camera.hpp"
#include "helper/microphone.hpp"
#include "helper/wifi.hpp"
#include "helper/helper.hpp"

const char* AUTH_KEY = "peJ0AMmumNwHwk3U6IMcRqtLqFWO0Ao9oT3BaijuZA1s5f5NqPyvPnhyAGVPV8Kh64HxcNiux3Rq2lS6qMI6IhGztPPsvrahqux4MsxikyHCCPDsazVxJln7hJfDa4J2";

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
  camera_fb_t *fb = esp_camera_fb_get();
  
  send_data(client, "take_picture", AUTH_KEY, (char*)fb->buf, fb->len);
  esp_camera_fb_return(fb);
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
			break;
		case WStype_TEXT:
      if(message_parts[1] == AUTH_KEY){
        if(message_parts[0] == "start_recording"){
          break;
        }else if(message_parts[0] == "get_recording"){
          break;
        }else if(message_parts[0] == "volume"){
          volume = stoi(message_parts[2]);
        }
        else if(message_parts[0] == "play"){
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