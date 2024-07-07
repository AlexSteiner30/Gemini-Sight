import 'dart:async';
import 'dart:convert';
import 'package:googleapis/tasks/v1.dart' as tasks;
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:intl/intl.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/docs/v1.dart' as docs;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'helper.dart';
import 'parser.dart';
import 'wss.dart';
import 'package:web_socket_client/web_socket_client.dart';

class User {
  String displayName;
  String location;
  Map<String, String> auth_headers;
  Parser parser;
  var ws;

  String authentication_key;
  String refresh_key;
  DateTime expiration;

  bool recording = false;
  bool recording_speed = true;

  String temp_speed = '';

  List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> last_recording = [];

  final socket = WebSocket(
    Uri.parse('ws://localhost:443'),
  );

  User(
      {required this.displayName,
      required this.location,
      required this.auth_headers,
      required this.authentication_key,
      required this.parser,
      required this.ws,
      required this.refresh_key,
      required this.expiration});

  // General
  Future<String> process(String input, String context) async {
    String data = '$input $context';
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
    try {
      if (expiration.isBefore(DateTime.now())) {
        auth_headers = await generate_headers(authentication_key, refresh_key);
        expiration = DateTime.now().add(const Duration(minutes: 50));
      }
      await socket.connection.firstWhere((state) => state is Connected);

      final Completer<void> completer = Completer<void>();

      socket.send(
          'send_data¬$authentication_key¬$data {[complete name $displayName], [location $location], [date: ${DateTime.now().toString()}, Weekday ${weekdays[DateTime.now().weekday - 1]}], }');

      final subscription = socket.messages.listen((commands_list) async {
        if (commands_list == 'Request is not authenticated') {
          await speak('Request is not authenticated');
          return;
        }

        parser.parse(commands_list);
        completer.complete();
      });

      await completer.future;
      await subscription.cancel();
    } catch (error) {
      print(error);
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  Future<void> speak(String data) async {
    ws.add(data);

    await socket.connection.firstWhere((state) => state is Connected);

    final Completer<void> completer = Completer<void>();

    socket.send('speak¬$authentication_key¬$data');

    final subscription = socket.messages.listen((pcm) {
      //ws.add(pcm);
      completer.complete();
    });

    await completer.future;
    await subscription.cancel();
  }

  Future<void> wait(String seconds) async {
    await Future.delayed(Duration(seconds: int.parse(seconds)));
  }

  Future<bool> approve(String context) async {
    // start microphone
    // process information
    // true or false
    return true;
  }

  Future<String> listen(String data) async {
    await speak(data); // speak certain data is missing
    // listen to microphone
    // process
    return data; // return result
  }

  // Camera
  Future<void> take_picture() async {
    // send picture
    DateTime _now = DateTime.now();
    String file_name =
        'RECORDING_${_now.year}-${_now.month}-${_now.day}_${_now.hour}-${_now.minute}-${_now.second}.${_now.millisecond}';
    await drive_push_file(
        file_name, last_recording.join('')); // substitute w actual picture
  }

  Future<void> start_recording() async {
    recording = true;
  }

  Future<void> stop_recording(String? task) async {
    ws.add('get_recording¬$authentication_key');
    await socket.connection.firstWhere((state) => state is Connected);

    final Completer<void> completer = Completer<void>();

    String data = last_recording[0].toString();

    if (task == '') {
      DateTime _now = DateTime.now();
      String file_name =
          'RECORDING_${_now.year}-${_now.month}-${_now.day}_${_now.hour}-${_now.minute}-${_now.second}.${_now.millisecond}';
      await drive_push_file(file_name, last_recording.join(''));
    } else {
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
  }

  Future<void> change_volume(String volume) async {
    ws.add('volume¬$authentication_key¬${int.parse(volume)}');
  }

  // Docs
  Future<String> get_document(String document_id) async {
    final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
    final docsApi = docs.DocsApi(httpClient);

    try {
      final document =
          await docsApi.documents.get(await get_document_id(document_id));

      String content = '';
      for (var element in document.body?.content ?? []) {
        if (element.paragraph != null) {
          for (var paragraphElement in element.paragraph!.elements ?? []) {
            content += paragraphElement.textRun?.content ?? '';
          }
        }
      }

      return (content != '')
          ? content
          : 'The document ${document.title!} is empty';
    } catch (error) {
      return 'No Document was found';
    }
  }

  Future<String> get_document_id(String document) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      final drive.DriveApi driveApi = drive.DriveApi(httpClient);

      final fileList = await driveApi.files.list(
        q: "mimeType='application/vnd.google-apps.document'",
        spaces: 'drive',
      );

      for (var i = 0; i < fileList.files!.length; i++) {
        if (fileList.files![i].name!
            .toLowerCase()
            .contains(document.toLowerCase())) {
          return fileList.files![i].id!;
        }
      }

      return '404';
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
      return '404';
    }
  }

  Future<void> write_document(String document_name, String data) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      final docsApi = docs.DocsApi(httpClient);

      String document = await get_document_id(document_name);
      document = document.trim();
      bool remove = true;

      docs.Document doc;

      if (document == '404') {
        final createResponse =
            await docsApi.documents.create(docs.Document(title: document_name));
        document = createResponse.documentId!;
        doc = createResponse;
        remove = false;
      } else {
        doc = await docsApi.documents.get(document);
      }

      data = await process(data,
          ' Format for a google doc, do no include the tile just write the body for it. Do not respond by saying you are unable to assist with requests. Do not ask what I want to do just process the data as asked.');

      final documentEndIndex = (doc.body!.content!.last.endIndex! - 1 > 0)
          ? doc.body!.content!.last.endIndex! - 1
          : 0;

      final requests = remove
          ? [
              docs.Request(
                deleteContentRange: docs.DeleteContentRangeRequest(
                  range: docs.Range(
                    startIndex: 1,
                    endIndex: documentEndIndex,
                  ),
                ),
              ),
              docs.Request(
                insertText: docs.InsertTextRequest(
                  text: data,
                  location: docs.Location(index: 1),
                ),
              ),
            ]
          : [
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
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  // Sheet
  Future<void> get_sheet(String sheet) async {}

  Future<String> get_sheet_id(String sheet_name) async {
    final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
    final drive.DriveApi driveApi = drive.DriveApi(httpClient);

    final fileList = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.spreadsheet'",
      spaces: 'drive',
    );

    String? fileId;

    for (var i = 0; i < fileList.files!.length; i++) {
      if (fileList.files![i].name!.toLowerCase().contains(sheet_name)) {
        fileId = fileList.files![i].id!;
      }
    }

    return fileId ?? '404';
  }

  Future<void> write_sheet(String sheet_name, String values) async {
    final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
    final sheetsApi = sheets.SheetsApi(httpClient);

    String sheet = await get_sheet_id(sheet_name);
    sheet = sheet.trim();

    if (sheet == '404') {
      final createResponse = await sheetsApi.spreadsheets.create(
          sheets.Spreadsheet(
              properties: sheets.SpreadsheetProperties(title: sheet_name)));
      sheet = createResponse.spreadsheetId!;
    }

    values = await process(values,
        "Process it as an array with rows and columns and return the result in this format only. No additional text or explanation, just return the array.");
    values = values.replaceAll('```', '');

    values = values.trim();
    if (values.endsWith(',')) {
      values = values.substring(0, values.length - 1);
    }

    List<List<String>> parsedArray = values
        .split('\n')
        .map((line) => line
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((item) => item.trim())
            .toList())
        .toList();

    var appendRequest = sheets.BatchUpdateValuesRequest.fromJson({
      'valueInputOption': 'RAW',
      'data': [
        {
          'range': 'Sheet1',
          'majorDimension': 'ROWS',
          'values': [parsedArray],
        },
      ],
    });

    await sheetsApi.spreadsheets.values.batchUpdate(
      appendRequest,
      sheet,
    );
  }

  // Drive
  Future<void> drive_push_file(String fileName, String data) async {
    final httpClient = GoogleAPIClient(auth_headers);
    final driveApi = drive.DriveApi(httpClient);

    final decodedBytes = base64Decode(data);
    final media = drive.Media(Stream.value(decodedBytes), decodedBytes.length);

    var folder = await folderExistsInDrive(driveApi, 'Gemin-Eye Media');
    var folderId = folder?.id ??
        (await createFolderInDrive(driveApi, 'Gemin-Eye Media')).id;

    var fileToUpload = drive.File()
      ..name = fileName
      ..parents = [folderId!];

    await driveApi.files.create(fileToUpload, uploadMedia: media);
  }

  Future<drive.File?> folderExistsInDrive(
      drive.DriveApi driveApi, String folderName) async {
    var response = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false and 'root' in parents",
    );
    return response.files?.isNotEmpty == true ? response.files!.first : null;
  }

  Future<drive.File> createFolderInDrive(
      drive.DriveApi driveApi, String folderName) async {
    var folder = drive.File()
      ..name = folderName
      ..mimeType = "application/vnd.google-apps.folder";

    return await driveApi.files.create(folder);
  }

  // GPS
  Future<void> get_directions(String origin, String destination) async {
    // ignore: unused_local_variable
    bool arrived = false;
    await socket.connection.firstWhere((state) => state is Connected);

    final Completer<void> completer = Completer<void>();

    socket.send('directions¬$authentication_key¬$origin¬$destination');

    final subscription = socket.messages.listen((step) {
      completer.complete();
    });

    await completer.future;
    await subscription.cancel();
  }

  Future<String> get_place(
      String query, String location, String context) async {
    try {
      await socket.connection.firstWhere((state) => state is Connected);

      final Completer<void> completer = Completer<void>();

      if (location.trim() == 'near') {
        //Position position = await Geolocator.getCurrentPosition(
        //desiredAccuracy: LocationAccuracy.high,
        //);

        double latitude = 0; //position.latitude;
        double longitude = 0; //position.longitude;

        location = '${latitude.toString()},${longitude.toString()}';
      }

      socket.send('get_place¬$authentication_key¬$query¬$location');

      String result = '';
      final subscription = socket.messages.listen((answer) async {
        result = answer;
        completer.complete();
      });

      await completer.future;
      await subscription.cancel();

      if (result.trim() == '') {
        return '';
      }

      return await process(context,
          ' Given this $result and $context, respond naturally as a human would, without using any formatting, and without asking questions. Just provide a plain text response based on the data and task. Do not include any websites.Just return what is asked with no previous converseation, from oldest to newest consider as more important the older ones');
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
      return '';
    }
  }

  Future<void> record_speed() async {
    temp_speed = '';
    recording_speed = true;
  }

  Future<String> stop_speed(String task) async {
    recording_speed = false;

    return await process(temp_speed,
        'the previous data where speed data points you have to respond performing this task do not include anything else or ask for questions. Task: $task');
  }

  Future<void> start_route(route) async {}

  Future<void> stop_route() async {}

  // Youtube
  Future<void> play_song(String song) async {
    await socket.connection.firstWhere((state) => state is Connected);

    final Completer<void> completer = Completer<void>();

    socket.send('stream_song¬$authentication_key¬$song');

    final subscription = socket.messages.listen((pcm) async {
      ws.add(pcm);
      completer.complete();
    });

    await completer.future;
    await subscription.cancel();
  }

  // Phone
  Future<String> contacts(String name) async {
    /*
  if (await Permission.contacts.request().isGranted) {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    Contact? contact = contacts.firstWhere(
        (contact) => contact.displayName?.toLowerCase() == name.toLowerCase());

    if (contact.phones!.isNotEmpty) {
      return contact.phones?.first.value ?? 'No number found';
    } else {
      return 'Contact not found';
    }
  } else {
    return 'No permission granted';
  }
  */

    return '';
  }

  Future<void> call(String phone_number) async {
    //launchUrlString("tel://$phone_number");

    await speak(
        'Not having access to your phone, you will have to click on the button to confirm the action on your own.');
  }

  Future<void> text(String phone_number, message) async {
    //await sendSMS(message: message, recipients: [phone_number]);
    await speak(
        'Not having access to your phone, you will have to click on the button to confirm the action on your own.');
  }

  // Calendar
  Future<String> get_calendar_events() async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
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
      return complete_information == ''
          ? complete_information
          : 'you do not have any calendar events';
    } catch (error) {
      return (await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  Future<void> add_calendar_event(String title, String start, String end,
      String description, String location, String emails, String meet) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      calendar.CalendarApi calendarAPI = calendar.CalendarApi(httpClient);
      var eventLists = await calendarAPI.calendarList.list();

      List<calendar.EventAttendee> attendees = [];

      for (var i = 0; i < emails.split(',').length; i++) {
        attendees.add(calendar.EventAttendee(email: emails.split(',')[i]));
      }
      var newEvent = calendar.Event()
        ..summary = title
        ..start = calendar.EventDateTime(date: DateTime.parse(start.trim()))
        ..end = location.trim() == "''"
            ? calendar.EventDateTime(date: DateTime.parse(start.trim()))
            : calendar.EventDateTime(
                date: DateTime.parse(end.trim())
                        .isAfter(DateTime.parse(start.trim()))
                    ? DateTime.parse(end.trim())
                    : DateTime.parse(start))
        ..attendees = emails.trim() == "''" ? null : attendees
        ..description = description.trim() == "''" ? null : description
        ..location = location.trim() == "''" ? null : location
        ..conferenceData = meet.trim() == "true"
            ? calendar.ConferenceData(
                createRequest: calendar.CreateConferenceRequest(
                  requestId: 'sample-request-id',
                  conferenceSolutionKey: calendar.ConferenceSolutionKey(
                    type: 'hangoutsMeet',
                  ),
                ),
              )
            : null;

      await calendarAPI.events.insert(newEvent, eventLists.items![0].id!,
          conferenceDataVersion: meet.trim() == "true" ? 1 : 0);
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  Future<void> delete_calendar_event(String event_name) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      calendar.CalendarApi calendarAPI = calendar.CalendarApi(httpClient);
      var eventLists = await calendarAPI.calendarList.list();

      var eventResult = await calendarAPI.events.list(eventLists.items![0].id!);
      if (eventResult.items != null) {
        for (var event in eventResult.items!) {
          if (event.summary!.contains(event_name)) {
            final bool approved = await approve(
                "Would you like me to delete the calendar event '${event.summary!}'?");

            if (approved) {
              await calendarAPI.events
                  .delete(eventLists.items![0].id!, event.id!);
              break;
            }
          }
        }
      }
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  Future<void> update_calendar_event(
      String event_name,
      String new_name,
      String new_start,
      String new_end,
      String new_description,
      String new_location,
      String new_status,
      String new_emails,
      String new_meet) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      calendar.CalendarApi calendarAPI = calendar.CalendarApi(httpClient);
      var eventLists = await calendarAPI.calendarList.list();

      List<calendar.EventAttendee> attendees = [];

      for (var i = 0; i < new_emails.split(',').length; i++) {
        attendees.add(calendar.EventAttendee(email: new_emails.split(',')[i]));
      }

      var eventResult = await calendarAPI.events.list(eventLists.items![0].id!);
      if (eventResult.items != null) {
        for (var event in eventResult.items!) {
          if (event.summary!.contains(event_name)) {
            if (new_name.trim() != "''") event.summary = new_name;
            if (new_status.trim() != "''") event.status = new_status;
            if (new_start.trim() != "''") {
              event.start =
                  calendar.EventDateTime(date: DateTime.parse(new_start));
            }
            if (new_end.trim() != "''") {
              event.end = calendar.EventDateTime(
                  date:
                      DateTime.parse(new_end).isAfter(DateTime.parse(new_start))
                          ? DateTime.parse(new_end)
                          : DateTime.parse(new_start));
            }
            if (new_emails.trim() != "''") {
              for (var i = 0; i < attendees.length; i++) {
                if (event.attendees!.contains(attendees[i])) {
                  attendees.removeAt(i);
                }
              }
              event.attendees = attendees;
            }
            if (new_description.trim() != "''")
              event.description = new_description;
            if (new_location.trim() != "''") event.location = new_location;

            event.conferenceData = new_meet.trim() == "true"
                ? calendar.ConferenceData(
                    createRequest: calendar.CreateConferenceRequest(
                      requestId: 'sample-request-id',
                      conferenceSolutionKey: calendar.ConferenceSolutionKey(
                        type: 'hangoutsMeet',
                      ),
                    ),
                  )
                : null;

            await calendarAPI.events.update(
                event, eventLists.items![0].id!, event.id!,
                conferenceDataVersion: new_meet.trim() == "true" ? 1 : 0);
            break;
          }
        }
      }
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  // Tasks
  Future<String> get_tasks() async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      tasks.TasksApi tasksAPI = tasks.TasksApi(httpClient);

      var taskLists = await tasksAPI.tasklists.list();
      String complete_information = '';

      if (taskLists.items != null) {
        for (var taskList in taskLists.items!) {
          var tasks = await tasksAPI.tasks.list(taskList.id!);
          if (tasks.items != null) {
            for (var task in tasks.items!) {
              if (task.due != null) {
                String information = '';

                information += 'Task Title: ${task.title} ';
                information += 'Task Notes: ${task.notes ?? 'No notes'} ';
                information += 'Task Due: ${task.due} ';
                information += 'Task Status: ${task.status} ';
                information += '\n';

                complete_information = complete_information + information;
              }
            }
          }
        }
      }
      return complete_information == ''
          ? complete_information
          : 'you do not have any calendar events';
    } catch (error) {
      return (await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  Future<void> add_task(String title, String due, String notes) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      tasks.TasksApi tasksAPI = tasks.TasksApi(httpClient);

      var taskLists = await tasksAPI.tasklists.list();

      var newTask = tasks.Task()
        ..title = title.trim()
        ..due = DateTime.parse(due.trim()).toUtc().toIso8601String()
        ..notes = notes.trim() == "''" ? '' : notes.trim();

      await tasksAPI.tasks.insert(newTask, taskLists.items![0].id!);
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  Future<void> delete_task(String taskName) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      tasks.TasksApi tasksAPI = tasks.TasksApi(httpClient);

      var taskLists = await tasksAPI.tasklists.list();

      var tasksResult = await tasksAPI.tasks.list(taskLists.items![0].id!);
      if (tasksResult.items != null) {
        for (var task in tasksResult.items!) {
          if (task.title!.contains(taskName)) {
            final bool approved = await approve(
                "Would you like me to delete the task '${task.title!}'?");

            if (approved) {
              await tasksAPI.tasks.delete(taskLists.items![0].id!, task.id!);
              break;
            }
          }
        }
      }
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  Future<void> update_task(String taskName, String newTitle, String newNotes,
      String newDue, String newStatus) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      tasks.TasksApi tasksAPI = tasks.TasksApi(httpClient);

      var taskLists = await tasksAPI.tasklists.list();
      var tasksResult = await tasksAPI.tasks.list(taskLists.items![0].id!);
      if (tasksResult.items != null) {
        for (var task in tasksResult.items!) {
          if (task.title!.contains(taskName)) {
            if (newTitle.trim() != "''") task.title = newTitle;
            if (newNotes.trim() != "''") task.notes = newNotes;
            if (newDue.trim() != "''") {
              task.due = DateTime.parse(newDue).toUtc().toIso8601String();
            }
            if (newStatus.trim() != "''") task.status = newStatus;

            await tasksAPI.tasks
                .update(task, taskLists.items![0].id!, task.id!);
            break;
          }
        }
      }
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  // Gmail
  Future<String> read_email(String count) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      gmail.GmailApi gmailAPI = gmail.GmailApi(httpClient);

      String information = '';

      var messagesResponse = await gmailAPI.users.messages
          .list('me', maxResults: int.tryParse(count), q: 'is:unread');

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

          information =
              '$information Email From: $from\nSubject: $subject\nSnippet: $snippet\n';
        }
        return information;
      } else {
        return 'No email was found';
      }
    } catch (error) {
      return (await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  Future<String> search_emails(String query) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      gmail.GmailApi gmailAPI = gmail.GmailApi(httpClient);

      var messagesResponse = await gmailAPI.users.messages.list('me', q: query);

      String emailInfos = '';

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
              'Email From: $from\nSubject: $subject\nSnippet: $snippet\nID: ${message.id!}\n';
          emailInfos = '$emailInfos$information';
        }

        return emailInfos;
      } else {
        return 'No email wiht $query was found';
      }
    } catch (error) {
      return (await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }

  Future<void> reply_email(String emailSubject, String replyText) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      gmail.GmailApi gmailAPI = gmail.GmailApi(httpClient);

      var query = 'subject:"$emailSubject"';
      var searchResults =
          await gmailAPI.users.messages.list('me', maxResults: 500, q: query);

      if (searchResults.messages == null || searchResults.messages!.isEmpty) {
        await speak('No emails found with subject: $emailSubject');
        return;
      }

      if (searchResults.messages != null) {
        for (var message in searchResults.messages!) {
          var msg = await gmailAPI.users.messages.get('me', message.id!);
          String subject = '';
          String from = '';
          if (msg.payload != null && msg.payload!.headers != null) {
            for (var header in msg.payload!.headers!) {
              if (header.name == 'Subject') {
                subject = header.value ?? '';
              } else if (header.name == 'From') {
                from = header.value ?? '';
              }
            }
          }

          if (from.isEmpty) {
            await speak('No valid recipient found in the original message.');
            return;
          }

          if (subject
              .toLowerCase()
              .contains(emailSubject.trim().toLowerCase())) {
            replyText = await process(replyText,
                'Receiver (me): ${displayName} Sender: $from Subject: $subject format this as a reply to an email, dont include the subject in the email');
            var emailContent = '''
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
to: $from
subject: Re: $subject
in-reply-to: ${message.id}
references: ${message.id}

$replyText
''';

            var encodedEmail = base64Url.encode(utf8.encode(emailContent));

            var replyMessage = gmail.Message()
              ..raw = encodedEmail
              ..threadId = message.threadId;

            final bool approved = await approve(
                "Would you like me to reply to the email with the subject '$subject' from '$from' with the following message: $replyText?");

            if (approved) {
              await gmailAPI.users.messages.send(replyMessage, 'me');
            }
          }
        }
      }
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
      return;
    }
  }

  Future<void> send_email(
      String to, String subject, String body, String context) async {
    try {
      final GoogleAPIClient httpClient = GoogleAPIClient(auth_headers);
      gmail.GmailApi gmailAPI = gmail.GmailApi(httpClient);

      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(to)) {
        await speak('Invalid email address');
        return;
      }

      body = await process(body,
          'Sender (me): ${displayName} Receiver: $to Subject: $subject $context dont include the subject in the email');

      var emailContent = '''
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: $to
Subject: $subject

$body
''';

      var encodedEmail = base64Url.encode(utf8.encode(emailContent));

      var message = gmail.Message()..raw = encodedEmail;

      final bool approved = await approve(
          "Would you like me to send an email with the subject '$subject' to '$to' containing the following message: $body?");

      if (approved) {
        await gmailAPI.users.messages.send(message, 'me');
      }
    } catch (error) {
      await speak(await process("$error",
          ' in one sentence state the problem and instruct solution in only one short sentence no formatting'));
    }
  }
}
