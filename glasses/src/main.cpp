#include <ArduinoWebsockets.h>
#include <driver/i2s.h>
#include "helper/camera/camera.hpp"
#include "helper/microphone.hpp"
#include "helper/wifi.hpp"
#include "helper/helper.hpp"

using namespace websockets;

const char* AUTH_KEY = "peJ0AMmumNwHwk3U6IMcRqtLqFWO0Ao9oT3BaijuZA1s5f5NqPyvPnhyAGVPV8Kh64HxcNiux3Rq2lS6qMI6IhGztPPsvrahqux4MsxikyHCCPDsazVxJln7hJfDa4J2";

WebsocketsClient client;
bool isConnected = false;
bool isTalking = false;
int volume = 100;

void micTask(void* parameter) {
  i2s_install();
  i2s_setpin();
  i2s_start(I2S_PORT);

  isTalking = true;
  bytesRead = 0;
  while (bytesRead < TOTAL_SAMPLES * SAMPLE_SIZE && isTalking) {
    size_t bytesIn = 0;
    esp_err_t result = i2s_read(I2S_PORT, audioBuffer + (bytesRead / SAMPLE_SIZE), TOTAL_SAMPLES * SAMPLE_SIZE - bytesRead, &bytesIn, portMAX_DELAY);
    if (result == ESP_OK) {
      bytesRead += bytesIn;
    }
  }
  
  client.sendBinary((const char*)audioBuffer, bytesRead);
}

void onMessageCallback(WebsocketsMessage message) {
  vector<string> message_parts = split(message.data().c_str(), "¬");

  if(message_parts[1] == AUTH_KEY){
    if(message_parts[0] == "start_recording"){

    }else if(message_parts[0] == "get_recording"){
      
    }else if(message_parts[0] == "volume"){
      volume = stoi(message_parts[2]);
    }
    else if(message_parts[0] == "play"){
      // string to bytes
      // play bytes
    }
  }
}

void onEventsCallback(WebsocketsEvent event, String data) {
  if(event == WebsocketsEvent::ConnectionOpened) {
    Serial.println("Connnection Opened");
    client.send(AUTH_KEY);
    delay(5000);

    isConnected = true;
    xTaskCreatePinnedToCore(micTask, "micTask", 10000, NULL, 1, NULL, 1);
  } else if(event == WebsocketsEvent::ConnectionClosed) {
    Serial.println("Connnection Closed");
  } else if(event == WebsocketsEvent::GotPing) {
    Serial.println("Got a Ping!");
  } else if(event == WebsocketsEvent::GotPong) {
    Serial.println("Got a Pong!");
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println();

  audioBuffer = (int16_t*)malloc(TOTAL_SAMPLES * SAMPLE_SIZE);

  setup_camera();
  connect_wifi("3Pocket_66B9808B", "LWS36G3Hsx");

  client.onMessage(onMessageCallback);
  client.onEvent(onEventsCallback);

  client.connect("192.168.0.183", 4040, "/ws"); 
}

void loop() {
  client.poll();
}

void record_audio(){
}