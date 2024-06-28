import 'dart:async';
import 'dart:convert';
import 'package:app/helper/parse.dart';
import 'package:app/pages/sign_in.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:web_socket_client/web_socket_client.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:intl/intl.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/docs/v1.dart' as docs;
import 'package:googleapis/sheets/v4.dart' as sheets;

late GoogleSignInAccount user;

bool recording = false;
double volume = 100.0;

List<String> last_recording = [
  "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"
];

final socket = WebSocket(
  Uri.parse('ws://192.168.88.12:9000'),
);

// General
Future<String> process(String input, String context) async {
  String data = input + context;
  await socket.connection.firstWhere((state) => state is Connected);

  final Completer<String> completer = Completer<String>();

  socket.send('process¬e6c2ce4f-7736-46f6-9693-6cb104c42b10¬$data');

  final subscription = socket.messages.listen((response) {
    if (response[0] == 'r') {
      completer.complete(response);
    }
  });

  final result = await completer.future;
  await subscription.cancel();
  return result.substring(1);
}

Future<void> send_data(String data) async {
  await socket.connection.firstWhere((state) => state is Connected);

  final Completer<void> completer = Completer<void>();

  socket.send('e6c2ce4f-7736-46f6-9693-6cb104c42b10¬$data');

  final subscription = socket.messages.listen((commands_list) {
    parse(commands_list);
    completer.complete();
  });

  await completer.future;
  await subscription.cancel();
}

Future<void> speak(String data) async {
  print('Speaking $data');

  await socket.connection.firstWhere((state) => state is Connected);

  final Completer<void> completer = Completer<void>();

  socket.send('speak¬e6c2ce4f-7736-46f6-9693-6cb104c42b10¬' + data);

  final subscription = socket.messages.listen((pcm) {
    // play pcm over ble
    print(pcm);
    completer.complete();
  });

  await completer.future;
  await subscription.cancel();
}

// Camera
Future<void> take_picture() async {
  // send picture
  await socket.connection.firstWhere((state) => state is Connected);

  socket.send(
      'media¬e6c2ce4f-7736-46f6-9693-6cb104c42b10¬${last_recording[0]}'); // take picture and send

  last_recording = [];
}

Future<void> start_recording() async {
  recording = true;
}

Future<void> stop_recording() async {
  recording = false;
}

Future<void> change_volume(volume) async {
  volume = volume;
}

// Docs
Future<void> get_document(document) async {}

Future<String> get_document_id(document) async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  final drive.DriveApi driveApi = drive.DriveApi(httpClient);

  final fileList = await driveApi.files.list(
    q: "mimeType='application/vnd.google-apps.document'",
    spaces: 'drive',
  );

  Map<String, String> files = {};

  for (var i = 0; i < fileList.files!.length; i++) {
    files.addEntries({
      fileList.files![i].name as String: fileList.files![i].id as String
    }.entries);
  }

  return await process(files.toString(),
      'Given the following Map {name of the document: id of the document} of file names with corresponding IDs, return only the ID of the document name that is most similar to "$document". Respond with only one document ID. Only return an ID if the names are actually very similar, if no similar document is found, reply with "404".');
}

Future<void> write_document(String document_name, String data) async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  final docsApi = docs.DocsApi(httpClient);

  String document = await get_document_id(document_name);
  document = document.trim();

  if (document == '404') {
    final createResponse =
        await docsApi.documents.create(docs.Document(title: document_name));
    document = createResponse.documentId!;
  }

  data = await process(data,
      ' Format for a google doc, do no include the tile just write the body for it. Do not respond by saying you are unable to assist with requests.');

  final requests = [
    docs.Request(
      insertText: docs.InsertTextRequest(
        text: data,
        location: docs.Location(index: 1),
      ),
    ),
  ];

  await docsApi.documents.batchUpdate(
    docs.BatchUpdateDocumentRequest(requests: requests),
    document,
  );

  print('Document Written');
}

// Sheet
Future<void> get_sheet(String sheet) async {}

Future<String> get_sheet_id(String sheet) async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  final drive.DriveApi driveApi = drive.DriveApi(httpClient);

  final fileList = await driveApi.files.list(
    q: "mimeType='application/vnd.google-apps.spreadsheet'",
    spaces: 'drive',
  );

  Map<String, String> files = {};

  for (var i = 0; i < fileList.files!.length; i++) {
    files.addEntries({
      fileList.files![i].name as String: fileList.files![i].id as String
    }.entries);
  }

  return await process(files.toString(),
      'Given the following Map {name of the document: id of the document} of file names with corresponding IDs, return only the ID of the document name that is most similar to "$sheet". Respond with only one document ID. Only return an ID if the names are actually very similar, if no similar document is found, reply with "404".');
}

Future<void> write_sheet(String sheet_name, List<List<Object>> data) async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  final sheetsApi = sheets.SheetsApi(httpClient);

  String sheet = await get_sheet_id(sheet_name);
  sheet = sheet.trim();

  print(sheet);

  if (sheet == '404') {
    final createResponse = await sheetsApi.spreadsheets.create(
        sheets.Spreadsheet(
            properties: sheets.SpreadsheetProperties(title: sheet_name)));
    sheet = createResponse.spreadsheetId!;
  }

  print(sheet);

  final requests = [
    sheets.Request(
      updateCells: sheets.UpdateCellsRequest(
        range:
            sheets.GridRange(sheetId: 0, startRowIndex: 0, startColumnIndex: 0),
        rows: data
            .map((row) => sheets.RowData(
                values: row
                    .map((cell) => sheets.CellData(
                        userEnteredValue:
                            sheets.ExtendedValue(stringValue: cell.toString())))
                    .toList()))
            .toList(),
        fields: 'userEnteredValue',
      ),
    ),
  ];

  print('test');

  await sheetsApi.spreadsheets.batchUpdate(
      sheets.BatchUpdateSpreadsheetRequest(requests: requests), sheet);

  print('Sheet Written');
}

// Drive
Future<void> drive_get_file(file) async {
  print(file);
}

Future<void> drive_push_file(file, data) async {
  print(file);
  print(data);
}

Future<void> wait(int seconds) async {
  await Future.delayed(Duration(seconds: seconds));
}

// GPS
Future<void> record_speed() async {
  print('Recording Speed');
}

Future<void> stop_speed() async {
  print('Stop Recording Speed');
}

Future<void> start_route(route) async {
  print('Started Route');
}

Future<void> stop_route() async {
  print('Stopped Route');
}

// Youtube
Future<void> play_song(String song) async {
  print('Playing song: $song');
}

// iPhone
Future<String> contacts(String name) async {
  if (await Permission.contacts.request().isGranted) {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    Contact? contact = contacts.firstWhere(
        (contact) => contact.displayName?.toLowerCase() == name.toLowerCase());

    if (contact != null && contact.phones!.isNotEmpty) {
      return contact.phones?.first.value ?? 'No number found';
    } else {
      return 'Contact not found';
    }
  } else {
    return 'No permission granted';
  }
}

Future<void> call(String phone_number) async {
  launchUrlString("tel://$phone_number");

  await speak(
      'Not having access to your phone, you will have to click on the button to confirm the action on your own.');
}

Future<void> text(String phone_number, message) async {
  await sendSMS(message: message, recipients: [phone_number])
      .catchError((onError) {
    print(onError);
  });

  await speak(
      'Not having access to your phone, you will have to click on the button to confirm the action on your own.');
}

// Calendar
Future<String> get_calendar_events() async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  calendar.CalendarApi calendarAPI = calendar.CalendarApi(httpClient);

  var calendarList = await calendarAPI.calendarList.list();
  String complete_information = '';

  if (calendarList.items != null) {
    for (var cal in calendarList.items!) {
      var events = await calendarAPI.events.list(cal.id!);
      if (events.items != null) {
        for (var event in events.items!) {
          if (event.start?.dateTime != null &&
              event.start!.dateTime!.isAfter(DateTime.now())) {
            String information = '';

            information += 'Event Summary: ${event.summary} ';
            information +=
                'Event Description: ${event.description ?? 'No description'} ';
            information +=
                'Event Start: ${DateFormat('yyyy-MM-dd – kk:mm').format(event.start!.dateTime!)}\n';
            information +=
                'Event End: ${event.end != null ? DateFormat('yyyy-MM-dd – kk:mm').format(event.end!.dateTime!) : 'No end time'} ';
            information +=
                'Event Location: ${event.location ?? 'No location'} ';
            information +=
                'Event Attendees: ${event.attendees?.map((attendee) => attendee.email).join(', ') ?? 'No attendees'} ';
            information += '\n';

            complete_information = complete_information + information;
          }
        }
      }
    }
  }
  return complete_information;
}

// Gmail
Future<void> read_email() async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  gmail.GmailApi gmailAPI = gmail.GmailApi(httpClient);

  var profile = await gmailAPI.users.getProfile('me');

  var messagesResponse =
      await gmailAPI.users.messages.list('me', maxResults: 10, q: 'is:unread');

  if (messagesResponse.messages != null) {
    for (var message in messagesResponse.messages!) {
      var msg = await gmailAPI.users.messages.get('me', message.id!);
      String subject = '';
      String from = '';
      String snippet = msg.snippet ?? 'No snippet';

      if (msg.payload != null && msg.payload!.headers != null) {
        for (var header in msg.payload!.headers!) {
          if (header.name == 'Subject') {
            subject = header.value ?? '';
          } else if (header.name == 'From') {
            from = header.value ?? '';
          }
        }
      }

      String information =
          'Email From: $from\nSubject: $subject\nSnippet: $snippet\n';
      await process(information, '');

      // change email to read
    }
  }
}

Future<List<String>> search_emails(String query) async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  gmail.GmailApi gmailAPI = gmail.GmailApi(httpClient);

  var messagesResponse = await gmailAPI.users.messages.list('me', q: query);

  List<String> emailInfos = [];

  if (messagesResponse.messages != null) {
    for (var message in messagesResponse.messages!) {
      var msg = await gmailAPI.users.messages.get('me', message.id!);
      String subject = '';
      String from = '';
      String snippet = msg.snippet ?? 'No snippet';

      if (msg.payload != null && msg.payload!.headers != null) {
        for (var header in msg.payload!.headers!) {
          if (header.name == 'Subject') {
            subject = header.value ?? '';
          } else if (header.name == 'From') {
            from = header.value ?? '';
          }
        }
      }

      String information =
          'Email From: $from\nSubject: $subject\nSnippet: $snippet\nID: ${message.id!}';
      emailInfos.add(information);
    }
  }

  return emailInfos;
}

Future<void> reply_to_email(String messageId, String replyText) async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  gmail.GmailApi gmailAPI = gmail.GmailApi(httpClient);

  var message = await gmailAPI.users.messages.get('me', messageId);
  var threadId = message.threadId;
  var headers = message.payload?.headers;

  String subject = '';
  String from = '';

  if (headers != null) {
    for (var header in headers) {
      if (header.name == 'Subject') {
        subject = header.value ?? '';
      } else if (header.name == 'From') {
        from = header.value ?? '';
      }
    }
  }

  String replyTo = from;

  var emailContent = '''
  Content-Type: text/plain; charset="UTF-8"
  Content-Transfer-Encoding: 7bit
  to: $replyTo
  subject: Re: $subject
  in-reply-to: $messageId
  references: $messageId

  $replyText
  ''';

  var encodedEmail = base64Url.encode(utf8.encode(emailContent));

  var replyMessage = gmail.Message()
    ..raw = encodedEmail
    ..threadId = threadId;

  await gmailAPI.users.messages.send(replyMessage, 'me');
}

Future<void> send_email(
    String to, String subject, String body, String context) async {
  String data = await process(
      body, '$context do not include the subject just write the email body');

  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  gmail.GmailApi gmailAPI = gmail.GmailApi(httpClient);

  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(to)) {
    print('Invalid email address');
  }

  var emailContent = '''
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: $to
Subject: $subject

$data
''';

  var encodedEmail = base64Url.encode(utf8.encode(emailContent));

  var message = gmail.Message()..raw = encodedEmail;

  try {
    await gmailAPI.users.messages.send(message, 'me');
    print('Email Sent');
  } catch (e) {
    print('Failed to send email: $e');
    if (e is DetailedApiRequestError) {
      print('Failed to send email: ${e.message}');
    }
    print('Failed to send email');
  }
}
