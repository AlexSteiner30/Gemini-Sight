import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/pages/sign_in.dart';
import 'package:app/pages/device.dart';

class DeviceSettings extends StatefulWidget {
  const DeviceSettings({
    Key? key,
    required this.user,
    required this.device,
  }) : super(key: key);

  final GoogleSignInAccount user;
  final Device device;

  @override
  _DeviceSettingsState createState() => _DeviceSettingsState();
}

class _DeviceSettingsState extends State<DeviceSettings> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glasses Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      _buildUserInfo(),
                      const SizedBox(height: 64),
                      _buildWifiConnection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildDeviceInfo(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundImage: NetworkImage(widget.user.photoUrl ?? ''),
        ),
        const SizedBox(height: 16),
        Text(
          widget.user.displayName ?? 'No name available',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.user.email,
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWifiConnection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Connect Device to WiFi',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: ssidController,
          decoration: const InputDecoration(
            labelText: 'SSID',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wifi),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _connectToWifi,
          icon: const Icon(Icons.connect_without_contact),
          label: const Text('Connect'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.devices, size: 20),
              const SizedBox(width: 8),
              Text('Model: ${widget.device.model}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 Gemini Sight',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await GoogleSignIn().signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged', false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
      (route) => false,
    );
  }

  void _connectToWifi() {
    // Handle connect action
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connecting to WiFi...')),
    );
  }
}
