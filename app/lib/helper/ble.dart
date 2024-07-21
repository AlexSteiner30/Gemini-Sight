import 'package:flutter_blue/flutter_blue.dart';

bool check_connection() {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  flutterBlue.startScan(timeout: const Duration(seconds: 4));

  flutterBlue.scanResults.listen((results) {
    for (ScanResult r in results) {
      r.device.id.id;
    }
  });

  flutterBlue.stopScan();

  return false;
}

Future<void> connectToDevice(String deviceId) async {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  try {
    // Scan for devices
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    BluetoothDevice? targetDevice;

    flutterBlue.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.id.id == deviceId) {
          targetDevice = r.device;
          await flutterBlue.stopScan();
          await targetDevice!.connect();

          // Check if the device is connected
          BluetoothDeviceState deviceState = await targetDevice!.state.first;
          if (deviceState == BluetoothDeviceState.connected) {
            print('true');
          } else {
            print('false');
          }
        }
      }
    });

    await flutterBlue.stopScan();
  } catch (e) {
    // Handle any errors that occur during the connection
    print("Error connecting to device: $e");
    print('false');
  }

  print('true');
}
