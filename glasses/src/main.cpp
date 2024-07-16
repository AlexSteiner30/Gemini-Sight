#include "glasses.hpp"

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
    vector<string> message_parts = split((char*)payload, "¬");
    switch(type) {
		case WStype_DISCONNECTED:
			Serial.println("[WSc] Disconnected!\n");
			break;

		case WStype_CONNECTED:
			Serial.println("\n[WSc] Connected to url: /ws");
            client.sendTXT(AUTH_KEY);
            //delay(5000);
            Serial.println("Recording");
            micTask();
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
                    take_picture();
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

void setup() {
    Serial.begin(115200);

    i2s_install();
    i2s_setpin();
    i2s_start(I2S_PORT);

    audioBuffer = (int16_t*)malloc(TOTAL_SAMPLES * SAMPLE_SIZE);

    /*
    NeuralNetwork nn;
    float input_data[10] = {1, 0.1, 5.2, 4.3, 6.5, 9.1};
    nn.setInputBuffer(input_data);

    float prediction = nn.predict();
    Serial.println(prediction);
    */

    //setup_camera();
    connect_wifi("3Pocket_66B9808B", "LWS36G3Hsx");

    client.begin("192.168.0.183", 4040, "/ws");
    client.onEvent(webSocketEvent);
    client.setReconnectInterval(5000);
}

void loop() {
    client.loop();
}