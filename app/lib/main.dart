import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Sight',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '910242255946-3okgle3e78inrabcm39807h21cumhvkj.apps.googleusercontent.com', // Replace with your actual client ID
  );

  Future<void> _login() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DeviceListPage(user: account)),
        );
      }
    } catch (error) {
      print('Login failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _login,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return states.contains(MaterialState.pressed)
                        ? Colors.grey[800]!
                        : Colors.grey[800]!;
                  },
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.account_circle, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Login with Google',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Device {
  String id;
  String name;
  String model;
  bool isOnline;

  Device({required this.id, required this.name, required this.model, this.isOnline = false});
}

class DeviceListPage extends StatefulWidget {
  final GoogleSignInAccount user;

  const DeviceListPage({super.key, required this.user});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  final List<Device> _devices = [];

  void _addDevice() {
    setState(() {
      _devices.add(Device(
        id: 'ID${_devices.length + 1}',
        name: 'Device ${_devices.length + 1}',
        model: 'Model ${_devices.length + 1}',
      ));
    });
  }

  Future<void> _confirmDelete(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete ${_devices[index].name}?'),
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

  void _showAccountPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountPage(
          user: widget.user,
        ),
      ),
    );
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
                    builder: (context) => DeviceConfigPage(device: _devices[index]),
                  ),
                );
              },
              child: Card(
                color: Colors.grey[700],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.important_devices, size: 50, color: Colors.grey[300]),
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
        onPressed: _addDevice,
        tooltip: 'Add Device',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DeviceConfigPage extends StatefulWidget {
  final Device device;

  const DeviceConfigPage({super.key, required this.device});

  @override
  _DeviceConfigPageState createState() => _DeviceConfigPageState();
}

class _DeviceConfigPageState extends State<DeviceConfigPage> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _blindPeopleSupport = false;
  double _volume = 50.0;

  void _submitConfiguration() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure ${widget.device.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'SSID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Support for blind people'),
              value: _blindPeopleSupport,
              onChanged: (bool value) {
                setState(() {
                  _blindPeopleSupport = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Volume'),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: _volume.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _volume = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _submitConfiguration,
                child: const Text('Save Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  final GoogleSignInAccount user;

  const AccountPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.photoUrl ?? ''),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Email'),
              subtitle: Text(user.email),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            const Text('Manage Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Google Maps'),
              value: true,
              onChanged: (bool value) {},
            ),
            SwitchListTile(
              title: const Text('Google Drive'),
              value: true,
              onChanged: (bool value) {},
            ),
            SwitchListTile(
              title: const Text('Gmail'),
              value: true,
              onChanged: (bool value) {},
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                  (route) => false,
                );
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
