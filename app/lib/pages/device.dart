import 'dart:async';
import 'package:app/helper/ble.dart';
import 'package:app/helper/loading_screen.dart';
import 'package:app/helper/query.dart';
import 'package:app/helper/wifi.dart';
import 'package:app/pages/settings.dart';
import 'package:app/pages/bottom_nav_bar.dart';
import 'package:app/pages/sign_in.dart';
import 'package:app/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Device device = Device(auth: authentication_key, model: '0.1', status: "false");
int connected_time = -1;

class Device {
  String auth;
  String model;
  String status;

  Device({required this.auth, required this.model, this.status = "false"});
}

// ignore: must_be_immutable
class DevicePage extends StatefulWidget {
  DevicePage({super.key, required this.user, required this.blind_support});

  final GoogleSignInAccount user;
  bool blind_support;

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  bool isLoading = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    update_time();
    check_connection();

    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      update_time();
    });

    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      check_connection();
    });
  }

  void update_time() {
    setState(() {
      connected_time++;
    });
  }

  void check_connection() {
    setState(() {
      connected = connected;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void settings() {
    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            DeviceSettings(user: widget.user, device: device),
        transitionDuration: const Duration(seconds: 0),
      ),
    );
  }

  Future<drive.File?> folderExistsInDrive(
      drive.DriveApi driveApi, String folderName) async {
    var response = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false and 'root' in parents",
    );
    return response.files?.isNotEmpty == true ? response.files!.first : null;
  }

  Future<drive.File> createFolderInDrive(
      drive.DriveApi driveApi, String folderName) async {
    var folder = drive.File()
      ..name = folderName
      ..mimeType = "application/vnd.google-apps.folder";

    return await driveApi.files.create(folder);
  }

  Future<void> _onNavBarTap(int index) async {
    setState(() {
      _currentIndex = index;
    });

    if (_currentIndex == 1) {
      _currentIndex = 0;
      final httpClient = GoogleAPIClient(await account!.authHeaders);
      final driveApi = drive.DriveApi(httpClient);
      var folder = await folderExistsInDrive(driveApi, 'Gemini Sight Media');
      var folderId = folder?.id ??
          (await createFolderInDrive(driveApi, 'Gemini Sight Media')).id;
      String folder_url =
          "https://drive.google.com/drive/u/2/folders/$folderId";
      // ignore: deprecated_member_use
      if (await canLaunch(folder_url)) {
        // ignore: deprecated_member_use
        await launch(folder_url);
      } else {
        throw 'Could not launch $folder_url';
      }
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
                  if (connected)
                    // ignore: prefer_const_constructors
                    Text(
                      'Connected',
                      // ignore: prefer_const_constructors
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  if (connected)
                    // ignore: prefer_const_constructors
                    Text(
                      'Synced ${connected_time >= 60 ? connected_time >= 60 * 60 ? "${connected_time ~/ 60 * 60}d" : "${connected_time ~/ 60}h" : "${connected_time}m"} ago',
                      // ignore: prefer_const_constructors
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  if (!connected)
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
                        if (connected)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Column(
                                children: [
                                  Icon(Icons.battery_charging_full,
                                      color: Colors.white),
                                  SizedBox(height: 5),
                                  Text('90%',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              const SizedBox(width: 40),
                              const Column(
                                children: [
                                  Icon(Icons.volume_up, color: Colors.white),
                                  SizedBox(height: 5),
                                  Text('50%',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              const SizedBox(width: 40),
                              Column(
                                children: [
                                  wifi
                                      ? const Icon(Icons.wifi,
                                          color: Colors.white)
                                      : const Icon(Icons.wifi_off,
                                          color: Colors.red),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              const SizedBox(width: 40),
                              const Column(
                                children: [
                                  Icon(Icons.bluetooth, color: Colors.white),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ],
                          ),
                        if (!connected)
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
                        if (connected)
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
                        if (!connected)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            onPressed: settings,
                            icon: const Icon(Icons.wifi),
                            label: const Text('Connect'),
                          ),
                        const SizedBox(height: 10),
                        if (connected)
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Gemini Sight Glasses successfully connected',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        if (!connected)
                          const Text(
                            'Connect via Bluetooth for WiFi credentials',
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
                              style: const TextStyle(color: Colors.grey)),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            widget.blind_support =
                                prefs.getBool('blind_support') ?? false;

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
                          onTap: () {
                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => DeviceSettings(
                                  user: widget.user,
                                  device: device,
                                ),
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
