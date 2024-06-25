import 'dart:convert';

void main() {
  List<String> actions = [
    "record_speed()",
    "speak(\"I'm recording your speed now.\")",
    "start_route(\"Los Angeles\")",
    "stop_speed()",
    "stop_route()",
    "write_sheet(\"bike_trip\", \"Your bike trip data has been recorded in the spreadsheet.\")",
    "speak(\"Your bike trip data has been recorded in the spreadsheet.\")"
  ];

  Map<String, Function> functions = {
    'record_speed': recordSpeed,
    'speak': speak,
    'start_route': startRoute,
    'stop_speed': stopSpeed,
    'stop_route': stopRoute,
    'write_sheet': writeSheet,
  };

  for (String action in actions) {
    executeFunction(action, functions);
  }
}

void executeFunction(String action, Map<String, Function> functions) {
  // Extract the function name and arguments from the string
  RegExp regex = RegExp(r'(\w+)\((.*)\)');
  RegExpMatch? match = regex.firstMatch(action);
  if (match != null) {
    String functionName = match.group(1)!;
    String arguments = match.group(2)!;

    if (functions.containsKey(functionName)) {
      Function functionToCall = functions[functionName]!;
      var args = parseArguments(arguments);
      Function.apply(functionToCall, args);
    }
  }
}

List<dynamic> parseArguments(String arguments) {
  if (arguments.isEmpty) return [];

  // Match individual arguments
  RegExp argRegex = RegExp(r'("[^"]*"|\{[^\}]*\}|[^,]+)');
  Iterable<Match> matches = argRegex.allMatches(arguments);
  return matches.map((match) {
    String arg = match.group(0)!.trim();
    if (arg.startsWith('"') && arg.endsWith('"')) {
      return arg.substring(1, arg.length - 1);
    } else if (arg.startsWith('{') && arg.endsWith('}')) {
      // Manually parse and resolve variables within the map string
      Map<String, dynamic> mapArg = {};
      RegExp mapRegex = RegExp(r'"(\w+)":\s*([^,}]+)');
      Iterable<Match> mapMatches = mapRegex.allMatches(arg);
      for (var mapMatch in mapMatches) {
        String key = mapMatch.group(1)!;
        String value = mapMatch.group(2)!.trim();
        mapArg[key] = resolveVariable(value);
      }
      return mapArg;
    } else {
      print(arg);
      // Assuming any non-string argument is a variable in the scope.
      return resolveVariable(arg);
    }
  }).toList();
}

dynamic resolveVariable(String variable) {
  var context = {
    'avg_speed': 15,
    'time_taken': '1 hour',
  };

  print(context[variable]);
  return context[variable] ?? variable;
}

void recordSpeed() {
  print('Recording speed...');
}

void speak(String message) {
  print('Speaking: $message');
}

void startRoute(String location) {
  print('Starting route to $location...');
}

void stopSpeed() {
  print('Stopping speed recording...');
}

void stopRoute() {
  print('Stopping route...');
}

void writeSheet(String sheetName, data) {
  print('Writing to sheet $sheetName: $data');
}
