import 'dart:async';
import 'dart:convert';
import 'package:app/helper/parse.dart';
import 'package:app/pages/sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:web_socket_client/web_socket_client.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:intl/intl.dart';

late GoogleSignInAccount user;

final socket = WebSocket(
  Uri.parse('ws://192.168.88.9:9000'),
);

Future<void> process(String data) async {
  await socket.connection.firstWhere((state) => state is Connected);

  final Completer<void> completer = Completer<void>();

  socket.send('process¬e6c2ce4f-7736-46f6-9693-6cb104c42b10¬$data');

  final subscription = socket.messages.listen((response) {
    if (response[0] == 'r') {
      speak(response.toString().substring(1)).then((_) {
        completer.complete();
      });
    }
  });

  await completer.future;
  await subscription.cancel();
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
    //print(pcm);
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

Future<void> get_events() async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  calendar.CalendarApi calendarAPI = calendar.CalendarApi(httpClient);

  var calendarList = await calendarAPI.calendarList.list();

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

            await process(information);
          }
        }
      }
    }
  }
}

Future<void> get_emails() async {
  search_emails('chess');
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  gmail.GmailApi gmailAPI = gmail.GmailApi(httpClient);

  var profile = await gmailAPI.users.getProfile('me');
  var messagesResponse =
      await gmailAPI.users.messages.list('me', maxResults: 10);

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
      await process(information);
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
      print(information);
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

Future<void> send_email(String to, String subject, String body) async {
  final GoogleAPIClient httpClient = GoogleAPIClient(await user.authHeaders);
  gmail.GmailApi gmailAPI = gmail.GmailApi(httpClient);

  var emailContent = '''
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
to: $to
subject: $subject

$body
''';

  var encodedEmail = base64Url.encode(utf8.encode(emailContent));

  var message = gmail.Message()..raw = encodedEmail;

  await gmailAPI.users.messages.send(message, 'me');
}
