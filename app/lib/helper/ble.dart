import 'dart:async';
import 'dart:convert';
import 'package:app/helper/commands.dart';
import 'package:app/pages/sign_in.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

BluetoothDevice? connectedDevice;
BluetoothCharacteristic? targetCharacteristic;
bool ble = false;

Future<void> scan_devices() async {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  flutterBlue.startScan(timeout: const Duration(seconds: 10));

  flutterBlue.scanResults.listen((results) async {
    for (ScanResult result in results) {
      print(result.device.name);
      if (result.device.id.id == ble_id) {
        await connect_device(result.device);
        break;
      }
    }
  });

  await Future.delayed(const Duration(seconds: 4));
  flutterBlue.stopScan();
}

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

    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
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

void read_data(List<int> data) async {
  String dataString = ascii.decode(data);
  List<String> dataParts = dataString.split('|');

  if (dataParts.length >= 2) {
    String command = dataParts[0];
    String authKey = dataParts[1];

    if (authKey == authentication_key) {
      switch (command) {
        case 'ip':
          if (dataParts.length == 3) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('ip', dataParts[2]);
          }
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

Future<void> write_data(String data) async {
  if (targetCharacteristic != null) {
    await targetCharacteristic?.write(data.codeUnits);
  } else {
    print('Target characteristic is not set.');
  }
}
