import 'dart:async';
import 'dart:convert';
import 'package:app/helper/commands.dart';
import 'package:app/pages/sign_in.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

BluetoothDevice? connectedDevice;
BluetoothCharacteristic? targetCharacteristic;
bool ble = false;
int volume = 0;
int battery = 0;

/// Scans for nearby Bluetooth devices and attempts to connect to the device with a specific ID.
///
/// The scan lasts for 5 seconds. If the device with the matching ID is found, it initiates a connection.
Future<void> scan_devices() async {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  flutterBlue.startScan(timeout: const Duration(seconds: 5));

  // Listen for scan results.
  flutterBlue.scanResults.listen((results) async {
    for (ScanResult result in results) {
      if (result.device.id.id == ble_id) {
        await connect_device(result.device);
        break;
      }
    }
  });

  await Future.delayed(const Duration(seconds: 4));
  flutterBlue.stopScan();
}

/// Connects to a given Bluetooth device and sets up notifications for a specific characteristic.
///
/// Parameters:
///   - BluetoothDevice device: The device to connect to.
Future<void> connect_device(BluetoothDevice device) async {
  try {
    await device.connect();
    connectedDevice = device;
    ble = true;

    device.state.listen((state) async {
      if (state == BluetoothDeviceState.disconnected) {
        ble = false;
        connect_device(connectedDevice!);
      } else if (state == BluetoothDeviceState.connected) {
        ble = true;
      }
    });

    // Discover services offered by the device.
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == ble_id) {
          // Check if the characteristic UUID matches the target UUID. Unique
          targetCharacteristic = characteristic;

          await characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            read_data(value);
          });
        }
      }
    }
  } catch (error) {
    ble = false;
  }
}

/// Processes incoming data from the Bluetooth device and performs actions based on the command.
///
/// Parameters:
///   - List<int> data: The data received from the Bluetooth device.
void read_data(List<int> data) async {
  String dataString = ascii.decode(data);
  List<String> dataParts = dataString.split('|');

  if (dataParts.length >= 2) {
    String command = dataParts[0];
    String authKey = dataParts[1];

    if (authKey == authentication_key) {
      // Check if the authentication key matches.
      // Execute commands
      switch (command) {
        case 'ip':
          if (dataParts.length == 3) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('ip', dataParts[2]);
          }
          break;
        case 'volume':
          volume = int.tryParse(dataParts[2])!;
          break;
        case 'battery':
          battery = int.tryParse(dataParts[2])!;
          break;
        case 'contacts':
          if (dataParts.length == 3) await contacts(dataParts[2]);
          break;
        case 'call':
          if (dataParts.length == 3) await call(dataParts[2]);
          break;
        case 'text':
          if (dataParts.length == 4) await text(dataParts[2], dataParts[3]);
          break;
      }
    }
  }
}

/// Sends data to the connected Bluetooth device by writing it to the target characteristic.
///
/// Parameters:
///   - String data: The data to send.
Future<void> write_data(String data) async {
  if (targetCharacteristic != null) {
    await targetCharacteristic?.write(data.codeUnits);
  } else {
    print('Target characteristic is not set.');
  }
}
