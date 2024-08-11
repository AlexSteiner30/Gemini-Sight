#include "glasses.hpp"

Glasses glasses;
String blind_message;

void Glasses::get_wake_word(){
    glasses.current_state = glasses.wake_word;
    
    while(!glasses.predict(glasses.get_speech_command())){}

    glasses.record_microphone(false);
}

void record_video(void *pvParameter) {
    glasses.record_video();
}

void record_audio(void *pvParameter) {
    glasses.record_audio();
}

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
    vector<string> message_parts = glasses.split((char*)payload, "¬");
    size_t size;
    uint8_t* buffer;

    switch(type) {
		case WStype_DISCONNECTED:
			Serial.println("[WSc] Disconnected!");
            glasses.current_state = glasses.not_connected;
			break;

		case WStype_CONNECTED:
			Serial.println("[WSc] Connected to url: /ws");
            glasses.client.sendTXT(glasses.AUTH_KEY);

            blind_message = "blind|" + String(glasses.AUTH_KEY) + "|" + glasses.read_string("blind");
            size = blind_message.length();
            buffer = new uint8_t[size];

            memcpy(buffer, blind_message.c_str(), size);
            glasses.client.sendBIN(buffer, size);

            delete[] buffer;

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
                    glasses.play_audio(reinterpret_cast<uint8_t*>(const_cast<char*>(message_parts[2].data())));
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

    pinMode(A0, INPUT);
    SPIFFS.begin();

    glasses.setup_tf();
    glasses.setup_microphone();
    glasses.setup_camera();
    glasses.setup_ble();
    glasses.setup_audio();

    glasses.play_file("boot.wav");

    glasses.preferences.begin("glasses", false);

    glasses.AUTH_KEY = glasses.read_string("auth_key").c_str();

    if(glasses.AUTH_KEY == "error"){
        Serial.println("Device not initialized!");
        return;
    }

    Serial.println("Device Started!");

    if(glasses.read_string("ssid") != "error" && glasses.read_string("password") != "error")
        glasses.connect_wifi(glasses.read_string("ssid").c_str(), glasses.read_string("password").c_str());
    else
        glasses.invoke_error("WiFi not connected");

    glasses.client.begin("192.168.88.31", 4040, "/ws");
    glasses.client.onEvent(webSocketEvent);
    glasses.client.setReconnectInterval(5000);
}

void loop() {
    glasses.client.loop();
}