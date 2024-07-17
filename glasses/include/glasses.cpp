#include "glasses.h"

void Glasses::webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
    vector<string> message_parts = split((char*)payload, "¬");
    switch(type) {
		case WStype_DISCONNECTED:
			Serial.println("[WSc] Disconnected!\n");
            isConnected = false;
			break;

		case WStype_CONNECTED:
			Serial.println("\n[WSc] Connected to url: /ws");
            client.sendTXT(AUTH_KEY);
            isConnected = true;
			break;

		case WStype_TEXT:
            if(message_parts[1] == AUTH_KEY){
                if(message_parts[0] == "start_recording"){
                    break;
                }
                else if(message_parts[0] == "get_recording"){
                    break;
                }
                else if(message_parts[0] == "take_picture"){
                    camera_recording.take_picture(*this);
                    break;
                }
                else if(message_parts[0] == "volume"){
                    volume = stoi(message_parts[2]);
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

Glasses::Glasses(){
    microphone.i2s_install();
    microphone.i2s_setpin();
    microphone.i2s_start(I2S_PORT);
}

void Glasses::connect(){
    client.begin("192.168.0.183", 4040, "/ws");
    client.onEvent(webSocketEvent);
    client.setReconnectInterval(5000);
}
