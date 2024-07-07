#include <WebSocketsClient.h>
#include <driver/i2s.h>
#include "helper/camera/camera.hpp"
#include "helper/microphone.hpp"

String authentication_key = "peJ0AMmumNwHwk3U6IMcRqtLqFWO0Ao9oT3BaijuZA1s5f5NqPyvPnhyAGVPV8Kh64HxcNiux3Rq2lS6qMI6IhGztPPsvrahqux4MsxikyHCCPDsazVxJln7hJfDa4J2";

WebSocketsClient webSocket;
bool isConnected;

void setup() {
  Serial.begin(115200);
  Serial.println();

  setup_camera();
  connect_wifi("", "");

  webSocket.begin("172.20.10.9", 4040, "/ws"); 
  webSocket.onEvent(webSocketEvent);

  xTaskCreatePinnedToCore(micTask, "micTask", 10000, NULL, 1, NULL, 1);
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

      delay(1000);
      webSocket.sendTXT(authentication_key + "¬Hey Gemma, who are my team members");
      isConnected = true;
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

  i2s_install();
  i2s_setpin();
  i2s_start(I2S_PORT);

  size_t bytesIn = 0;
  while (1) {
    esp_err_t result = i2s_read(I2S_PORT, &sBuffer, bufferLen, &bytesIn, portMAX_DELAY);
    if (result == ESP_OK && isConnected) {
      webSocket.sendTXT((const char*)sBuffer);
    }
  }
}