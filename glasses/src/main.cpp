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

    glasses.record_microphone(false);
}

void record_video(void *pvParameter) {
    glasses.record_video();
}

void record_audio(void *pvParameter) {
    glasses.record_audio();
}

void listen_ble(void *pvParameter){
    glasses.listen_ble();
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
                    glasses.record_microphone(true);
                    break;
                }
                else if(message_parts[0] == "start_recording"){
                    glasses.is_recording = true;
                    xTaskCreate(&record_video, "record_video", 2048, NULL, 5, NULL);
                    xTaskCreate(&record_audio, "record_audio", 2048, NULL, 5, NULL);
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
                    //glasses.play_audio(string to bytes);
                    break;
                }
                else if(message_parts[0] == "contacts" || message_parts[0] == "call" || message_parts[0] == "text"){
                    glasses.send_ble((char*)payload);
                    break;
                }
            }
			break;
	}
}

void setup() {
    Serial.begin(115200);
    Serial.println();

    // play boot sound

    glasses.setup_tf();
    glasses.setup_microphone();
    glasses.setup_camera();
    glasses.setup_ble();

    glasses.AUTH_KEY = read_string(0).c_str();

    Serial.println("Started");

    xTaskCreate(&listen_ble, "listen_ble", 2048, NULL, 5, NULL);

    if(read_string(1) != NULL && read_string(2) != NULL)
        glasses.connect_wifi(read_string(1).c_str(), read_string(2).c_str());

    glasses.client.begin("172.20.10.3", 4040, "/ws");
    glasses.client.onEvent(webSocketEvent);
    glasses.client.setReconnectInterval(5000);
}

void loop() {
    glasses.client.loop();
}