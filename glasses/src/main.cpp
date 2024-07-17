#include "glasses.h"
#include "helper/wifi.hpp"

Glasses glasses;

void setup() {
    Serial.begin(115200);

    connect_wifi("3Pocket_66B9808B", "LWS36G3Hsx");
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