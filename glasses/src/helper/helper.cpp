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