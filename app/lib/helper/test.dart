import 'dart:async';

// Define the functions
Future<void> call(String contact) async {
  print('Calling $contact');
}

Future<String> contacts(String name) async {
  print('Retrieving contact for $name');
  return Future.delayed(
      Duration(seconds: 1), () => '+39351517408'); // Example return value
}

Future<void> sendEmail(String recipient, String subject, String body) async {
  print('Sending email to $recipient with subject "$subject" and body "$body"');
}

// Function registry
Map<String, Function> functionRegistry = {
  'call': call,
  'send_email': sendEmail,
  'contacts': contacts
};

// Dispatcher function to call the appropriate function
Future<dynamic> dispatcher(String functionName, List<dynamic> args) async {
  if (functionRegistry.containsKey(functionName)) {
    Function function = functionRegistry[functionName]!;
    return await Function.apply(function, args);
  } else {
    print('Function not found: $functionName');
    return null;
  }
}

// Function to parse the input string and execute the functions
Future<void> parseAndExecute(String input) async {
  // Remove surrounding square brackets if they exist
  if (input.startsWith('[') && input.endsWith(']')) {
    input = input.substring(1, input.length - 1);
  }

  // Split the string by '),' but keep track of nested functions
  List<String> calls = _splitCalls(input);

  for (String call in calls) {
    await _parseFunction(call.trim());
  }
}

// Function to split calls considering nested functions
List<String> _splitCalls(String input) {
  List<String> calls = [];
  int nestedLevel = 0;
  StringBuffer currentCall = StringBuffer();

  for (int i = 0; i < input.length; i++) {
    if (input[i] == '(') {
      nestedLevel++;
    } else if (input[i] == ')') {
      nestedLevel--;
    } else if (input[i] == ',' && nestedLevel == 0) {
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

// Recursive function to parse and execute the function calls
Future<dynamic> _parseFunction(String input) async {
  int index = 0;
  while (index < input.length && input[index] != '(') {
    index++;
  }

  if (index == input.length) {
    throw FormatException('Invalid input string');
  }

  String functionName = input.substring(0, index).trim();
  index++; // Skip '('

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
    } else if (input[index] == ',' && nestedLevel == 0) {
      args.add(await _parseArgument(currentArg.toString().trim()));
      currentArg.clear();
    } else {
      currentArg.write(input[index]);
    }
    index++;
  }

  return await dispatcher(functionName, args);
}

// Function to parse individual arguments
Future<dynamic> _parseArgument(String arg) async {
  arg = arg.trim();
  if (arg.contains('(')) {
    // It's a nested function call
    return await _parseFunction(arg);
  } else if (arg.startsWith("'") && arg.endsWith("'")) {
    // It's a string argument
    return arg.substring(1, arg.length - 1);
  } else if (arg.contains('+')) {
    // Handle string concatenation
    return await _evaluateConcatenation(arg);
  } else {
    // It's a variable or simple value
    return arg;
  }
}

// Function to evaluate string concatenation
Future<String> _evaluateConcatenation(String expression) async {
  List<String> parts = expression.split('+');
  StringBuffer result = StringBuffer();

  for (String part in parts) {
    String trimmedPart = part.trim();
    if (trimmedPart.contains('(')) {
      // It's a nested function call
      result.write(await _parseFunction(trimmedPart));
    } else if (trimmedPart.startsWith("'") && trimmedPart.endsWith("'")) {
      // It's a string argument
      result.write(trimmedPart.substring(1, trimmedPart.length - 1));
    } else {
      // It's a variable or simple value
      result.write(trimmedPart);
    }
  }

  return result.toString();
}

Future<void> main() async {
  String inputString =
      "[call(contacts('Anna')), send_email('Alex.steiner@student.h-is.com', 'Meeting', 'You are required to attend this meeting'), call(contacts('John'))]";
  await parseAndExecute(inputString);
}
