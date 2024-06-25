import 'package:web_socket_client/web_socket_client.dart';

final socket = WebSocket(
  Uri.parse('ws://192.168.88.9:9000'),
);

// ignore: non_constant_identifier_names
void send_data(String data) async {
  await socket.connection.firstWhere((state) => state is Connected);

  socket.send('e6c2ce4f-7736-46f6-9693-6cb104c42b10,$data');

  socket.messages.listen((commands_list) {
    // play pcm over ble
    // ignore: avoid_print
    print(commands_list);
  });
}

void speak(data) async {
  await socket.connection.firstWhere((state) => state is Connected);

  socket.send(
      // ignore: prefer_interpolation_to_compose_strings
      'speak,' + data);

  socket.messages.listen((pcm) {
    // play pcm over ble
    // ignore: avoid_print
    print(pcm);
  });
}

// ignore: non_constant_identifier_names
void start_recording() {
  // ignore: avoid_print
  print('Started Recording');
}

// ignore: non_constant_identifier_names
void stop_recording() {
  // ignore: avoid_print
  print('Stop Recording');
}

// ignore: non_constant_identifier_names
void start_route(route) {
  // search route then speak
  // ignore: avoid_print
  print('Started Route');
}

// ignore: non_constant_identifier_names
void stop_route(route) {
  // search route then speak
  // ignore: avoid_print
  print('Stopped Route');
}

// ignore: non_constant_identifier_names
void get_document(document) {
  // ignore: avoid_print
  print(document);
}

// ignore: non_constant_identifier_names
void write_document(document, data) {
  // ignore: avoid_print
  print(document);
  // ignore: avoid_print
  print(data);
}

// ignore: non_constant_identifier_names
void get_sheet(sheet) {
  // ignore: avoid_print
  print(sheet);
}

// ignore: non_constant_identifier_names
void write_sheet(sheet, data) {
  // ignore: avoid_print
  print(sheet);
  // ignore: avoid_print
  print(data);
}

// ignore: non_constant_identifier_names
void change_volume(volume) {
  // ignore: avoid_print
  print(volume);
}

// ignore: non_constant_identifier_names
void drive_get_file(file) {
  // ignore: avoid_print
  print(file);
}

// ignore: non_constant_identifier_names
void drive_push_file(file, data) {
  // ignore: avoid_print
  print(file);
  // ignore: avoid_print
  print(data);
}

void wait(int seconds) {
  //sleep(const Duration(seconds: 1)); // fix seconds
}

// ignore: non_constant_identifier_names
void record_speed() {
  // record speed
  // ignore: avoid_print
  print('Recording Speed');
}

// ignore: non_constant_identifier_names
void stop_speed() {
  // ignore: avoid_print
  print('Stop Recording Speed');
}

// ignore: non_constant_identifier_names
void play_song(String song) {
  // ignore: avoid_print
  print('Playing song: $song');
}

void main() {
  send_data(
      'Hey Gemma i m going to go on a bike trip till los angeles start recording my speed, write when done the average speed and time taken in a spread sheet named bike_trip');
}
