import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import 'parser.dart';
import 'user.dart';

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url,
          headers: headers != null ? (headers..addAll(_headers)) : _headers);
}

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 4040);
  print(
      'WebSocket listening on ws://${server.address.address}:${server.port}/');

  await for (HttpRequest request in server) {
    if (request.uri.path == '/ws' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket ws = await WebSocketTransformer.upgrade(request);
      try {
        handleWebSocket(ws, request);
      } catch (error) {
        print(error);
      }
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..write('WebSocket connections only')
        ..close();
    }
  }
}

void handleWebSocket(WebSocket ws, HttpRequest request) {
  print("A new client connected");
  Parser parser = Parser(functionRegistry: {});
  User user = User(
      displayName: '',
      location: '',
      auth_headers: {},
      authentication_key: '',
      parser: parser,
      ws: ws);
  Map<String, Function> functionRegistry = {};

  ws.listen((message) async {
    List<String> messageParts = message.toString().split('¬');

    if (messageParts.length == 2) {
      messageParts[0] =
          messageParts[0].substring(1, messageParts[0].length - 1);

      List<String> pairs = messageParts[0].split(', ');

      Map<String, String> auth_headers = {};

      for (String pair in pairs) {
        List<String> keyValue = pair.split(': ');
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();
        auth_headers[key] = value;

        functionRegistry = {
          'process': user.process,
          'send_data': user.send_data,
          'speak': user.speak,
          'listen': user.listen,
          'take_picture': user.take_picture,
          'start_recording': user.start_recording,
          'stop_recording': user.stop_recording,
          'start_route': user.start_route,
          'stop_route': user.stop_route,
          'get_document': user.get_document,
          'write_document': user.write_document,
          'get_sheet': user.get_sheet,
          'write_sheet': user.write_sheet,
          'change_volume': user.change_volume,
          'wait': user.wait,
          'record_speed': user.record_speed,
          'stop_speed': user.stop_speed,
          'play_song': user.play_song,
          'contacts': user.contacts,
          'call': user.call,
          'text': user.text,
          'get_calendar_events': user.get_calendar_events,
          'add_calendar_event': user.add_calendar_event,
          'delete_calendar_event': user.delete_calendar_event,
          'update_calendar_event': user.update_calendar_event,
          'read_email': user.read_email,
          'search_emails': user.search_emails,
          'reply_email': user.reply_email,
          'send_email': user.send_email,
          'get_tasks': user.get_tasks,
          'add_task': user.add_task,
          'update_task': user.update_task,
          'delete_task': user.delete_task,
          'get_place': user.get_place,
        };
        parser.functionRegistry = functionRegistry;
        user.parser = parser;
      }

      user.authentication_key = messageParts[1];
      user.auth_headers = auth_headers;
      user.ws = ws;
      user.displayName = 'Nikolas Coffey'; // change this from client side
      user.location =
          'Strada San Michele 150, Borgo Maggiore, 47890, San Marino'; // change this from client side
    } else if (messageParts.length == 3) {
      await user.send_data(messageParts[2]);
    }
  }, onDone: () {
    print('WebSocket connection closed');
  }, onError: (error) {
    print('WebSocket error: $error');
  });
}
