import 'dart:async';
import 'dart:convert';
import 'package:app/helper/parse.dart';
import 'package:app/pages/sign_in.dart';
import 'package:app/pages/splash_screen.dart';
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

bool recording = false;
double volume = 100.0;

List<String> last_recording = [
  "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBw0HBhAPBw8RDw8VExISFxcVDREVFxUQFhgXFhcYFRcbHCgsGRslGxYVIjciJTEtOi86Gh8zODMsNyktNysBCgoKDg0OGBAQGislHh03LS0tLS0rLS0tLS0tLS0rLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLTcrLf/AABEIAKIBNwMBIgACEQEDEQH/xAAcAAEBAQADAQEBAAAAAAAAAAAAAgEFBgcECAP/xABHEAACAgECAwQECAkKBwAAAAAAEQECAwQFBhIhBxMxQRQiUWEXIzJCVXGBlDdScpGTlaHS4ggWM3Wzw8TR0/AVNFSChZKx/8QAGAEBAQEBAQAAAAAAAAAAAAAAAAIBAwX/xAAfEQEBAQACAgIDAAAAAAAAAAAAEQECIRIxA1FBYaH/2gAMAwEAAhEDEQA/APRUEagj0a82MQRqCFIxBGoIUjEEaghSMQRqCFIxBGoIUjEEaghSMQRqCFIxBGoIUjEEaghSMQRqCFIxBGoIUjEEaghSMQRqCFIxBGoIUjEEaghSMQRqCFIxBGoIUjEEaghSMRhSApFIIpBEVSUEUghRKCKQQolBFIIUSgikEKJQRSCFEoIpBCiUEUghRKCKQQolBFIIUSgikEKJQRSCFEoIpBCiUEUghRKCKQQolBFIIUSgikEKJQRSCFEoIpBCiUCkBRSCNQRzqmII1BCjEEaghRiCNQQoxBGoIUYgjUEKMQRqCFGII1BCjEfDumXV4sURtWCmXJMT1yZ+7pVJcyiZmZfhEeUuY6P70ahR+f44u3bdeOdLg3bNOOKa7BjthxzyY4tXLWtomIn1+sT8qZPfkfm+v4Wf/Lf4k/SSI+Pfbr8uekoI1BF1yYgjUEKMQRqCFGII1BCjEEaghRiCNQQoxBGoIUYgjUEKMQRqCFGIGoCikEUgiKpKCPMNZxrqOIeP8e1bLlnTaaMmSmTLSKzkyTire1+S1omKVdJiJiPe/I+fi3iLcez7ibFHpGXW6DLXn5M9q2vClXrXIm46TD6et1iUzPNfhr1dBH8Nt1uLc9Bi1GjtzYslK3rKXq2h9Y8p9x9KNqIlBFIIUSgikcVxFut9q0Ueh4banU5J5MOKvTnyKZdp+bSsRMzafD7YFMyuTQR4hxjquL9mrGr3LPbHim0R8Rend45nwratfLydn7G5O7dlHGGbirbMtNyU6jBNIteKxEZKX5uWZiPCzrZrp4GZyXvCZXeUEUgjahKCKQQolBFI+bWZsuGsei4ZzT16d5SkRPk5n2+5+ApH5zr+FqP62/xJ+k0eJx2c75HFH/EO703N6V6Vyek9ObvO85Xy+Hkz2fSZcmbG9TinDb2d5W/5pgjh06fJ3I/qgikEXXNKCPi3bdsG0Rh9OtNe+zY9PRVmXmyPliV4R0nqfehSJQRSOK33dM+3ae07fos2syRWbctJpSvn43tPj08Kxafd1FMxyaCPGeFO0PcuJuPNJiz2rh01r5PisdVExGO8xz2nrbwj3dPCD2hGZyquXHcSgikEbUpQRSCFEoIpBCiUEcBxnxZp+E9vrk1Uc+XJM1x4+aK89oTmbT8msOHPXxg4Pi/iTe+F9FXV5sGhz6Z1reMc5+bHNvD15lWq+nMo8Y6GeSs47rvaCOvcEcXafi/bZy6WJx5KTFcmObRM0mfCYnzrKlSo8J6HY0bU7kSgUgKKQU+XiagjnVR+a+zG87f2kaWNb6loyZsVotPXvLY8mNT7+aYg7n/KFrHdbdPznqo+z4n/AH9p2Xi3su0m/blOr0We+i1NrRa1qU562vHz+V1mtunjEx7U2/Ne1bDnrv2m0OTW59x1FMdYnmrSFlyzCpTHWOlpiKTLmZl1J/Eds3N5V6b2MXtfgDBF/CuTPWPyeeZ/+zJ3hHD8G7L/ADe4Y02ksuelPXUuO9tM3up845rTEfVB829cJV3fcLZp3DctO4rHJg13d445YTivLKmfMquWzddhQR1D4P6/S29frP8AgHwf1+lt6/Wf8ApM+3b0Zyw2uv8Av/KDjtg2WNk01sddTqtVzW5ubU6jvbR0iFWVCr0a98nJoVkebdrfF+h0/DefRafLjz6nKsc0paL93EWibTkmPkzCS8XMdOkn9exXR7fp+HL22vP3+e9qzndeW2O0RPJTl/Fh2VvN2+qOe4y4J0XFWhvGbHXHqV6matYi9bR4RaY+XR+MT7ZSnqeV9iOPNpOO82G7qsGauSr8Jpekdfqt0+0y9ukzePT3fJeuOk2yTFax1mZmIiI98yfPG5aX/qMP6en+Z9GfBTU4bY9RSuSloVq2rFq2j2TE9Jg47+bO2TP/ACGj+54P3Ta5zHF8K7dpeHMeesbjOp73LOV5dTjmavyjr1n2z59DsGHWYc9+XBlx3t4quStpX1RJ1fhbJsXFGPPbbNvwRGHJ3Vu827BRz4xNek9J69JUx5xB2PR7NotDm59DpdPhuprzY9PjpbllOHWI6dI/MK3cfYgj4950E7ntmTBjzZdNN+X4zDflyVVot6tvJpfVMnVfg+zfTm7/AH2wpmY7sgjpPwfZvpzd/vth8H2b6c3f77YUmfbuyCPk2bQTtm2Y8F82XUTSJjvMt+bJZ2m3rW8019kHCbnwZXcNfkzTuW6YeeXyYtfyY69EqV5JUCsmPj7S4+L2n+ttF/eHcpg8p454Qrt9NvW4bnm7zcdLh+N13Pyc/P6+P1Y5ckLpbycnZ/g/r9Lbz+s/4BVbmTO3b0IjqfDsm1Rs+gjDXPqNR61rc+ozd5k6+XMo6QchEdRUx+aOyv8ACLo/y8v9lkP0qj81dlf4RtH+Xl/ssh+lkZx3p0+X2xHG8Q7zh4e2jJq9fF5xY+Tm5KxNvWtWkKJmPO0eZyaOP4g3K2z7Tk1GPBl1M05fi8VZm9ua1a+rCnwb+yTa55jpXwybL+Lq/u+P/UHwybL+Lq/u+P8A1D+vwk5/oPcv0Fv3R8JOf6D3L9Bb90Vfj+v65LhftB27ijc5022VzxkilsnxmKla8tZiJ6xeevrQdtR1bhnjDLvu5Thy7ZrNJHJa/PmxzWriYjlfLHWX+w7UhU7nbpnaHwJHGVcE11E6e+Kbw+754tS/K+jhTHLH7Tju1butm7MvRLXm0zGm09Jt1tecU0tNp9/Ljlz7z0RHWNw4bx79xX3284+90+mxUrhx2r8XbNkm1suS0THrqIxVXh08A3N+/wAOo9hOxajQ7fqNXq6zSmfu644mFNqU5pm69kzaIifNSeqI2IUdAhWb3tYgagbWRSBSCOdU6zu29bhmx93w1oMt8lunfamPR8ONv1ppdXvMdOnLHj4+RxnBnZ/XZtwtrt7y+mbjeZtN5j1MdrfKmkT4z5c0rp0iIO8oIVtSgikEKlKCKQQolHn3adg4hjW6fNwlfJOGlZ5qY5rzd6563rP9JWaqF1Snp1PQ0EK3OnSti4r3TW6CI1my6uuriF1imLBa3tm+S0TSvuiLL3n1cDcIxw7TPn1tq5ddqbzkzXrExSJmZtyY382JtPXz6eyDtaCFbUoIpBCpRXHWj5IiHMzKiIcz4zPvNRSCFalBFI4PijbdVvOGul0ma2mwX5pz5aTHeckJYsUeU2cu3lFV1YpH9M/E+16fVTiz6/S0yRKms6nFExPsnr0n6zloVocdYnr9h4T2kdl+DhrY/TNozZb0patclcs0mVeYrFq2rWvzpiFMefj0O4dhGs1Gq4SyV1U2tjx55pimfKvLW1qx7omX/wB0iq3jkuPRkEUghUOq8ebZn3Km3eg45yd1uWlz3S9XDTn5rS/KHB2hFIIVqUfFuWutosczi0+bUW5ZmK46RLnyhzMRH2n3oIUfnzgrhHeth4r02r1e3ZrY8d7TaK2xc3LatqzMRN+sxzP7D3zTZe/xc3LenuvXln8x/dBCt5bUoFIIVLAaghSJCKQQpEz0rMqZ90eZ49wX2n7jvfGePS6zDijDlvesUrSYtiUWtE8z6pdX7/A9jR8mDatLp9bfPp9Phpnv8vJXDSt7flWiHIqsj6UEUghUxKBSAopBGgirjEEaBSMQRoFIxBGgUjEEaBSMQRoFIxBGgUjEEaBSMQRp8Oq3nR6TcMem1Wow48+SImmO2WsXtEzMQqzPnMTEe1CkeQdtm/bnk09dLqNFfSaOckT3k5K5O+tXrWOavSkeM8rmZUT5HbOx/irT75snouDBTS5dPFYmmN8lqWfr1fVzZtzPWW5fTum9bVh3vasul19YtjyVmsuPCfK0eyYlTE+48f8A5Pm15I3LWauf6KuONPE+VslrVvK9qikf+0G5vSvePbEEaDKmMQRoFIxBGgUjEEaBSMQRoFIxBGgUjEEaBSMQRoFIxBGgUjEDTRSNBSCOakgpBASCkEBIKQQEgpBASCkEBIKQQEgpBASdB7QOzLDxfr66nHqbabPFK0n4qMlLVq10cTWevi58PA9AQRubB0zbOFt1x7bOm3XecmbBNeSZppKUzd2ly9/a1pjo+qmevjB2bads0+z7fTT7bjriw0hVrH7ZmZ6zMz1mZ8T7UEKJBSCMEgpBASCkEBIKQQEgpBASCkEBIKQQEgpBASCkEBIKQA1BFIIiqSgikEKJQRSCFEoIpBCiUEUghRKCKQQolBFIIUSgikEKJQRSCFEoIpBCiUEUghRKCKQQolBFIIUSgikEKJQRSCFEoIpBCiUEUghRKCKQQolBFIIUSjTUaKNBSCOdUkFIIUSCkEKJBSCFEgpBCiQUghRIKQQokFIIUSCkEKJBSCFEgpBCiQUghRIKQQokFIIUSCkEKJBSCFEgpBCiQUghRIKQQokFICjQAS0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH//2Q=="
];

final socket = WebSocket(
  Uri.parse('ws://192.168.88.12:443'),
);

// General
Future<String> process(String input, String context) async {
  String data = input + context;
  await socket.connection.firstWhere((state) => state is Connected);

  final Completer<String> completer = Completer<String>();

  socket.send('process¬$authentication_key¬$data');

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

  socket.send(
      'send_data¬$authentication_key¬General Information about the user, complete name ${account!.displayName}, email ${account!.email} additional data $data');

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

  socket.send('speak¬$authentication_key¬$data');

  final subscription = socket.messages.listen((pcm) {
    // play pcm over ble
    print(pcm);
    completer.complete();
  });

  await completer.future;
  await subscription.cancel();
}

Future<void> wait(String seconds) async {
  print('test');
  //await Future.delayed(Duration(seconds: seconds));
}

// Camera
Future<void> take_picture() async {
  // send picture
  await socket.connection.firstWhere((state) => state is Connected);

  socket.send(
      'media¬$authentication_key¬${last_recording[0]}'); // take picture and send

  last_recording = [];
}

Future<void> start_recording() async {
  recording = true;
}

Future<void> stop_recording(String task) async {
  await socket.connection.firstWhere((state) => state is Connected);

  final Completer<void> completer = Completer<void>();

  String data = last_recording[0].toString();

  socket.send('vision¬$authentication_key¬$task.¬$data');

  final subscription = socket.messages.listen((response) async {
    if (response[0] == 'v') {
      await speak(response.toString().substring(1));
      completer.complete(response);
    }
  });

  await completer.future;
  await subscription.cancel();
  recording = false;
}

Future<void> change_volume(volume) async {
  volume = volume;
}

// Docs
Future<void> get_document(document) async {}

Future<String> get_document_id(document) async {
  final GoogleAPIClient httpClient =
      GoogleAPIClient((await account?.authHeaders)!);
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
  final GoogleAPIClient httpClient =
      GoogleAPIClient((await account?.authHeaders)!);
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
  final GoogleAPIClient httpClient =
      GoogleAPIClient((await account?.authHeaders)!);
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
  final GoogleAPIClient httpClient =
      GoogleAPIClient((await account?.authHeaders)!);
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
  final GoogleAPIClient httpClient =
      GoogleAPIClient((await account?.authHeaders)!);
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
  final GoogleAPIClient httpClient =
      GoogleAPIClient((await account?.authHeaders)!);
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
  final GoogleAPIClient httpClient =
      GoogleAPIClient((await account?.authHeaders)!);
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
  final GoogleAPIClient httpClient =
      GoogleAPIClient((await account?.authHeaders)!);
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

  final GoogleAPIClient httpClient =
      GoogleAPIClient((await account?.authHeaders)!);
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
