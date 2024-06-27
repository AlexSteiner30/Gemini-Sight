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

late GoogleSignInAccount user;

final socket = WebSocket(
  Uri.parse('ws://192.168.88.9:9000'),
);

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
  return result.substring(0);
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

Future<void> start_recording() async {
  print('Started Recording');
}

Future<void> stop_recording() async {
  print('Stop Recording');
}

Future<void> start_route(route) async {
  print('Started Route');
}

Future<void> stop_route() async {
  print('Stopped Route');
}

Future<void> get_document(document) async {
  print(document);
}

Future<void> write_document(document, Map<String, dynamic> data) async {
  print(document);
  print(data);
}

Future<void> get_sheet(sheet) async {
  print(sheet);
}

Future<void> write_sheet(String sheet, Map<String, dynamic> data) async {
  print(sheet);
  print(data);
}

Future<void> change_volume(volume) async {
  print(volume);
}

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

Future<void> record_speed() async {
  print('Recording Speed');
}

Future<void> stop_speed() async {
  print('Stop Recording Speed');
}

Future<void> play_song(String song) async {
  print('Playing song: $song');
}

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
  data = data.substring(1);
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
