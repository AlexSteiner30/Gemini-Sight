import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

bool wifi = false;

Future<void> is_online() async {
  final prefs = await SharedPreferences.getInstance();

  final Uri url = Uri.parse('http://${prefs.getString('ip')}');

  try {
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      wifi = true;
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
