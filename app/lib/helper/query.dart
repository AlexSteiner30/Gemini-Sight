import 'dart:async';
import 'dart:convert';
import 'package:app/helper/socket.dart';
import 'package:app/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/docs/v1.dart' as docs;

Future<void> get_query(GoogleSignInAccount user, context) async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  final drive.DriveApi driveApi = drive.DriveApi(httpClient);
  final docsApi = docs.DocsApi(httpClient);
  final gmailApi = gmail.GmailApi(httpClient);
  bool successful = false;
  String result =
      "Gemini can now hold more personalized conversations to enhance your experience and assist with daily tasks.";
  try {
    final List<gmail.Message> messages = await _fetchGmailMessages(gmailApi);

    await _processAndSendData(messages, (message) async {
      final fullMessage = await gmailApi.users.messages.get('me', message.id!);
      return _getBody(fullMessage);
    });

    final fileList = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.document'",
      spaces: 'drive',
    );

    await _processAndSendData(fileList.files!, (file) async {
      final document = await docsApi.documents.get(file.id!);
      final content = document.body!.content!;
      return _extractText(content);
    });
    successful = true;
  } catch (e) {
    result = e as String;
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
            successful ? 'Data updated successfully' : 'Error getting data'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                result,
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
}

// ignore: unused_element
Future<List<gmail.Message>> _fetchGmailMessages(gmail.GmailApi gmailApi) async {
  final List<gmail.Message> messages = [];
  String? nextPageToken;

  do {
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
      socket.send('add_query¬$authentication_key¬$data');
      count = 0;
      data = '';
    }
  }

  if (data.isNotEmpty) {
    socket.send('add_query¬$authentication_key¬$data');
  }
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
  return '$text\n\n';
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
  return '$text\n';
}

// ignore: unused_element
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
