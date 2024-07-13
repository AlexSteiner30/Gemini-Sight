#include <vector>
#include <string>
#include <iostream>

using namespace std;

vector<string> split(string s, string delimiter){
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

void send_data(WebSocketsClient client, string command, const char* AUTH_KEY, char* binary_data, size_t binarySize){
    string textMessage = command + "¬" + string(AUTH_KEY)+ "¬";

    size_t textSize = textMessage.length();
    size_t totalSize = textSize + binarySize;

    uint8_t* combinedBuffer = new uint8_t[totalSize];

    memcpy(combinedBuffer, textMessage.c_str(), textSize);
    memcpy(combinedBuffer + textSize, binary_data, binarySize);

    Serial.println(binarySize);
    client.sendBIN(combinedBuffer, binarySize);

    delete[] combinedBuffer;
}