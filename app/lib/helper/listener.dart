import 'dart:async';
import 'dart:ui';
import 'package:app/helper/commands.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:web_socket_client/web_socket_client.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: false,
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on("stop").listen((event) {
    service.stopSelf();
    print("background process is now stopped");
  });

  service.on("start").listen((event) {});

  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  start_recording();

  recording_handler();
}

void recording_handler() async {
  var recording_temp = false;

  /*

  while (true) {
    if (recording) {
      // pull request from device
      // add to string

      recording_temp = true;
    }
    if (!recording && recording_temp) {
      recording_temp = false;
      // send list
      // clear list
      await socket.connection.firstWhere((state) => state is Connected);

      socket.send(
          'media¬e6c2ce4f-7736-46f6-9693-6cb104c42b10¬${last_recording[0]}');

      last_recording = [];
    }

    stop_recording(''); // to remove
  }
  */
}
