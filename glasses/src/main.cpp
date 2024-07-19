#include "glasses.hpp"
#include "helper/helper.hpp"

Glasses glasses;

void Glasses::get_wake_word(){
    glasses.current_state = glasses.wake_word;

    int prediction = glasses.predict(glasses.get_speech_command());
    while(prediction != 1){
        prediction = glasses.predict(glasses.get_speech_command());
        Serial.println(prediction);
    }

    Serial.println("Gemma");

    glasses.record_microphone();
}

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
    vector<string> message_parts = split((char*)payload, "¬");
    switch(type) {
		case WStype_DISCONNECTED:
			Serial.println("[WSc] Disconnected!");
			break;

		case WStype_CONNECTED:
			Serial.println("[WSc] Connected to url: /ws");
            glasses.client.sendTXT(glasses.AUTH_KEY);
            glasses.get_wake_word();
			break;

		case WStype_TEXT:
            if(message_parts[1] == glasses.AUTH_KEY){
                if(message_parts[0] == "listen"){
                    glasses.record_microphone();
                    break;
                }
                else if(message_parts[0] == "start_recording"){
                    break;
                }
                else if(message_parts[0] == "get_recording"){
                    break;
                }
                else if(message_parts[0] == "take_picture"){
                    glasses.take_picture();
                    break;
                }
                else if(message_parts[0] == "volume"){
                    glasses.volume = stoi(message_parts[2]);
                    break;
                }
                else if(message_parts[0] == "play"){
                    // string to bytes -> play bytes
                    break;
                }
            }
			break;
            
		case WStype_BIN:
			break;
	}
}

void setup() {
    Serial.begin(115200);
    Serial.println();

    glasses.setup_tf();
    glasses.setup_microphone();
    //glasses.setup_camera();

    Serial.println("Started");

    glasses.connect_wifi("3Pocket_66B9808B", "LWS36G3Hsx");

    glasses.client.begin("192.168.0.183", 4040, "/ws");
    glasses.client.onEvent(webSocketEvent);
    glasses.client.setReconnectInterval(5000);
}

void loop() {
    glasses.client.loop();
}

/*
#include <Arduino.h>
#include "Audio.h"
#include "SPIFFS.h"

#define I2S_DOUT 22
#define I2S_BCLK 26
#define I2S_LRC  25

Audio audio;

void setup() {
  Serial.begin(115200);
  
  Serial.println("Initializing...");

  if(!SPIFFS.begin(true)){
    Serial.println("An error occurred while mounting SPIFFS");
    return;
  }
  Serial.println("SPIFFS mounted successfully");

  audio.setPinout(I2S_BCLK, I2S_LRC, I2S_DOUT);
  audio.setVolume(21); // 0...21

  Serial.println("Starting WAV playback");
  audio.connecttoFS(SPIFFS, "/audio.wav");
}

void loop() {
  audio.loop();
  if (audio.isRunning()) {
    Serial.print(".");
  } else {
    Serial.println("\nPlayback finished");
    delay(1000);
    ESP.restart();  // Restart ESP32 after playback
  }
}
*/