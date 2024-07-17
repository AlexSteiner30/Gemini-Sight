#include "glasses.h"
#include "helper/wifi.hpp"

Glasses glasses = Glasses();

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
    vector<string> message_parts = glasses.split((char*)payload, "¬");
    switch(type) {
		case WStype_DISCONNECTED:
			Serial.println("[WSc] Disconnected!\n");
            glasses.isConnected = false;
			break;

		case WStype_CONNECTED:
			Serial.println("\n[WSc] Connected to url: /ws");
            glasses.client.sendTXT(glasses.AUTH_KEY);
            glasses.isConnected = true;
			break;

		case WStype_TEXT:
            if(message_parts[1] == glasses.AUTH_KEY){
                if(message_parts[0] == "start_recording"){
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

    connect_wifi("3Pocket_66B9808B", "LWS36G3Hsx");

    glasses.client.onEvent(webSocketEvent);
    glasses.connect();
}

void loop() {
    glasses.client.loop();

    if(glasses.isConnected){
        int result = glasses.nn.predict(glasses.get_speech_command());
        while(result != 1){
            result = glasses.nn.predict(glasses.get_speech_command());
        };

        Serial.println("Command Invoked!");
        Serial.println(result);
    }
}