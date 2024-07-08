import 'dart:async';
import 'package:app/helper/socket.dart';
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
import 'package:web_socket_client/web_socket_client.dart';

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
    await Future.delayed(const Duration(seconds: 2));
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
      final Completer<String> completer = Completer<String>();

      await socket.connection.firstWhere((state) => state is Connected);

      socket.send('authentication¬${auth.idToken}');

      final subscription = socket.messages.listen((response) {
        completer.complete(response);
      });

      final result = await completer.future;
      await subscription.cancel();

      authentication_key = result;

      final prefs = await SharedPreferences.getInstance();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DevicePage(
                user: account!,
                connected: true,
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
