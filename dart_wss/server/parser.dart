typedef DynamicFunction = Future<dynamic> Function(List<dynamic>);

class Parser {
  Map<String, Function> functionRegistry;
  Parser({required this.functionRegistry});

  /// Dispatcher, excute function with args
  ///
  /// Input:
  ///   - String name of the function
  ///   - List<dynamic> args, can be for e.g. string, int or other functions
  ///
  /// Returns:
  ///   - Dynamic, e.g. function result or null
  Future<dynamic> dispatcher(String functionName, List<dynamic> args) async {
    if (functionRegistry.containsKey(functionName)) {
      // If funtion is found in the Map of the users function, look at wss.dart and user.dart
      Function function = functionRegistry[functionName]!;
      return await Function.apply(
          function, args); // Return & apply function with arks
    } else {
      print('Function not found: $functionName');
      return null;
    }
  }

  /// Parse input and exectue it
  ///
  /// Input:
  ///   - String input to parse and execute -> e.g. [functions here]
  Future<void> parseAndExecute(String input) async {
    try {
      // Gemini sometimes generate its response with [], other times it doesnt, check for it and remove it in case
      if (input.startsWith('[') && input.endsWith(']')) {
        input = input.substring(1, input.length - 1);
      }

      /// Subdivide the input in smaller problems
      /// Parse each problem at the the time
      List<String> calls = _splitCalls(input);

      for (String call in calls) {
        await _parseFunction(call.trim());
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  /// Split commands
  ///
  /// Intput:
  ///   - String input commands -> e.g. command1()¬command2()
  /// Returns:
  ///   - List<String> calls to be performed arranged respectuflly
  List<String> _splitCalls(String input) {
    try {
      List<String> calls = [];
      int nestedLevel = 0;
      StringBuffer currentCall = StringBuffer();

      for (int i = 0; i < input.length; i++) {
        // Input encounters ( -> start nested
        if (input[i] == '(') {
          nestedLevel++;
        }
        // Input encounters ) -> close nested
        else if (input[i] == ')') {
          nestedLevel--;
        }

        /// When layer level is 0 hence no more args are passed ) closed and the command is finished given ¬
        /// Add the function name to the calls
        else if (input[i] == '¬' && nestedLevel == 0) {
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
    } catch (error) {
      print(error);
      return [];
    }
  }

  /// Parse a function -> function name and args
  ///
  /// Input:
  ///   - String function input
  ///
  /// Returns:
  ///   - Dynamic -> dispatcher or null
  Future<dynamic> _parseFunction(String input) async {
    try {
      /// Get function name, stop when in strin encounter (
      int index = 0;
      while (index < input.length && input[index] != '(') {
        index++;
      }

      if (index == input.length) {
        throw FormatException('Invalid input string');
      }

      String functionName = input.substring(0, index).trim();
      index++;

      /// Get Args
      /// Nested level between the two parethensis
      /// When it finds ) parse the argument if the nested elvel is 0
      /// Parse argument also when ¬ is encountered which stands for , meaning the second argument

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
    } catch (error) {
      print(error);
      return;
    }
  }

  /// Parse arguments
  ///
  /// Input:
  ///   - String non parsed argument
  /// Returns:
  ///   - Dynamic nothing or passed argument
  ///
  /// ^ is used to concatenate the strings (substitution to +)
  /// ( argument has a function therefore parse the function
  /// | used for a string -> e.g. |Hello World| = "Hello World"
  Future<dynamic> _parseArgument(String arg) async {
    try {
      arg = arg.trim();

      if (arg.contains('^')) {
        return await _evaluateConcatenation(arg);
      } else if (arg.contains('(')) {
        return await _parseFunction(arg);
      } else if (arg.startsWith("|") && arg.endsWith("|")) {
        return arg.substring(1, arg.length - 1);
      } else {
        return arg;
      }
    } catch (error) {
      print(error);
      return;
    }
  }

  /// Evalute Concatenation
  ///
  /// Input:
  ///   - String expression
  ///
  /// Returns:
  ///   - String concatenated string
  Future<String> _evaluateConcatenation(String expression) async {
    try {
      /// Concatenates a string, splitting by the concatenation symbol ^
      /// Iterates throught the items
      /// If the current itme contains ( it is a function therefore parse it
      /// If it is between || it is a String
      /// Append every part to a string and return it as a concatenated string
      List<String> parts = expression.split('^');
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
    } catch (error) {
      print(error);
      return '';
    }
  }

  /// Function called when js ws send command list
  ///
  /// Input:
  ///   - String input commands -> e.g [speak(|...|)¬send_email(|...|)]
  Future<void> parse(String input) async {
    parseAndExecute(input);
  }
}
