import 'package:app/pages/device.dart';
import 'package:app/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';

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
    await Future.delayed(const Duration(seconds: 3), () {});
    if (prefs.getBool('logged') as bool) {
      final GoogleSignIn _googleSignIn = GoogleSignIn(
          clientId:
              '910242255946-b70mhjrb2225nmapdvsgrr0mk66r9pid.apps.googleusercontent.com',
          scopes: [
            calendar.CalendarApi.calendarScope,
            gmail.GmailApi.gmailReadonlyScope,
            gmail.GmailApi.gmailSendScope,
            gmail.GmailApi.gmailComposeScope,
            gmail.GmailApi.gmailModifyScope,
            drive.DriveApi.driveScope,
          ]);

      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DevicePage(user: account!, connected: false)),
      );
    } else {
      Navigator.pushReplacement(
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
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
