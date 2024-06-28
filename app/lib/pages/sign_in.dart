import 'package:app/helper/commands.dart';
import 'package:app/pages/device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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

  Future<void> check_login() async {
    final prefs = await SharedPreferences.getInstance();
    bool logged = prefs.getBool('logged') as bool;

    if (logged) {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      user = account!;
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => DevicePage(
                  user: account,
                  connected: false,
                )),
      );
    }
  }

  @override
  initState() {
    super.initState();
    check_login();
  }

  Future<void> _login() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      user = account!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged', true);

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => DevicePage(
                  user: account,
                  connected: false,
                )),
      );
    } catch (error) {
      if (kDebugMode) {
        print('Login failed: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _login,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    return states.contains(WidgetState.pressed)
                        ? Colors.grey[800]!
                        : Colors.grey[800]!;
                  },
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_circle, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Login with Google',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url,
          headers: (headers != null ? (headers..addAll(_headers)) : headers));
}
