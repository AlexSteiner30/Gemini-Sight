#include "glasses.hpp"
#include "helper/helper.hpp"

Glasses glasses;

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
    vector<string> message_parts = split((char*)payload, "¬");
    switch(type) {
		case WStype_DISCONNECTED:
			Serial.println("[WSc] Disconnected!");
			break;

		case WStype_CONNECTED:
			Serial.println("[WSc] Connected to url: /ws");
            glasses.client.sendTXT(glasses.AUTH_KEY);
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
    Serial.println();

    glasses.setup_microphone();
    glasses.predict(glasses.get_speech_command());
    //glasses.setup_camera();

    //glasses.connect_wifi("3Pocket_66B9808B", "LWS36G3Hsx");

    /*
    glasses.client.begin("192.168.0.183", 4040, "/ws");
    glasses.client.onEvent(webSocketEvent);
    glasses.client.setReconnectInterval(5000);
    */
}

void loop() {
    //glasses.client.loop();
}