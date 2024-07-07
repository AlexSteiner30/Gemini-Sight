import 'dart:async';
import 'package:app/helper/socket.dart';
import 'package:app/helper/loading_screen.dart';
import 'package:app/helper/query.dart';
import 'package:app/main.dart';
import 'package:app/pages/device.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/tasks/v1.dart' as tasks;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_client/web_socket_client.dart';

// ignore: non_constant_identifier_names
String authentication_key = '';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId: CLIENT_ID,
      scopes: [
        calendar.CalendarApi.calendarScope,
        gmail.GmailApi.gmailReadonlyScope,
        gmail.GmailApi.gmailSendScope,
        gmail.GmailApi.gmailComposeScope,
        gmail.GmailApi.gmailModifyScope,
        drive.DriveApi.driveScope,
        tasks.TasksApi.tasksScope,
        sheets.SheetsApi.spreadsheetsScope,
      ],
      forceCodeForRefreshToken: true,
      serverClientId: SERVER_CLIENT_ID);

  GoogleSignInAccount? user;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return; // User canceled the sign-in
      final GoogleSignInAuthentication auth = await account.authentication;

      user = account;

      await _verifyAuthentication(auth.idToken, account);
    } catch (error) {
      _showDialog('Login Failed', error.toString());
    }
  }

  Future<void> _verifyAuthentication(
      String? authCode, GoogleSignInAccount? account) async {
    final prefs = await SharedPreferences.getInstance();
    final completer = Completer<String>();
    await socket.connection.firstWhere((state) => state is Connected);

    socket.send('authentication¬$authCode');

    final subscription = socket.messages.listen((response) {
      completer.complete(response);
    });

    final result = await completer.future;
    await subscription.cancel();

    authentication_key = result;

    if (authentication_key.isEmpty) {
      await _googleSignIn.signOut();
      _showDialog('Authentication failed',
          'Please log in with an account that has purchased the Gemini Sight Glasses.');
      return;
    }

    await _handleServerAuthCode(account!.serverAuthCode!);
    await _handleFirstTimeLogin(account, prefs);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DevicePage(
          user: user!,
          connected: false,
          blind_support: prefs.getBool('blind_support') ?? false,
        ),
      ),
    );
  }

  Future<void> _handleServerAuthCode(String serverAuthCode) async {
    final completer = Completer<String>();
    await socket.connection.firstWhere((state) => state is Connected);

    socket.send('auth_code¬$authentication_key¬$serverAuthCode');

    final subscription = socket.messages.listen((response) {
      completer.complete(response);
    });

    await completer.future;
    await subscription.cancel();
  }

  Future<void> _handleFirstTimeLogin(
      GoogleSignInAccount? account, SharedPreferences prefs) async {
    final completer = Completer<String>();
    await socket.connection.firstWhere((state) => state is Connected);

    socket.send('first_time¬$authentication_key¬${user!.email}');

    final subscription = socket.messages.listen((response) {
      completer.complete(response);
    });

    final result = await completer.future;
    await subscription.cancel();

    if (result == "true") {
      setState(() {
        isLoading = true;
      });
      await get_query(account!, context);
      setState(() {
        isLoading = false;
      });
    }

    await prefs.setBool('logged', true);
    await prefs.setBool('first_time', false);

    socket.send('not_first_time¬$authentication_key');
  }

  void _showDialog(String title, String content) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: isLoading
          ? LoadingScreen()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _login,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return Colors.grey[800]!;
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
          headers: headers != null ? (headers..addAll(_headers)) : _headers);
}
