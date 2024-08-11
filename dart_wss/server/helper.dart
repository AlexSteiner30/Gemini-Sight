import 'dart:async';
import 'package:web_socket_client/web_socket_client.dart';

final socket = WebSocket(
  Uri.parse('ws://192.168.88.31:443'),
);

/// Get display name of user by making an authenticated request to js ws
///
/// Input:
///   - String user auth key
///
/// Returns:
///   - String user's display name
Future<String> get_display_name(String authentication_key) async {
  await socket.connection.firstWhere((state) => state is Connected);
  final Completer<String> completer = Completer<String>();

  socket.send('get_display_name¬$authentication_key');
  final subscription = socket.messages.listen((display_name) async {
    completer.complete(display_name);
  });

  final refresh_token = await completer.future;
  await subscription.cancel();

  return refresh_token;
}

/// Request refresh token to js ws saved in database
///
/// Input:
///   - String authetnication key to validate request
///
/// Returns:
///   - Refresh toke used to generate auth code
Future<String> get_refresh_token(String authentication_key) async {
  await socket.connection.firstWhere((state) => state is Connected);
  final Completer<String> completer = Completer<String>();

  socket.send('get_refresh_token¬$authentication_key');
  final subscription = socket.messages.listen((refresh_token) async {
    completer.complete(refresh_token);
  });

  final refresh_token = await completer.future;
  await subscription.cancel();

  return refresh_token;
}

/// Send authenticated request to js ws with the refresh token to get the the authentication code
/// which can validate the request to an google account up to 1 hour of time
///
/// Input:
///   - String user auth key
///   - String refresh token
///
/// Returns:
///   - String auth code
Future<String> get_auth_code(
    String authentication_key, String refresh_token) async {
  await socket.connection.firstWhere((state) => state is Connected);
  final Completer<String> completer = Completer<String>();

  socket.send('get_auth_code¬$authentication_key¬$refresh_token');
  final subscription = socket.messages.listen((auth_code) async {
    completer.complete(auth_code);
  });

  final auth_code = await completer.future;
  await subscription.cancel();

  return auth_code;
}

/// Generate the headers for the google authentication
/// Returns a json with the generated auth code which is used to validate
Future<Map<String, String>> generate_headers(
    String authentication_key, String refresh_token) async {
  return <String, String>{
    'Authorization':
        'Bearer ${await get_auth_code(authentication_key, refresh_token)}',
    'X-Goog-AuthUser': '0'
  };
}
