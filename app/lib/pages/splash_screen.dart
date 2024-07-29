import 'dart:async';
import 'package:app/helper/ble.dart';
import 'package:app/helper/helper.dart';
import 'package:app/helper/wifi.dart';
import 'package:app/main.dart';
import 'package:app/pages/device.dart';
import 'package:app/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/tasks/v1.dart' as tasks;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:shared_preferences/shared_preferences.dart';

GoogleSignInAccount? account;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('blind_support') == null) {
      await prefs.setBool('blind_support', false);
    }
    if ((prefs.getBool('logged') ?? false)) {
      final GoogleSignIn _googleSignIn =
          GoogleSignIn(clientId: CLIENT_ID, scopes: [
        calendar.CalendarApi.calendarScope,
        gmail.GmailApi.gmailReadonlyScope,
        gmail.GmailApi.gmailSendScope,
        gmail.GmailApi.gmailComposeScope,
        gmail.GmailApi.gmailModifyScope,
        drive.DriveApi.driveScope,
        tasks.TasksApi.tasksScope,
        sheets.SheetsApi.spreadsheetsScope,
      ]);

      account = await _googleSignIn.signInSilently();

      final GoogleSignInAuthentication auth = await account!.authentication;

      List<String> initial_data = await get_initial_data(auth);
      authentication_key = initial_data[0];
      ble_id = initial_data[1];

      final prefs = await SharedPreferences.getInstance();

      await scan_devices();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DevicePage(
                user: account!,
                blind_support: prefs.getBool('blind_support') ?? false)),
      );
    } else {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 275,
          height: 275,
        ),
      ),
    );
  }
}
