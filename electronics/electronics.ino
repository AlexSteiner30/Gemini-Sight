#include <WiFi.h>
#include <WebSocketsClient.h>

const char* ssid = "";
const char* password = "";

const String authentication_header = "{Authorization: Bearer ya29.a0AXooCgs-FNtDuBO9tlUhYebW38v7KBNpZXBekza3cg3twU9LtwingwGg3kFXahP5-ZPc-k3eGVv8TUiMXi8Z6RJia7s9gvK1ArguA395Un5gDPk8MH2wGycDGqRoD9HFCShV8-wXR7JnnBPtqFfvmA4qX1OmSB63Z9itaCgYKAbYSARMSFQHGX2MiKw9rQzHg4ND0PfvF54BuLg0171, X-Goog-AuthUser: 0}";
const String authentication_key = "dpVYZBSFPRcHd9yGCNDzQT3mHDDEVv54seSNiv6KovFb8Qfw54zMPBzIZ0RAUSHOgOKgdeECEaWqi6hoEy6Vkk2P5rexd5fPVNTrIUEqmo8R7TAxU4eCCJSS8ZPMa9HbMbiFAYpmY2ewZGFMaQf6b0qPJeOrCxXLeXIDjEBXQDGgYgXC4cie9qZhMwkQjEsaP01EXlqR";

WebSocketsClient webSocket;

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_DISCONNECTED:
      Serial.println("Disconnected!");
      break;
    case WStype_CONNECTED:
      Serial.printf("Connected to URL: %s\n", payload);

      webSocket.sendTXT(authentication_header + "¬" + authentication_key);
      webSocket.sendTXT(authentication_header + "¬" + authentication_key + "¬Write an email to alex.steiner@student.h-is.com saying okay");
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