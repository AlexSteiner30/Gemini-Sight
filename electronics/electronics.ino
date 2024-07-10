#include <WebSocketsClient.h>
#include <driver/i2s.h>
#include "helper/camera/camera.hpp"
#include "helper/microphone.hpp"
#include "helper/wifi.hpp"
#include <cstring>  

String authentication_key = "peJ0AMmumNwHwk3U6IMcRqtLqFWO0Ao9oT3BaijuZA1s5f5NqPyvPnhyAGVPV8Kh64HxcNiux3Rq2lS6qMI6IhGztPPsvrahqux4MsxikyHCCPDsazVxJln7hJfDa4J2";

WebSocketsClient webSocket;
bool isConnected = false;

void setup() {
  Serial.begin(115200);
  Serial.println();

  audioBuffer = (int16_t*)malloc(TOTAL_SAMPLES * SAMPLE_SIZE);

  setup_camera();
  connect_wifi("3Pocket_66B9808B", "LWS36G3Hsx");
  i2s_install();
  i2s_setpin();
  i2s_start(I2S_PORT);

  webSocket.begin("192.168.0.183", 4040, "/ws"); 
  webSocket.onEvent(webSocketEvent);
}

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_DISCONNECTED:
      Serial.println("Disconnected!");
      isConnected = false;
      break;
    case WStype_CONNECTED:
      Serial.printf("Connected to URL: %s\n", payload);

      webSocket.sendTXT(authentication_key);
      delay(5000);

      record_audio();

      isConnected = true;
      //xTaskCreatePinnedToCore(micTask, "micTask", 10000, NULL, 1, NULL, 1);

      break;
    case WStype_TEXT:
      Serial.printf("Received: %s\n", payload);
      break;
    case WStype_BIN:
      Serial.printf("Received binary data of length %u\n", length);
      break;
  }
}

void loop() {
  webSocket.loop();
}

void micTask(void* parameter) {
  
}

void record_audio(){
  Serial.println("Starting 5-second recording...");

  bytesRead = 0;
  while (bytesRead < TOTAL_SAMPLES * SAMPLE_SIZE) {
    size_t bytesIn = 0;
    esp_err_t result = i2s_read(I2S_PORT, audioBuffer + (bytesRead / SAMPLE_SIZE), TOTAL_SAMPLES * SAMPLE_SIZE - bytesRead, &bytesIn, portMAX_DELAY);
    if (result == ESP_OK) {
      bytesRead += bytesIn;
    }
  }

  Serial.println("Recording finished.");

  String textMessage = "";

  size_t textSize = textMessage.length();
  size_t binarySize = TOTAL_SAMPLES * SAMPLE_SIZE;
  size_t totalSize = textSize + binarySize;

  uint8_t* combinedBuffer = new uint8_t[totalSize];

  memcpy(combinedBuffer, textMessage.c_str(), textSize);
  memcpy(combinedBuffer + textSize, audioBuffer, binarySize);

  Serial.println(binarySize);
  webSocket.sendBIN(combinedBuffer, binarySize);

  delete[] combinedBuffer;
}
