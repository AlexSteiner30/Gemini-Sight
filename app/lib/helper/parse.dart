import 'package:app/helper/commands.dart';

void parse(String input) {
  input = input.replaceAll('\\"', '"');
  input = input.replaceAll('[', '').replaceAll(']', '');

  List<String> actions = input.split('¬');
  for (String action in actions) {
    RegExp regex = RegExp(r'(\w+)\((.*)\)');
    RegExpMatch? match = regex.firstMatch(action);
    if (match != null) {
      String functionName = match.group(1)!;
      String arguments = match.group(2)!;

      executeFunction(functionName, arguments);
    }
  }
}

Future<void> executeFunction(functionName, args) async {
  switch (functionName) {
    case 'speak':
      await speak(args);
    case 'start_recording':
      await start_recording();
    case 'stop_recording':
      await stop_recording();
    case 'start_route':
      await start_route(args);
    case 'stop_route':
      await stop_route();
    case 'read_email':
      await get_emails();
  }
}

dynamic resolveVariable(String variable) {
  print(variable);
  var context = {
    'avg_speed': 15,
    'time_taken': '1 hour',
  };

  return context[variable] ?? variable;
}
