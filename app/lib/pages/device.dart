import 'package:app/pages/account.dart';
import 'package:app/pages/bottom_nav_bar.dart';
import 'package:app/pages/chat.dart';
import 'package:app/pages/device_config.dart';
import 'package:app/pages/explore.dart';
import 'package:app/pages/gallery.dart';
import 'package:app/pages/menu.dart';
import 'package:app/pages/store.dart';
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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  int _currentIndex = 4;

  Future<void> _onNavBarTap(int index) async {
    /* 
    Index 
    0 -> Explore
    1 -> Store
    2 -> Gallery
    3 -> Chats
    4 -> Device
    5 -> Menu 
    */

    setState(() {
      _currentIndex = index;
    });

    if (_currentIndex == 0) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ExploreScreen(user: widget.user),
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    } else if (_currentIndex == 1) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => StoreScreen(user: widget.user),
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    } else if (_currentIndex == 2) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => GalleryScreen(user: widget.user),
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    } else if (_currentIndex == 3) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ChatScreen(user: widget.user),
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    } else if (_currentIndex == 5) {
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

  void _showPopupMenu(BuildContext context) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(25.0, 40.0, 0.0, 0.0),
      items: [
        PopupMenuItem<int>(
          value: 0,
          child: Text("Settings"),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Text("About"),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Text("Logout"),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 0:
            // Handle Settings
            break;
          case 1:
            // Handle About
            break;
          case 2:
            // Handle Logout
            break;
        }
      }
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ignore: prefer_const_constructors
                Text(
                  'Meta Quest Pro',
                  // ignore: prefer_const_constructors
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPopupMenu(context),
                  // ignore: prefer_const_constructors
                  child: Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
            // ignore: prefer_const_constructors
            SizedBox(height: 20),
            // ignore: prefer_const_constructors
            Text(
              'Connected',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
            Text(
              'Synced 3m ago',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/meta_quest_pro.png'), // Add your image asset here
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Row(
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
                  SizedBox(height: 20),
                  Text('prettyflyforthewifi',
                      style: TextStyle(color: Colors.white)),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: () {},
                    icon: Icon(Icons.cast),
                    label: Text('Cast'),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Maximize your battery life',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.apps, color: Colors.white),
                    title: Text('App Library',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text('Install and launch apps on your device',
                        style: TextStyle(color: Colors.grey)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.white),
                    title: Text('Headset settings',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text('Get info and configure your device',
                        style: TextStyle(color: Colors.grey)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.keyboard, color: Colors.white),
                    title:
                        Text('Keyboard', style: TextStyle(color: Colors.white)),
                    subtitle: Text('Type in VR from your Phone',
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
