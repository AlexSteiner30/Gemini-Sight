#include "glasses.hpp"

/**
 * Connect device to WiFi, only WPA2-Enterprise and WPA3-Enterprise are supported
 * 
 * @param ssid ssid
 * @param password password
*/
void Glasses::connect_wifi(const char* ssid, const char* password){
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);
    Serial.println("\nConnecting");
    play_file("connecting.wav");
    delay(1500);

    int count = 0;
    while(WiFi.status() != WL_CONNECTED){
        play_file("loading.wav");
        delay(2000);
        count++;
    }

    Serial.println("\nConnected to the WiFi network");
    invoke_error("Connected to the WiFi network");
    Serial.print("Local ESP32 IP: ");
    Serial.println(WiFi.localIP());
}