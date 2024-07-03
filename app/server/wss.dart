import 'dart:io';

class Account {
  String displayName = 'Alex Steiner';
  String email = 'alex.steiner@student.h-is.com';
  Map<String, String>? authHeaders;
}

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 4040);
  print(
      'WebSocket listening on ws://${server.address.address}:${server.port}/');

  await for (HttpRequest request in server) {
    if (request.uri.path == '/ws' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket ws = await WebSocketTransformer.upgrade(request);
      handleWebSocket(ws);
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..write('WebSocket connections only')
        ..close();
    }
  }
}

void handleWebSocket(WebSocket ws) {
  print('New WebSocket connection established');

  ws.listen((message) {
    print('Received message: $message');
    ws.add('Echo: $message');
  }, onDone: () {
    print('WebSocket connection closed');
  }, onError: (error) {
    print('WebSocket error: $error');
  });
}
