import 'package:web_socket_client/web_socket_client.dart';

class WebSocketClient {
  final socket = WebSocket(
    Uri.parse('ws://192.168.88.9:9000'),
  );
}

void main() async {
  WebSocketClient client = WebSocketClient();
  await client.socket.connection.firstWhere((state) => state is Connected);

  client.socket.send(
      'e6c2ce4f-7736-46f6-9693-6cb104c42b10,hey gemini how do i go back home?');
  client.socket.messages.listen((onData) {
    print(onData);
  });
}
