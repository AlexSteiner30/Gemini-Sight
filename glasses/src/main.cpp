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

void record_video(void *pvParameter) {
    glasses.record_video();
}

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
    vector<string> message_parts = split((char*)payload, "¬");
    switch(type) {
		case WStype_DISCONNECTED:
			Serial.println("[WSc] Disconnected!");
            glasses.current_state = glasses.not_connected;
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
                    xTaskCreate(&record_video, "record_video", 2048, NULL, 5, NULL);
                    break;
                }
                else if(message_parts[0] == "get_recording"){
                    glasses.is_recording = false;
                    break;
                }
                else if(message_parts[0] == "take_picture"){
                    glasses.take_picture();
                    break;
                }
                else if(message_parts[0] == "volume"){
                    glasses.set_volume(message_parts[2]);
                    break;
                }
                else if(message_parts[0] == "play"){
                    // string to bytes -> play bytes
                    break;
                }
            }
			break;
	}
}

void setup() {
    Serial.begin(115200);
    Serial.println();

    glasses.setup_tf();
    glasses.setup_microphone();
    glasses.setup_camera();

    Serial.println("Started");

    glasses.connect_wifi("iPhone di Alex", "12345678");

    glasses.client.begin("172.20.10.3", 4040, "/ws");
    glasses.client.onEvent(webSocketEvent);
    glasses.client.setReconnectInterval(5000);
}

void loop() {
    glasses.client.loop();
}