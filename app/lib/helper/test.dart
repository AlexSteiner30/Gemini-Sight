// Define your functions as before
int multiplyBy2(int input, int x, int y) {
  return input * 2 + x - y;
}

int get_number() {
  return 3;
}

String concatenate(String input1, String input2) {
  return input1 + input2;
}

bool negate(bool input) {
  return !input;
}

dynamic evaluate(String expression) {
  expression = expression.trim();

  if (expression.contains('(') && expression.endsWith(')')) {
    int indexOfOpenParen = expression.indexOf('(');
    String functionName = expression.substring(0, indexOfOpenParen);
    String argumentPart =
        expression.substring(indexOfOpenParen + 1, expression.length - 1);

    List<dynamic> arguments = _parseArguments(argumentPart);

    List<dynamic> evaluatedArgs = arguments.map((arg) {
      if (arg is String && arg.contains('(') && arg.endsWith(')')) {
        return evaluate(arg);
      } else {
        return arg;
      }
    }).toList();

    switch (functionName) {
      case 'multiplyBy2':
        if (evaluatedArgs.length != 3) {
          throw Exception('multiplyBy2 requires exactly 2 arguments');
        }
        int arg1 = evaluatedArgs[0];
        int arg2 = evaluatedArgs[1];
        int arg3 = evaluatedArgs[2];
        return multiplyBy2(arg1, arg2, arg3);
      case 'concatenate':
        if (evaluatedArgs.length != 2) {
          throw Exception('concatenate requires exactly 2 arguments');
        }
        String arg1 = evaluatedArgs[0];
        String arg2 = evaluatedArgs[1];
        return concatenate(arg1, arg2);
      case 'negate':
        if (evaluatedArgs.length != 1) {
          throw Exception('negate requires exactly 1 argument');
        }
        bool arg = evaluatedArgs[0];
        return negate(arg);
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

void main() {
  var number = 10;
  List<String> expressions = [
    'multiplyBy2(${get_number()}, 3, 5)',
    'concatenate("hello", "world")',
    'negate(negate(false))'
  ];

  for (var expression in expressions) {
    try {
      print(evaluate(expression));
    } catch (e) {
      print('Error evaluating expression: $e');
    }
  }
}
