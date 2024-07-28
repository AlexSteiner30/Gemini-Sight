import 'package:app/helper/commands.dart';
import 'package:app/pages/sign_in.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'dart:convert';

BluetoothConnection? connection;
bool connected = false;

Future<void> connect_device(String address) async {
  await BluetoothConnection.toAddress(address).then((_connection) {
    print('Connected to the device');
    connection = _connection;

    connection?.input?.listen(read_data).onDone(() {});
    connected = true;
  }).catchError((error) {
    print('Cannot connect, exception occured');
    connected = false;
  });
}

void read_data(Uint8List inc_data) async {
  String data = ascii.decode(inc_data);
  List<String> data_parts = data.split('¬');

  if (data_parts.length >= 2) {
    String command = data_parts[0];
    String auth_key = data_parts[1];

    if (auth_key == authentication_key) {
      switch (command) {
        case 'contacts':
          if (data_parts.length == 3) await contacts(data_parts[2]);
          break;
        case 'call':
          if (data_parts.length == 3) await call(data_parts[2]);
          break;
        case 'text':
          if (data_parts.length == 4) await text(data_parts[2], data_parts[3]);
          break;
      }
    }
  }
}

void write_data(Uint8List data) {
  connection!.output.add(data);
}
