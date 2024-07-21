import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:app/helper/socket.dart';
import 'package:web_socket_client/web_socket_client.dart';

Future<List<String>> get_initial_data(GoogleSignInAuthentication auth) async {
  await socket.connection.firstWhere((state) => state is Connected);
  final Completer<String> completer = Completer<String>();

  socket.send('authentication¬${auth.idToken}');

  final subscription = socket.messages.listen((response) {
    completer.complete(response);
  });

  final auth_result = await completer.future;
  await subscription.cancel();

  final Completer<String> ble_completer = Completer<String>();

  socket.send('ble_id¬$auth_result');

  final ble_subscription = socket.messages.listen((response) {
    ble_completer.complete(response);
  });

  final ble_result = await ble_completer.future;
  await ble_subscription.cancel();

  return [auth_result, ble_result];
}
