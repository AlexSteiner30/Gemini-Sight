#include "glasses.hpp"

#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

bool deviceConnected = false;

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    Serial.println("Device connected");
  };

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    Serial.println("Device disconnected");
    pServer->startAdvertising(); 
  }
};


void Glasses::setup_ble() {
  BLEDevice::init("Gemini Sight Glasses");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);
  
  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );

  pCharacteristic->setValue("Hello World");
  pCharacteristic->setCallbacks(this); 
  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06); 
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("Characteristic defined! Now you can read it on your phone!");
}


void Glasses::process_ble_data(std::string data){
    vector<string> message_parts = split(data.c_str(), "|");
    Serial.println(data.c_str());
    Serial.println(message_parts[0].c_str());

    if (message_parts[0] == "authentication_key" && message_parts.size() == 2) {
        const char* AUTH_KEY = message_parts[1].c_str();
        save_string(0, message_parts[1]);
    } else if (message_parts[0] == "wifi" && message_parts[1] == AUTH_KEY && message_parts.size() == 4) {
        save_string(1, message_parts[2]);
        save_string(2, message_parts[3]);

        connect_wifi(message_parts[2].c_str(), message_parts[3].c_str());

        String ble_data = "ip|" + String(AUTH_KEY) + "|" + WiFi.localIP().toString();
        send_ble((char*)ble_data.c_str());
    } else {
        // need to replace character 
        size_t size = data.length();
        uint8_t* buffer = new uint8_t[size];

        memcpy(buffer, data.c_str(), size);
        client.sendBIN(buffer, size);

        delete[] buffer;
    }
}
void Glasses::onWrite(BLECharacteristic *pCharacteristic) {
    std::string data = pCharacteristic->getValue();
        
    if (data.length() > 0) {
        process_ble_data(data);
    }
}

void Glasses::send_ble(char* payload){

}
