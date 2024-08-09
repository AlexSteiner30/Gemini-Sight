#include "glasses.hpp"

void Glasses::save_string(String key, const string value){
  preferences.putString(key.c_str(), value.c_str());
}

String Glasses::read_string(String key){
  return preferences.getString(key.c_str(), "error");
}

vector<string> Glasses::split(string s, string delimiter){
    vector<string> list;
    size_t pos = 0;
    string token;
    while ((pos = s.find(delimiter)) != string::npos) {
        token = s.substr(0, pos);
        list.push_back(token);
        s.erase(0, pos + delimiter.length());
    }
    list.push_back(s);
    return list;
}

void Glasses::check_battery(){
  uint32_t Vbatt = 0;

  for (int i = 0; i < 16; i++) {
    Vbatt += analogReadMilliVolts(A0);  
  }

  int battery_percentage = constrain(((2 * Vbatt / 16000.0 - minBatteryVoltage) / (maxBatteryVoltage - minBatteryVoltage)) * 100, 0, 100);

  send_ble((char*)("battery|" + std::string(AUTH_KEY) + "|" + std::to_string(battery_percentage)).c_str());
}