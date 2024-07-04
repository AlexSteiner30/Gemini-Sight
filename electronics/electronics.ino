#include <WiFi.h>
#include <WebSocketsClient.h>



String authentication_key = "peJ0AMmumNwHwk3U6IMcRqtLqFWO0Ao9oT3BaijuZA1s5f5NqPyvPnhyAGVPV8Kh64HxcNiux3Rq2lS6qMI6IhGztPPsvrahqux4MsxikyHCCPDsazVxJln7hJfDa4J2";

WebSocketsClient webSocket;

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_DISCONNECTED:
      Serial.println("Disconnected!");
      break;
    case WStype_CONNECTED:
      Serial.printf("Connected to URL: %s\n", payload);

      webSocket.sendTXT(authentication_key);
      webSocket.sendTXT(authentication_key + "¬Write an email to alex.steiner@student.h-is.com saying okay");
      break;
    case WStype_TEXT:
      Serial.printf("Received: %s\n", payload);
      break;
    case WStype_BIN:
      Serial.printf("Received binary data of length %u\n", length);
      break;
  }
}

void setup() {
  Serial.begin(115200);
  Serial.print("\n\nConnecting to WiFi");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi");

  webSocket.begin("192.168.88.12", 4040, "/ws"); 

  webSocket.onEvent(webSocketEvent);
  webSocket.setReconnectInterval(5000);
}

void loop() {
  webSocket.loop();
}