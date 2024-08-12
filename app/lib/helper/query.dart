import 'dart:async';
import 'dart:convert';
import 'package:app/helper/socket.dart';
import 'package:app/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/docs/v1.dart' as docs;

/// Function to fetch and process Gmail messages and Google Docs data.
///
/// This function retrieves emails and Google Docs associated with the user's Google account,
/// processes the data, and sends it to a server using a socket connection.
///
/// Parameters:
///   - GoogleSignInAccount user: The user's Google account.
///   - BuildContext context: The current build context, used for displaying dialogs.
Future<void> get_query(GoogleSignInAccount user, context) async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  final drive.DriveApi driveApi = drive.DriveApi(httpClient);
  final docsApi = docs.DocsApi(httpClient);
  final gmailApi = gmail.GmailApi(httpClient);
  bool successful = false;
  String result =
      "Gemini can now hold more personalized conversations to enhance your experience and assist with daily tasks."; // Default message to display.

  try {
    final List<gmail.Message> messages =
        await _fetchGmailMessages(gmailApi); // Fetching Gmail messages.

    await _processAndSendData(messages, (message) async {
      final fullMessage = await gmailApi.users.messages.get('me', message.id!);
      return _getBody(fullMessage);
    });

    final fileList = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.document'",
      spaces: 'drive',
    );

    await _processAndSendData(fileList.files!, (file) async {
      final document = await docsApi.documents
          .get(file.id!); // Fetching the full content of each Google Doc.
      final content = document.body!.content!;
      return _extractText(
          content); // Extracting the text content from the document.
    });
    successful = true;
  } catch (e) {
    result = e as String;
  }

  // Displaying a dialog to inform the user about the success or failure of the operation.
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

/// Function to fetch Gmail messages from the user's inbox.
///
/// This function retrieves all the messages in the user's Gmail inbox, handling pagination if necessary.
///
/// Parameters:
///   - gmail.GmailApi gmailApi: The Gmail API client instance.
///
/// Returns:
///   - List<gmail.Message>: A list of Gmail message objects.
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

/// Function to process and send data to a server.
///
/// This function processes a list of items, converts them into a string, and sends the data to a server in batches.
///
/// Parameters:
///   - List<T> items: A list of items to process.
///   - Future<String> Function(T item) processItem: A function that processes each item and returns a string.
Future<void> _processAndSendData<T>(
    List<T> items, Future<String> Function(T item) processItem) async {
  String data = '';
  int count = 0;

  for (var item in items) {
    data +=
        ' ${await processItem(item)}'; // Processing each item and appending the result to the data string.
    count++;

    if (count == 50) {
      socket.send(
          'add_query¬$authentication_key¬$data'); // Sending data in batches of 50 items.
      count = 0;
      data = '';
    }
  }

  if (data.isNotEmpty) {
    socket.send(
        'add_query¬$authentication_key¬$data'); // Sending any remaining data.
  }
}

/// Function to extract text content from a list of Google Docs structural elements.
///
/// This function traverses the elements of a Google Doc and extracts text from paragraphs and tables.
///
/// Parameters:
///   - List<docs.StructuralElement> elements: A list of structural elements from a Google Doc.
///
/// Returns:
///   - String: The extracted text.
String _extractText(List<docs.StructuralElement> elements) {
  String text = '';
  for (var element in elements) {
    if (element.paragraph != null) {
      text += _extractParagraphText(
          element.paragraph!); // Extracting text from paragraphs.
    } else if (element.table != null) {
      text += _extractTableText(element.table!); // Extracting text from tables.
    }
  }
  return text;
}

/// Function to extract text from a Google Docs paragraph.
///
/// This function iterates over the elements of a paragraph and extracts the text content.
///
/// Parameters:
///   - docs.Paragraph paragraph: A paragraph object from a Google Doc.
///
/// Returns:
///   - String: The extracted text.
String _extractParagraphText(docs.Paragraph paragraph) {
  String text = '';
  for (var element in paragraph.elements!) {
    if (element.textRun != null) {
      text += element.textRun!.content!; // Extracting the content of text runs.
    }
  }
  return '$text\n\n';
}

/// Function to extract text from a Google Docs table.
///
/// This function iterates over the rows and cells of a table, extracting and concatenating the text content.
///
/// Parameters:
///   - docs.Table table: A table object from a Google Doc.
///
/// Returns:
///   - String: The extracted text.
String _extractTableText(docs.Table table) {
  String text = '';
  for (var row in table.tableRows!) {
    for (var cell in row.tableCells!) {
      text += _extractText(
          cell.content!); // Extracting text from each cell in the table.
      text += '\t';
    }
    text += '\n';
  }
  return '$text\n';
}

/// Function to extract the body text from a Gmail message.
///
/// This function retrieves the body of a Gmail message, handling both plain text and encoded parts.
///
/// Parameters:
///   - gmail.Message message: A Gmail message object.
///
/// Returns:
///   - String: The decoded body text.
String _getBody(gmail.Message message) {
  final parts =
      message.payload!.parts; // Retrieving the parts of the message payload.
  if (parts != null) {
    return parts
        .map((part) => _decodeBase64(part.body!.data!))
        .join(); // Decoding and joining the parts if they exist.
  } else {
    return _decodeBase64(message
        .payload!.body!.data!); // Decoding the body if there are no parts.
  }
}

/// Function to decode a Base64 encoded string.
///
/// This function decodes a Base64 encoded string and returns the decoded text.
///
///Parameters:
///   - String data: The Base64 encoded string.
///
/// Returns:
///   - String: The decoded text.
String _decodeBase64(String data) {
  return String.fromCharCodes(base64.decode(data.replaceAll('-', '+').replaceAll(
      '_',
      '/'))); // Decoding the Base64 string, accounting for URL-safe characters.
}
