#include "glasses.h"

Glasses::Glasses(){
    i2s_install();
    i2s_setpin();
    i2s_start(I2S_PORT);
}

void Glasses::connect(){
    client.begin("192.168.0.183", 4040, "/ws");
    client.setReconnectInterval(5000);
}
