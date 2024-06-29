import 'package:app/helper/commands.dart';

typedef DynamicFunction = Future<dynamic> Function(List<dynamic>);

Map<String, Function> functionRegistry = {
  'process': process,
  'send_data': send_data,
  'speak': speak,
  'start_recording': start_recording,
  'stop_recording': stop_recording,
  'start_route': start_route,
  'stop_route': stop_route,
  'get_document': get_document,
  'write_document': write_document,
  'get_sheet': get_sheet,
  'write_sheet': write_sheet,
  'change_volume': change_volume,
  'drive_get_file': drive_get_file,
  'drive_push_file': drive_push_file,
  'wait': wait,
  'record_speed': record_speed,
  'stop_speed': stop_speed,
  'play_song': play_song,
  'contacts': contacts,
  'call': call,
  'text': text,
  'get_calendar_events': get_calendar_events,
  'read_email': read_email,
  'search_emails': search_emails,
  'reply_to_email': reply_to_email,
  'send_email': send_email,
};

Future<dynamic> dispatcher(String functionName, List<dynamic> args) async {
  if (functionRegistry.containsKey(functionName)) {
    Function function = functionRegistry[functionName]!;
    return await Function.apply(function, args);
  } else {
    print('Function not found: $functionName');
    return null;
  }
}

Future<void> parseAndExecute(String input) async {
  if (input.startsWith('[') && input.endsWith(']')) {
    input = input.substring(1, input.length - 1);
  }

  List<String> calls = _splitCalls(input);

  for (String call in calls) {
    await _parseFunction(call.trim());
  }
}

List<String> _splitCalls(String input) {
  List<String> calls = [];
  int nestedLevel = 0;
  StringBuffer currentCall = StringBuffer();

  for (int i = 0; i < input.length; i++) {
    if (input[i] == '(') {
      nestedLevel++;
    } else if (input[i] == ')') {
      nestedLevel--;
    } else if (input[i] == '¬' && nestedLevel == 0) {
      calls.add(currentCall.toString());
      currentCall.clear();
      continue;
    }
    currentCall.write(input[i]);
  }

  if (currentCall.isNotEmpty) {
    calls.add(currentCall.toString());
  }

  return calls;
}

Future<dynamic> _parseFunction(String input) async {
  int index = 0;
  while (index < input.length && input[index] != '(') {
    index++;
  }

  if (index == input.length) {
    throw FormatException('Invalid input string');
  }

  String functionName = input.substring(0, index).trim();
  index++;

  List<dynamic> args = [];
  StringBuffer currentArg = StringBuffer();

  int nestedLevel = 0;
  while (index < input.length) {
    if (input[index] == '(') {
      nestedLevel++;
      currentArg.write(input[index]);
    } else if (input[index] == ')') {
      if (nestedLevel == 0) {
        if (currentArg.isNotEmpty) {
          args.add(await _parseArgument(currentArg.toString().trim()));
        }
        break;
      } else {
        nestedLevel--;
        currentArg.write(input[index]);
      }
    } else if (input[index] == '¬' && nestedLevel == 0) {
      args.add(await _parseArgument(currentArg.toString().trim()));
      currentArg.clear();
    } else {
      currentArg.write(input[index]);
    }
    index++;
  }

  return await dispatcher(functionName, args);
}

Future<dynamic> _parseArgument(String arg) async {
  arg = arg.trim();
  if (arg.contains('(')) {
    return await _parseFunction(arg);
  } else if (arg.startsWith("|") && arg.endsWith("|")) {
    return arg.substring(1, arg.length - 1);
  } else if (arg.contains('+')) {
    return await _evaluateConcatenation(arg);
  } else {
    return arg;
  }
}

Future<String> _evaluateConcatenation(String expression) async {
  List<String> parts = expression.split('+');
  StringBuffer result = StringBuffer();

  for (String part in parts) {
    String trimmedPart = part.trim();
    if (trimmedPart.contains('(')) {
      result.write(await _parseFunction(trimmedPart));
    } else if (trimmedPart.startsWith("|") && trimmedPart.endsWith("|")) {
      result.write(trimmedPart.substring(1, trimmedPart.length - 1));
    } else {
      result.write(trimmedPart);
    }
  }

  return result.toString();
}

Future<void> parse(String input) async {
  parseAndExecute(input);
}
