import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/pages/sign_in.dart';
import 'package:app/pages/device.dart'; // Adjust import as per your project structure

class DeviceSettings extends StatefulWidget {
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
  final bool phone;

  @override
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
    setState(() {
      switch (key) {
        case 'googleMaps':
          _googleMaps = value;
          break;
        case 'googleDrive':
          _googleDrive = value;
          break;
        case 'gmail':
          _gmail = value;
          break;
        case 'googleCalendar':
          _googleCalendar = value;
          break;
        case 'youtube':
          _youtube = value;
          break;
        case 'location':
          _location = value;
          break;
        case 'contacts':
          _contacts = value;
          break;
        case 'phone':
          _phone = value;
          break;
      }
    });
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
              onChanged: (value) => _handlePermission(
                Permission.location,
                value,
                'googleMaps',
              ),
            ),
            SwitchListTile(
              title: const Text('Google Drive'),
              value: _googleDrive,
              onChanged: (value) => _handlePermission(
                Permission.storage,
                value,
                'googleDrive',
              ),
            ),
            SwitchListTile(
              title: const Text('Gmail'),
              value: _gmail,
              onChanged: (value) => _handlePermission(
                Permission.audio,
                value,
                'gmail',
              ),
            ),
            SwitchListTile(
              title: const Text('Google Calendar'),
              value: _googleCalendar,
              onChanged: (value) => _handlePermission(
                Permission.calendar,
                value,
                'googleCalendar',
              ),
            ),
            SwitchListTile(
              title: const Text('YouTube'),
              value: _youtube,
              onChanged: (value) => _setPreference('youtube', value),
            ),
            SwitchListTile(
              title: const Text('Location'),
              value: _location,
              onChanged: (value) => _handlePermission(
                Permission.location,
                value,
                'location',
              ),
            ),
            SwitchListTile(
              title: const Text('Contacts'),
              value: _contacts,
              onChanged: (value) => _handlePermission(
                Permission.contacts,
                value,
                'contacts',
              ),
            ),
            SwitchListTile(
              title: const Text('Phone'),
              value: _phone,
              onChanged: (value) => _setPreference('phone', value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('logged', false);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                  (route) => false,
                );
              },
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            ListTile(
              title: Text(
                'Model: ${widget.device.model}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const Text(
              '© 2024 Gemini Sight',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
