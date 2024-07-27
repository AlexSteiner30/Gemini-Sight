#include "glasses.hpp"
#include "helper/helper.hpp"

SoftwareSerial HM10(2, 3);

void Glasses::setup_ble(){
    HM10.begin(9600);
}

void Glasses::listen_ble(){
    while(true){
        HM10.listen();  

        while (HM10.available() > 0) {  
            String data = String(HM10.read());

            vector<string> message_parts = split(data.c_str(), "¬");
            if(message_parts[0] == "authentication_key"){
                const char* AUTH_KEY = message_parts[1].c_str();
                save_string(0, message_parts[1]);
            }else{ 
                size_t size = data.length();
                uint8_t* buffer = new uint8_t[size];

                memcpy(buffer, data.c_str(), size);
                client.sendBIN(buffer, size);

                delete[] buffer;
            }
        }
    }
}

void Glasses::send_ble(char* payload){
    HM10.write(payload);
}