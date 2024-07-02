import 'dart:io';

import 'package:app/helper/loading_screen.dart';
import 'package:app/helper/query.dart';
import 'package:app/pages/settings.dart';
import 'package:app/pages/bottom_nav_bar.dart';
import 'package:app/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/helper/commands.dart';
import 'package:url_launcher/url_launcher.dart';

Device device = Device(auth: authentication_key, model: '0.1', status: "false");

class Device {
  String auth;
  String model;
  String status;

  Device({required this.auth, required this.model, this.status = "false"});
}

// ignore: must_be_immutable
class DevicePage extends StatefulWidget {
  DevicePage(
      {super.key,
      required this.user,
      required this.connected,
      required this.blind_support});

  final GoogleSignInAccount user;
  bool connected;
  bool blind_support;

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final List<Device> _devices = [];
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isLoading = false;
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
          auth: parts[0],
          model: parts[1],
          status: parts[2],
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
                    'Are you sure you want to delete ${_devices[index].auth}?'),
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
    super.initState();
    send_data(
        'Hey Gemma, from my astrophysics essay remove the paragraph about black holes and add more information about Einsteins theoreom');
    Geolocator.getPositionStream().listen((position) {
      if (recording_speed) {
        temp_speed +=
            'Current Speed ${position.speed.toString()} metres per seconds ';
      }
    });
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
    2 -> - QR Code
    */

    setState(() {
      _currentIndex = index;
    });

    if (_currentIndex == 1) {
      final prefs = await SharedPreferences.getInstance();
      String folder_url =
          "https://drive.google.com/drive/u/2/folders/${prefs.getString('folder_id')}";
      if (await canLaunch(folder_url)) {
        _currentIndex = 0;
        await launch(folder_url);
      } else {
        throw 'Could not launch $folder_url';
      }
    } else if (_currentIndex == 2) {
      _scanQRCode();
      _currentIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? LoadingScreen()
            : Column(
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
                      backgroundImage: AssetImage('assets/images/glasses.jpeg'),
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
                                  Text('90%',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              SizedBox(width: 40),
                              Column(
                                children: [
                                  Icon(Icons.volume_up, color: Colors.white),
                                  SizedBox(height: 5),
                                  Text('50%',
                                      style: TextStyle(color: Colors.white)),
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
                          leading: const Icon(Icons.blind, color: Colors.white),
                          title: const Text('Blind Support',
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text(
                              widget.blind_support
                                  ? 'Blind support is currently enabled'
                                  : 'Blind support is currently disabled',
                              style: TextStyle(color: Colors.grey)),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            widget.blind_support =
                                prefs.getBool('blind_support')!;

                            await prefs.setBool(
                                'blind_support', !widget.blind_support);
                            setState(() {
                              widget.blind_support = !widget.blind_support;
                            });
                          },
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.settings, color: Colors.white),
                          title: const Text('Glasses settings',
                              style: TextStyle(color: Colors.white)),
                          subtitle: const Text(
                              'Get info and configure your device',
                              style: TextStyle(color: Colors.grey)),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();

                            // ignore: no_leading_underscores_for_local_identifiers
                            bool _googleMaps =
                                prefs.getBool('googleMaps') ?? false;
                            // ignore: no_leading_underscores_for_local_identifiers
                            bool _googleDrive =
                                prefs.getBool('googleDrive') ?? false;
                            // ignore: no_leading_underscores_for_local_identifiers
                            bool _gmail = prefs.getBool('gmail') ?? false;
                            // ignore: no_leading_underscores_for_local_identifiers
                            bool _googleCalendar =
                                prefs.getBool('googleCalendar') ?? false;
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
                                pageBuilder: (_, __, ___) => DeviceSettings(
                                    user: widget.user,
                                    device: device,
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
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.book, color: Colors.white),
                          title: const Text('Query',
                              style: TextStyle(color: Colors.white)),
                          subtitle: const Text(
                              'Understanding you through your data',
                              style: TextStyle(color: Colors.grey)),
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await get_query(widget.user, context);
                            setState(() {
                              isLoading = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: isLoading
          ? null
          : BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onNavBarTap,
            ),
    );
  }
}
