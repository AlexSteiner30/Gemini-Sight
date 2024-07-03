#include <ArduinoWebsockets.h>
#include <WiFi.h>

const char* ssid = "alexnoemi";
const char* password = "hf73tgherhf56"; 

const char* websockets_server_host = "localhost"; // Server address
const uint16_t websockets_server_port = 4040; // Server port

using namespace websockets;

WebsocketsClient client;

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  client.onMessage([](WebsocketsMessage message) {
    Serial.print("Got Message: ");
    Serial.println(message.data());
  });

  client.onEvent([](WebsocketsEvent event, String data) {
    if (event == WebsocketsEvent::ConnectionOpened) {
      Serial.println("Connection Opened");
      client.send("Hello, Server!");
    } else if (event == WebsocketsEvent::ConnectionClosed) {
      Serial.println("Connection Closed");
    } else if (event == WebsocketsEvent::GotPing) {
      Serial.println("Got a Ping!");
    } else if (event == WebsocketsEvent::GotPong) {
      Serial.println("Got a Pong!");
    }
  });

  client.connect(websockets_server_host, websockets_server_port, "/ws");
  client.send("Hello, Server!");
}

void loop() {
  client.poll();
}