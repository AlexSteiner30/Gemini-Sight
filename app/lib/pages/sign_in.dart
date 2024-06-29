import 'dart:async';
import 'dart:convert';
import 'package:app/helper/commands.dart';
import 'package:app/helper/loading_screen.dart';
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
import 'package:web_socket_client/web_socket_client.dart';
import 'package:googleapis/docs/v1.dart' as docs;

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
      await get_init_query();
    }
  }

  Future<void> get_init_query() async {
    final Completer<String> completer = Completer<String>();
    await socket.connection.firstWhere((state) => state is Connected);

    socket.send('first_time¬$authentication_key¬${user!.email}');

    final subscription = socket.messages.listen((response) {
      completer.complete(response);
    });

    final result = await completer.future;
    await subscription.cancel();

    if (result == "true") {
      final GoogleAPIClient httpClient =
          GoogleAPIClient(await user!.authHeaders);
      final drive.DriveApi driveApi = drive.DriveApi(httpClient);
      final docsApi = docs.DocsApi(httpClient);
      final gmailApi = gmail.GmailApi(httpClient);

      setState(() {
        isLoading = true;
      });

      try {
        /*
        final List<gmail.Message> messages =
            await _fetchGmailMessages(gmailApi);

        print('gmail fetch');

        await _processAndSendData(messages, (message) async {
          final fullMessage =
              await gmailApi.users.messages.get('me', message.id!);
          return _getBody(fullMessage);
        });
        */

        final fileList = await driveApi.files.list(
          q: "mimeType='application/vnd.google-apps.document'",
          spaces: 'drive',
        );

        await _processAndSendData(fileList.files!, (file) async {
          final document = await docsApi.documents.get(file.id!);
          final content = document.body!.content!;
          return _extractText(content);
        });
      } catch (e) {
        print('Error getting data: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged', true);
    await prefs.setBool('first_time', false);

    socket.send('not_first_time¬$authentication_key');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DevicePage(
          user: user!,
          connected: false,
        ),
      ),
    );
  }

  Future<List<gmail.Message>> _fetchGmailMessages(
      gmail.GmailApi gmailApi) async {
    final List<gmail.Message> messages = [];
    String? nextPageToken;

    do {
      print('test');
      final response =
          await gmailApi.users.messages.list('me', pageToken: nextPageToken);
      messages.addAll(response.messages!);
      nextPageToken = response.nextPageToken;
    } while (nextPageToken != null);

    return messages;
  }

  Future<void> _processAndSendData<T>(
      List<T> items, Future<String> Function(T item) processItem) async {
    String data = '';
    int count = 0;

    for (var item in items) {
      data += ' ${await processItem(item)}';
      count++;

      if (count == 50) {
        print('Data sent');
        socket.send('add_query¬$authentication_key¬$data');
        count = 0;
        data = '';
      }
    }

    if (data.isNotEmpty) {
      socket.send('add_query¬$authentication_key¬$data');
      print('Data sent');
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
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return states.contains(MaterialState.pressed)
                              ? Colors.grey[800]!
                              : Colors.grey[800]!;
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

String _extractText(List<docs.StructuralElement> elements) {
  String text = '';
  for (var element in elements) {
    if (element.paragraph != null) {
      text += _extractParagraphText(element.paragraph!);
    } else if (element.table != null) {
      text += _extractTableText(element.table!);
    }
  }
  return text;
}

String _extractParagraphText(docs.Paragraph paragraph) {
  String text = '';
  for (var element in paragraph.elements!) {
    if (element.textRun != null) {
      text += element.textRun!.content!;
    }
  }
  return text + '\n\n';
}

String _extractTableText(docs.Table table) {
  String text = '';
  for (var row in table.tableRows!) {
    for (var cell in row.tableCells!) {
      text += _extractText(cell.content!);
      text += '\t';
    }
    text += '\n';
  }
  return text + '\n';
}

String _getBody(gmail.Message message) {
  final parts = message.payload!.parts;
  if (parts != null) {
    return parts.map((part) => _decodeBase64(part.body!.data!)).join();
  } else {
    return _decodeBase64(message.payload!.body!.data!);
  }
}

String _decodeBase64(String data) {
  return String.fromCharCodes(
      base64.decode(data.replaceAll('-', '+').replaceAll('_', '/')));
}
