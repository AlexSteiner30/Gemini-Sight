import 'package:app/helper/commands.dart';

// Define your functions as before
int multiplyBy2(int input, int x) {
  return input * 2 + x;
}

String concatenate(String input1, String input2) {
  return input1 + input2;
}

bool negate(bool input) {
  return !input;
}

dynamic evaluate(String expression) async {
  expression = expression.trim();

  if (expression.contains('(') && expression.endsWith(')')) {
    int indexOfOpenParen = expression.indexOf('(');
    String functionName = expression.substring(0, indexOfOpenParen);
    String argumentPart =
        expression.substring(indexOfOpenParen + 1, expression.length - 1);

    List<dynamic> arguments = _parseArguments(argumentPart);

    List<Future<dynamic>> futures = arguments.map((arg) async {
      if (arg is String && arg.contains('(') && arg.endsWith(')')) {
        return await evaluate(arg);
      } else {
        return arg;
      }
    }).toList();

    List<dynamic> evaluatedArgs = await Future.wait(futures);

    switch (functionName) {
      case 'process':
        if (evaluatedArgs.length != 1) {
          throw Exception('process requires exactly 1 argument');
        }
        String data = evaluatedArgs[0];
        return await process(data);

      case 'send_data':
        if (evaluatedArgs.length != 1) {
          throw Exception('send_data requires exactly 1 argument');
        }
        String data = evaluatedArgs[0];
        return await send_data(data);

      case 'speak':
        if (evaluatedArgs.length != 1) {
          throw Exception('speak requires exactly 1 argument');
        }
        String data = evaluatedArgs[0];
        return await speak(data);

      case 'start_recording':
        return await start_recording();

      case 'stop_recording':
        return await stop_recording();

      case 'start_route':
        if (evaluatedArgs.length != 1) {
          throw Exception('start_route requires exactly 1 argument');
        }
        dynamic route = evaluatedArgs[0];
        return await start_route(route);

      case 'stop_route':
        return await stop_route();

      case 'get_document':
        if (evaluatedArgs.length != 1) {
          throw Exception('get_document requires exactly 1 argument');
        }
        dynamic document = evaluatedArgs[0];
        return await get_document(document);

      case 'write_document':
        if (evaluatedArgs.length != 2) {
          throw Exception('write_document requires exactly 2 arguments');
        }
        dynamic document = evaluatedArgs[0];
        Map<String, dynamic> data = evaluatedArgs[1];
        return await write_document(document, data);

      case 'get_sheet':
        if (evaluatedArgs.length != 1) {
          throw Exception('get_sheet requires exactly 1 argument');
        }
        dynamic sheet = evaluatedArgs[0];
        return await get_sheet(sheet);

      case 'write_sheet':
        if (evaluatedArgs.length != 2) {
          throw Exception('write_sheet requires exactly 2 arguments');
        }
        String sheet = evaluatedArgs[0];
        Map<String, dynamic> data = evaluatedArgs[1];
        return await write_sheet(sheet, data);

      case 'change_volume':
        if (evaluatedArgs.length != 1) {
          throw Exception('change_volume requires exactly 1 argument');
        }
        dynamic volume = evaluatedArgs[0];
        return await change_volume(volume);

      case 'drive_get_file':
        if (evaluatedArgs.length != 1) {
          throw Exception('drive_get_file requires exactly 1 argument');
        }
        dynamic file = evaluatedArgs[0];
        return await drive_get_file(file);

      case 'drive_push_file':
        if (evaluatedArgs.length != 2) {
          throw Exception('drive_push_file requires exactly 2 arguments');
        }
        dynamic file = evaluatedArgs[0];
        dynamic data = evaluatedArgs[1];
        return await drive_push_file(file, data);

      case 'wait':
        if (evaluatedArgs.length != 1) {
          throw Exception('wait requires exactly 1 argument');
        }
        int seconds = evaluatedArgs[0];
        return await wait(seconds);

      case 'record_speed':
        return await record_speed();

      case 'stop_speed':
        return await stop_speed();

      case 'play_song':
        if (evaluatedArgs.length != 1) {
          throw Exception('play_song requires exactly 1 argument');
        }
        String song = evaluatedArgs[0];
        return await play_song(song);

      case 'contacts':
        if (evaluatedArgs.length != 1) {
          throw Exception('contacts requires exactly 1 argument');
        }
        String name = evaluatedArgs[0];
        return await contacts(name);

      case 'call':
        if (evaluatedArgs.length != 1) {
          throw Exception('call requires exactly 1 argument');
        }
        String phone_number = evaluatedArgs[0];
        return await call(phone_number);

      case 'text':
        if (evaluatedArgs.length != 2) {
          throw Exception('text requires exactly 2 arguments');
        }
        String phone_number = evaluatedArgs[0];
        String message = evaluatedArgs[1];
        return await text(phone_number, message);

      case 'get_calendar_events':
        return await get_calendar_events();

      case 'read_email':
        return await read_email();

      case 'search_emails':
        if (evaluatedArgs.length != 1) {
          throw Exception('search_emails requires exactly 1 argument');
        }
        String query = evaluatedArgs[0];
        return await search_emails(query);

      case 'reply_to_email':
        if (evaluatedArgs.length != 2) {
          throw Exception('reply_to_email requires exactly 2 arguments');
        }
        String messageId = evaluatedArgs[0];
        String replyText = evaluatedArgs[1];
        return await reply_to_email(messageId, replyText);

      case 'send_email':
        if (evaluatedArgs.length != 3) {
          throw Exception('send_email requires exactly 3 arguments');
        }
        String to = evaluatedArgs[0];
        String subject = evaluatedArgs[1];
        String body = evaluatedArgs[2];

        return await send_email(to, subject, body);

      default:
        throw Exception('Function $functionName not found');
    }
  }

  return expression;
}

List<dynamic> _parseArguments(String argumentsString) {
  List<dynamic> arguments = [];

  List<String> parts = argumentsString.split(',');
  for (var part in parts) {
    var trimmedPart = part.trim();

    if (RegExp(r'^-?\d+$').hasMatch(trimmedPart)) {
      arguments.add(int.parse(trimmedPart));
    } else if (trimmedPart == 'true' || trimmedPart == 'false') {
      arguments.add(trimmedPart == 'true');
    } else {
      arguments.add(trimmedPart);
    }
  }

  return arguments;
}

Future<void> parse(String input) async {
  input = input.replaceAll('[', '').replaceAll(']', '');

  List<String> expressions = [
    'send_email("alex.steiner@student.h-is.com", "My Events", "${await get_calendar_events()}")'
  ];

  for (var expression in expressions) {
    try {
      evaluate(expression);
    } catch (e) {
      print('Error evaluating expression: $e');
    }
  }
}
