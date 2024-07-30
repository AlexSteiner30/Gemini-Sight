import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

bool wifi = false;

Future<void> is_online() async {
  final prefs = await SharedPreferences.getInstance();
  final String? ipAddress = prefs.getString('ip');

  /*if (ipAddress == null) {
    wifi = false;
    return;
  }*/

  final Uri url = Uri.parse('http://185.21.119.34');

  try {
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      wifi = true;
      return;
    }
  } on SocketException {
    wifi = false;
  } on TimeoutException {
    wifi = false;
  } catch (e) {
    wifi = false;
  }

  wifi = false;
}
