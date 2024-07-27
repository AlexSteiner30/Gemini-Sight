#include "glasses.hpp"

SoftwareSerial HM10(2, 3);

void Glasses::setup_ble(){
    HM10.begin(9600);
}

void Glasses::listen_ble(){
    while(true){
        HM10.listen();  

        while (HM10.available() > 0) {  
            String data = String(HM10.read());
            size_t size = data.length();

            uint8_t* buffer = new uint8_t[size];

            memcpy(buffer, data.c_str(), size);
            client.sendBIN(buffer, size);

            delete[] buffer;
        }
    }
}

void Glasses::send_ble(char* payload){
    HM10.write(payload);
}