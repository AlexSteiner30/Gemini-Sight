import 'package:app/pages/account.dart';
import 'package:app/pages/bottom_nav_bar.dart';
import 'package:app/pages/gallery.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/helper/commands.dart';

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

// ignore: must_be_immutable
class DevicePage extends StatefulWidget {
  DevicePage({super.key, required this.user, required this.connected});

  final GoogleSignInAccount user;
  bool connected;

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final List<Device> _devices = [];
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // ignore: non_constant_identifier_names

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
            body: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      showDialog<void>(
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
                    'In order to connect a new device, camera access is necessary.',
                  ),
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
    print(parts);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    send_data('Hey Gemma solve this math problem which is right infront of me');
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  int _currentIndex = 0;

  Future<void> _onNavBarTap(int index) async {
    /* 
    Index 
    0 -> Device
    1 -> Gallery
    2 -> Menu
    */

    setState(() {
      _currentIndex = index;
    });

    if (_currentIndex == 1) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => GalleryScreen(user: widget.user),
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    } else if (_currentIndex == 2) {
      final prefs = await SharedPreferences.getInstance();

      // ignore: no_leading_underscores_for_local_identifiers
      bool _googleMaps = prefs.getBool('googleMaps') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _googleDrive = prefs.getBool('googleDrive') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _gmail = prefs.getBool('gmail') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _googleCalendar = prefs.getBool('googleCalendar') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _youtube = prefs.getBool('youtube') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _location = prefs.getBool('location') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _contacts = prefs.getBool('contacts') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _health = prefs.getBool('health') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _phone = prefs.getBool('phone') ?? false;

      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AccountPage(
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
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ignore: prefer_const_constructors
                Text(
                  'Gemini Sight Glasses',
                  // ignore: prefer_const_constructors
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // ignore: prefer_const_constructors
            SizedBox(height: 20),
            // ignore: prefer_const_constructors
            if (widget.connected)
              // ignore: prefer_const_constructors
              Text(
                'Connected',
                // ignore: prefer_const_constructors
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            if (widget.connected)
              // ignore: prefer_const_constructors
              Text(
                'Synced 3m ago',
                // ignore: prefer_const_constructors
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            if (!widget.connected)
              // ignore: prefer_const_constructors
              Text(
                'Not Connected',
                // ignore: prefer_const_constructors
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            const SizedBox(height: 20),
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/meta_quest_pro.png'), // Add your image asset here
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  if (widget.connected)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.battery_charging_full,
                                color: Colors.white),
                            SizedBox(height: 5),
                            Text('90%', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        SizedBox(width: 40),
                        Column(
                          children: [
                            Icon(Icons.volume_up, color: Colors.white),
                            SizedBox(height: 5),
                            Text('50%', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  if (!widget.connected)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.battery_0_bar, color: Colors.red),
                            SizedBox(height: 5),
                          ],
                        ),
                        SizedBox(width: 40),
                        Column(
                          children: [
                            Icon(Icons.volume_mute, color: Colors.red),
                            SizedBox(height: 5),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Text(widget.user.email,
                      // ignore: prefer_const_constructors
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),
                  if (widget.connected)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.cast),
                      label: const Text('Cast'),
                    ),
                  if (!widget.connected)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: _scanQRCode,
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Connect'),
                    ),
                  const SizedBox(height: 10),
                  if (widget.connected)
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Maximize your battery life',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  if (!widget.connected)
                    const Text(
                      'Scan the QR code to connect your device',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.apps, color: Colors.white),
                    title: const Text('App Library',
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text(
                        'Install and launch apps on your device',
                        style: TextStyle(color: Colors.grey)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text('Headset settings',
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Get info and configure your device',
                        style: TextStyle(color: Colors.grey)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.keyboard, color: Colors.white),
                    title: const Text('Keyboard',
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Type in VR from your Phone',
                        style: TextStyle(color: Colors.grey)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
