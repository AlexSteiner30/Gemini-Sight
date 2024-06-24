import 'package:app/pages/account.dart';
import 'package:app/pages/device_config.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Device {
  String id;
  String name;
  String model;
  bool isOnline;

  Device(
      {required this.id,
      required this.name,
      required this.model,
      this.isOnline = false});
}

class DeviceListPage extends StatefulWidget {
  final GoogleSignInAccount user;

  const DeviceListPage({super.key, required this.user});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  final List<Device> _devices = [];
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      _addDevice(scanData.code);
      controller.dispose();
      Navigator.pop(context); // Close the scanner
    });
  }

  Future<void> _scanQRCode() async {
    const permission = Permission.camera;
    if (await permission.isDenied) {
      await permission.request();
    }
    var status = await Permission.camera.status;
    if (status.isGranted) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Scan QR Code'),
            ),
            body: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ),
      );
    } else {
      return showDialog<void>(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Camera Access Not Granted'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'In order to connect a new device is it necessary to grant cammera access to the Gemini Sight Application'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _addDevice(String qrData) {
    // Parse the QR code data to extract device details
    // For this example, assume the qrData is formatted as "id,name,model"
    final parts = qrData.split(',');
    if (parts.length == 3) {
      setState(() {
        _devices.add(Device(
          id: parts[0],
          name: parts[1],
          model: parts[2],
        ));
      });
    }
  }

  void _confirmDelete(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to delete ${_devices[index].name}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteDevice(index);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteDevice(int index) {
    setState(() {
      _devices.removeAt(index);
    });
  }

  Future<void> _showAccountPage() async {
    // ignore: no_leading_underscores_for_local_identifiers
    bool _googleMaps = false;
    // ignore: no_leading_underscores_for_local_identifiers
    bool _googleDrive = false;
    // ignore: no_leading_underscores_for_local_identifiers
    bool _gmail = false;
    // ignore: no_leading_underscores_for_local_identifiers
    bool _googleCalendar = false;
    // ignore: no_leading_underscores_for_local_identifiers
    bool _youtube = false;
    // ignore: no_leading_underscores_for_local_identifiers
    bool _location = false;
    // ignore: no_leading_underscores_for_local_identifiers
    bool _contacts = false;
    // ignore: no_leading_underscores_for_local_identifiers
    bool _health = false;
    // ignore: no_leading_underscores_for_local_identifiers
    bool _phone = false;

    // ignore: non_constant_identifier_names
    Future<void> load_var() async {
      final prefs = await SharedPreferences.getInstance();

      _googleMaps = prefs.getBool('googleMaps') ?? false;
      _googleDrive = prefs.getBool('googleDrive') ?? false;
      _gmail = prefs.getBool('gmail') ?? false;
      _googleCalendar = prefs.getBool('googleCalendar') ?? false;
      _youtube = prefs.getBool('youtube') ?? false;
      _location = prefs.getBool('location') ?? false;
      _contacts = prefs.getBool('contacts') ?? false;
      _health = prefs.getBool('health') ?? false;
      _phone = prefs.getBool('phone') ?? false;
    }

    await load_var();

    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => AccountPage(
            user: widget.user,
            googleMaps: _googleMaps,
            googleDrive: _googleDrive,
            gmail: _gmail,
            googleCalendar: _googleCalendar,
            youtube: _youtube,
            location: _location,
            contacts: _contacts,
            health: _health,
            phone: _phone),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _showAccountPage,
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[800],
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DeviceConfigPage(device: _devices[index]),
                  ),
                );
              },
              child: Card(
                color: Colors.grey[700],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.important_devices,
                        size: 50, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      _devices[index].name,
                      style: TextStyle(fontSize: 18, color: Colors.grey[100]),
                    ),
                    Text(
                      'ID: ${_devices[index].id}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                    ),
                    Text(
                      'Model: ${_devices[index].model}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[300]),
                      onPressed: () => _confirmDelete(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanQRCode,
        tooltip: 'Scan QR Code',
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
