#include <WebSocketsClient.h>
#include <driver/i2s.h>
#include "helper/camera/camera.hpp"
#include "helper/microphone.hpp"
#include "helper/wifi.hpp"
#include <math.h>

#define SILENCE_THRESHOLD 1000
const char* AUTH_KEY = "peJ0AMmumNwHwk3U6IMcRqtLqFWO0Ao9oT3BaijuZA1s5f5NqPyvPnhyAGVPV8Kh64HxcNiux3Rq2lS6qMI6IhGztPPsvrahqux4MsxikyHCCPDsazVxJln7hJfDa4J2";

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

      webSocket.sendTXT(AUTH_KEY);
      delay(5000);

      isConnected = true;
      xTaskCreatePinnedToCore(micTask, "micTask", 10000, NULL, 1, NULL, 1);

      break;
    case WStype_TEXT:
      Serial.printf("Received: %s\n", payload);
      break;
  }
}

void loop() {
  webSocket.loop();
}

float calculate_rms(int16_t *audioBuffer, size_t samples) {
    long sum = 0;
    for (size_t i = 0; i < samples; i++) {
        sum += audioBuffer[i] * audioBuffer[i];
    }
    return sqrt(sum / (float)samples);
}

void micTask(void* parameter) {
  Serial.println("Starting 5-second recording...");

  bytesRead = 0;
  while (bytesRead < TOTAL_SAMPLES * SAMPLE_SIZE) {
    size_t bytesIn = 0;
    esp_err_t result = i2s_read(I2S_PORT, audioBuffer + (bytesRead / SAMPLE_SIZE), TOTAL_SAMPLES * SAMPLE_SIZE - bytesRead, &bytesIn, portMAX_DELAY);
    if (result == ESP_OK) {
      bytesRead += bytesIn;
    }

    size_t samplesRead = bytesRead / SAMPLE_SIZE;

    float rms = calculate_rms(audioBuffer, samplesRead);

    if (rms > SILENCE_THRESHOLD) {
      Serial.println("User is speaking\n");
    } else {
        Serial.println("User is silent\n");
    }
  }

  Serial.println("Recording finished.");

  webSocket.sendBIN((uint8_t *)audioBuffer, bytesRead);
}

void record_audio(){
}
