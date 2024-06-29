import 'package:app/pages/device.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/pages/sign_in.dart';

class DeviceSettings extends StatefulWidget {
  // ignore: use_super_parameters
  const DeviceSettings({
    Key? key,
    required this.user,
    required this.device,
    required this.googleMaps,
    required this.googleDrive,
    required this.gmail,
    required this.googleCalendar,
    required this.youtube,
    required this.location,
    required this.contacts,
    required this.health,
    required this.phone,
  }) : super(key: key);

  final GoogleSignInAccount user;
  final Device device;
  final bool googleMaps;
  final bool googleDrive;
  final bool gmail;
  final bool googleCalendar;
  final bool youtube;
  final bool location;
  final bool contacts;
  final bool health;
  final bool phone;

  @override
  // ignore: library_private_types_in_public_api
  _DeviceSettingsState createState() => _DeviceSettingsState();
}

class _DeviceSettingsState extends State<DeviceSettings> {
  late bool _googleMaps;
  late bool _googleDrive;
  late bool _gmail;
  late bool _googleCalendar;
  late bool _youtube;
  late bool _location;
  late bool _contacts;
  late bool _health;
  late bool _phone;

  @override
  void initState() {
    super.initState();
    _googleMaps = widget.googleMaps;
    _googleDrive = widget.googleDrive;
    _gmail = widget.gmail;
    _googleCalendar = widget.googleCalendar;
    _youtube = widget.youtube;
    _location = widget.location;
    _contacts = widget.contacts;
    _health = widget.health;
    _phone = widget.phone;
  }

  Future<void> _setPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _handlePermission(
      Permission permission, bool value, String key) async {
    if (value && await permission.isDenied) {
      await permission.request();
    }
    final status = await permission.status;
    if (value && !status.isGranted) {
      value = false;
    }
    await _setPreference(key, value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glasses Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(widget.user.photoUrl ?? ''),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Email'),
              subtitle: Text(widget.user.email),
            ),
            const Divider(height: 32),
            const Text(
              'Access Manager',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Google Maps'),
              value: _googleMaps,
              onChanged: (value) async {
                _googleMaps = value;
                await _setPreference('googleMaps', value);
              },
            ),
            SwitchListTile(
              title: const Text('Google Drive'),
              value: _googleDrive,
              onChanged: (value) async {
                _googleDrive = value;
                await _setPreference('googleDrive', value);
              },
            ),
            SwitchListTile(
              title: const Text('Gmail'),
              value: _gmail,
              onChanged: (value) async {
                _gmail = value;
                await _setPreference('gmail', value);
              },
            ),
            SwitchListTile(
              title: const Text('Google Calendar'),
              value: _googleCalendar,
              onChanged: (value) async {
                _googleCalendar = value;
                await _setPreference('googleCalendar', value);
              },
            ),
            SwitchListTile(
              title: const Text('YouTube'),
              value: _youtube,
              onChanged: (value) async {
                _youtube = value;
                await _setPreference('youtube', value);
              },
            ),
            SwitchListTile(
              title: const Text('Location'),
              value: _location,
              onChanged: (value) async {
                _location = value;
                await _handlePermission(Permission.location, value, 'location');
              },
            ),
            SwitchListTile(
              title: const Text('Contacts'),
              value: _contacts,
              onChanged: (value) async {
                _contacts = value;
                await _handlePermission(Permission.contacts, value, 'contacts');
              },
            ),
            SwitchListTile(
              title: const Text('Health'),
              value: _health,
              onChanged: (value) async {
                _health = value;
                await _handlePermission(
                    Permission.activityRecognition, value, 'health');
              },
            ),
            SwitchListTile(
              title: const Text('Phone'),
              value: _phone,
              onChanged: (value) async {
                _phone = value;
                await _setPreference('phone', value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('logged', false);
                Navigator.pushAndRemoveUntil(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                  (route) => false,
                );
              },
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            // ignore: prefer_const_constructors
            ListTile(
              title: Text(
                'Model: ${widget.device.model}',
                // ignore: prefer_const_constructors
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            const Text(
              '© 2024 Gemini Sight',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
