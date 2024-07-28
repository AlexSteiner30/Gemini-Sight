import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

bool wifi = false;

Future<bool> is_online(String ipAddress) async {
  final Uri url = Uri.parse('http://$ipAddress');

  try {
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return true;
    }
  } on SocketException {
    return false;
  } on TimeoutException {
    return false;
  } catch (e) {
    return false;
  }

  return false;
}
