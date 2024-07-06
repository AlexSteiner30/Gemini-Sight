#include <WiFi.h>
#include <WebSocketsClient.h>
#include <driver/i2s.h>
#include "helper/camera.hpp"

#define I2S_SD 14
#define I2S_WS 12
#define I2S_SCK 13
#define I2S_PORT I2S_NUM_0

#define bufferCnt 10
#define bufferLen 1024
int16_t sBuffer[bufferLen];

const char* ssid = "";
const char* password = "";

String authentication_key = "peJ0AMmumNwHwk3U6IMcRqtLqFWO0Ao9oT3BaijuZA1s5f5NqPyvPnhyAGVPV8Kh64HxcNiux3Rq2lS6qMI6IhGztPPsvrahqux4MsxikyHCCPDsazVxJln7hJfDa4J2";
WebSocketsClient webSocket;
bool isConnected;

void setup() {
  Serial.begin(115200);
  Serial.setDebugOutput(true);
  Serial.println();

  setup_camera();

  WiFi.begin(ssid, password);
  WiFi.setSleep(false);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");

  Serial.print("Camera Ready! Use 'http://");
  Serial.print(WiFi.localIP());
  Serial.println("' to connect");

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

void i2s_install() {
  const i2s_config_t i2s_config = {
    .mode = i2s_mode_t(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate = 44100,
    .bits_per_sample = i2s_bits_per_sample_t(16),
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = i2s_comm_format_t(I2S_COMM_FORMAT_STAND_I2S),
    .intr_alloc_flags = 0,
    .dma_buf_count = bufferCnt,
    .dma_buf_len = bufferLen,
    .use_apll = false
  };

  i2s_driver_install(I2S_PORT, &i2s_config, 0, NULL);
}

void i2s_setpin() {
  const i2s_pin_config_t pin_config = {
    .bck_io_num = I2S_SCK,
    .ws_io_num = I2S_WS,
    .data_out_num = -1,
    .data_in_num = I2S_SD
  };

  i2s_set_pin(I2S_PORT, &pin_config);
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
