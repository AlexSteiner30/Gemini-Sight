import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import 'parser.dart';
import 'user.dart';
import 'helper.dart';

Map<String, User> devices = {};

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
  // only supported mac addresses
  try {
    print("A new client connected");
    Parser parser = Parser(functionRegistry: {});
    User user = User(
        displayName: '',
        location: '',
        auth_headers: {},
        authentication_key: '',
        refresh_key: '',
        parser: parser,
        ws: ws,
        expiration: DateTime.now());

    parser.functionRegistry = {
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

    ws.listen((message) async {
      if (message is String) {
        if (devices[message] == null) {
          user.authentication_key = message;
          user.refresh_key = await get_refresh_token(message);
          user.expiration =
              DateTime.now().subtract(const Duration(minutes: 50));

          final entry = <String, User>{message: user};
          devices.addEntries(entry.entries);
        } else if (devices[message] != null) {
          user = devices[message.toString()]!;
        }
      } else if (message is List<int>) {
        await user.send_data(await user.speech_to_text(message));
      }
    }, onDone: () {
      ws.close();
      user.socket.close();
      devices.remove(user.authentication_key);
      print('WebSocket connection closed');
    }, onError: (error) {
      print('WebSocket error: $error');
    });
  } catch (error) {
    print('Error in WebSocket handling: $error');
  }
}

/*
user!.displayName = 'Nikolas Coffey'; // change this from client side
        user!.location =
            'Strada San Michele 150, Borgo Maggiore, 47890, San Marino'; // change this from client side
*/