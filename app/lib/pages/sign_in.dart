import 'dart:async';
import 'package:app/helper/commands.dart';
import 'package:app/helper/loading_screen.dart';
import 'package:app/helper/query.dart';
import 'package:app/pages/device.dart';
import 'package:flutter/foundation.dart';
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
    clientId:
        '910242255946-b70mhjrb2225nmapdvsgrr0mk66r9pid.apps.googleusercontent.com',
    scopes: [
      calendar.CalendarApi.calendarScope,
      gmail.GmailApi.gmailReadonlyScope,
      gmail.GmailApi.gmailSendScope,
      gmail.GmailApi.gmailComposeScope,
      gmail.GmailApi.gmailModifyScope,
      drive.DriveApi.driveScope,
      tasks.TasksApi.tasksScope,
      sheets.SheetsApi.spreadsheetsScope
    ],
  );

  GoogleSignInAccount? user;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication auth = await account.authentication;
      user = account;

      await verification(auth.idToken, account);
    } catch (error) {
      if (kDebugMode) {
        print('Login failed: $error');
      }
    }
  }

  Future<void> verification(
      String? auth_code, GoogleSignInAccount? account) async {
    final Completer<String> completer = Completer<String>();
    await socket.connection.firstWhere((state) => state is Connected);

    socket.send('authentication¬$auth_code');

    final subscription = socket.messages.listen((response) {
      completer.complete(response);
    });

    final result = await completer.future;
    await subscription.cancel();

    authentication_key = result;

    print(authentication_key);

    if (authentication_key == '') {
      await _googleSignIn.signOut();
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Authentication failed'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'In order to access this app, please log in with an account that has purchased the Gemini Sight Glasses',
                  ),
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
    } else {
      final Completer<String> completer = Completer<String>();
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
        // ignore: use_build_context_synchronously
        await get_query(account!, context);
        setState(() {
          isLoading = false;
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged', true);
      await prefs.setBool('first_time', false);

      socket.send('not_first_time¬$authentication_key');

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => DevicePage(
            user: user!,
            connected: false,
            blind_support: prefs.getBool('blind_support')!,
          ),
        ),
      );
    }
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
          headers: headers != null ? (headers..addAll(_headers)) : _headers);
}
