#include "glasses.hpp"

#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

bool deviceConnected = false;
BLECharacteristic *pCharacteristic;

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

/**
 * Setup BleDevice and Server
 * Create Characteristic & Callbacks
 */
void Glasses::setup_ble() {
  BLEDevice::init("Gemini Sight Glasses");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);
  
  pCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY);

  pCharacteristic->setValue("Hello World");
  pCharacteristic->setCallbacks(this); 
  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06); 
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

/**
 * Process received Ble Data
 * 
 * @param data string received
 */
void Glasses::process_ble_data(std::string data){
    vector<string> message_parts = split(data.c_str(), "|");

    if (message_parts[0] == "authentication_key" && message_parts.size() == 2) {
      AUTH_KEY = message_parts[1].c_str();
      save_string("auth_key", message_parts[1]);
    } else if (message_parts[0] == "wifi" && message_parts[1] == AUTH_KEY && message_parts.size() == 4) {
      save_string("ssid", message_parts[2]);
      save_string("password", message_parts[3]);

      connect_wifi(message_parts[2].c_str(), message_parts[3].c_str());

      String ble_data = "ip|" + String(AUTH_KEY) + "|" + WiFi.localIP().toString();
      send_ble((char*)ble_data.c_str());
    } else if(message_parts[0] == "blind" && message_parts[1] == AUTH_KEY && message_parts.size() == 3){
      save_string("blind", message_parts[2]);
    } else { // if the message isn't any of the above the ble received is mirrored to the dart ws 
      size_t size = data.length();
      uint8_t* buffer = new uint8_t[size];

      memcpy(buffer, data.c_str(), size);
      client.sendBIN(buffer, size);

      delete[] buffer;
    }
}

/**
 * On message received by the BLE clienet connected
 */
void Glasses::onWrite(BLECharacteristic *pCharacteristic) {
    std::string data = pCharacteristic->getValue();
        
    if (data.length() > 0) {
      process_ble_data(data);
    }
}

/**
 * Send message to Bluethoot
 * 
 * @param payload message to send
 */
void Glasses::send_ble(char* payload) {
    if (deviceConnected) {
      pCharacteristic->setValue((uint8_t*)payload, strlen(payload));
      pCharacteristic->notify();
    }else{
      String data = "ble_error|" + String(AUTH_KEY) + "|";
      size_t size = data.length();
      uint8_t* buffer = new uint8_t[size];

      memcpy(buffer, data.c_str(), size);
      client.sendBIN(buffer, size);

      delete[] buffer;
    }
}