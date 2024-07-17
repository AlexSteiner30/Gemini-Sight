#include "glasses.hpp"


void setup() {
    Serial.begin(115200);

    i2s_install();
    i2s_setpin();
    i2s_start(I2S_PORT);

    /*

    NeuralNetwork nn;

    int result = nn.predict(get_speech_command());
    while(result != 1){
        result = nn.predict(get_speech_command());
    };

    Serial.println("Command Invoked!");
    Serial.println(result);
    */

    //setup_camera();
    connect_wifi("3Pocket_66B9808B", "LWS36G3Hsx");
}

void loop() {
    client.loop();
}