#include "glasses.hpp"
 
HardwareSerial HM10(1); 

void Glasses::setup_ble() {
    HM10.begin(9600);
}

void Glasses::listen_ble() {
    while (true) {
        if (HM10.available() > 0) {
            String data = "";
            while (HM10.available() > 0) {
                char c = HM10.read();
                data += c;
            }

            vector<string> message_parts = split(data.c_str(), "¬");

            if (message_parts[0] == "authentication_key" && message_parts.size() == 2) {
                const char* AUTH_KEY = message_parts[1].c_str();
                save_string(0, message_parts[1]);
            } else if (message_parts[0] == "wifi" && message_parts[1] == AUTH_KEY && message_parts.size() == 4) {
                save_string(1, message_parts[2]);
                save_string(2, message_parts[3]);

                connect_wifi(message_parts[2].c_str(), message_parts[3].c_str());

                String ble_data = "ip¬" + String(AUTH_KEY) + "¬" + WiFi.localIP().toString();
                send_ble((char*)ble_data.c_str());
            } else {
                size_t size = data.length();
                uint8_t* buffer = new uint8_t[size];

                memcpy(buffer, data.c_str(), size);
                client.sendBIN(buffer, size);

                delete[] buffer;
            }
        }
    }
}

void Glasses::send_ble(char* payload) {
    HM10.write(payload);
}