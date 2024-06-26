import 'package:app/helper/commands.dart';

Future<void> parse(String input) async {
  List<Future<void> Function()> instructions = parseInstructions(input);
  await executeInstructions(instructions);
}

Future<void> executeInstructions(
    List<Future<void> Function()> instructions) async {
  for (var instruction in instructions) {
    await instruction();
  }
}

List<Future<void> Function()> parseInstructions(String input) {
  List<Future<void> Function()> instructions = [];
  Map<String, Future<void> Function(Map<String, dynamic>)> functionMap = {
    'send_email': (args) async =>
        await send_email(args['to'], args['subject'], args['body']),
  };

  RegExp exp = RegExp(r"(\w+)\(([^)]+)\)");
  Iterable<RegExpMatch> matches = exp.allMatches(input);

  for (var match in matches) {
    String functionName = match.group(1)!;
    String argumentsString = match.group(2)!;
    Map<String, dynamic> args = parseNamedArguments(argumentsString);

    if (functionMap.containsKey(functionName)) {
      print(args);
      instructions.add(() => functionMap[functionName]!(args));
    }
  }

  return instructions;
}

Map<String, dynamic> parseNamedArguments(String argumentsString) {
  Map<String, dynamic> args = {};
  RegExp argExp = RegExp(
      "(\\w+):\\s*'([^']*)'|(\\w+):\\s*\"([^\"]*)\"|(\\w+):\\s*(\\d+(?:\\.\\d+)?)|(\\w+):\\s*(true|false)");
  Iterable<RegExpMatch> argMatches = argExp.allMatches(argumentsString);

  for (var argMatch in argMatches) {
    String key = argMatch.group(1) ??
        argMatch.group(3) ??
        argMatch.group(5) ??
        argMatch.group(7)!;
    String? value = argMatch.group(2) ??
        argMatch.group(4) ??
        argMatch.group(6) ??
        argMatch.group(8);

    if (value != null) {
      if (RegExp(r'^\d+$').hasMatch(value)) {
        args[key] = int.parse(value);
      } else if (RegExp(r'^\d+\.\d+$').hasMatch(value)) {
        args[key] = double.parse(value);
      } else if (value == 'true' || value == 'false') {
        args[key] = value == 'true';
      } else {
        args[key] = value;
      }
    }
  }

  return args;
}
