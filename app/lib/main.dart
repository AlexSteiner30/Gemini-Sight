import 'package:flutter/material.dart';

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
          primarySwatch: Colors.grey, // Adjust primarySwatch if needed
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  void _login() async {
    try {
      // Simulate login
      await Future.delayed(Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DeviceListPage()),
      );
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
            // Your logo image here
            Image.asset(
              'assets/images/logo.png', // Adjust the path and file name as necessary
              width: 100, // Adjust the size as necessary
              height: 100,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  return states.contains(MaterialState.pressed)
                      ? Colors.grey[800]!
                      : Colors.grey[800]!;
                }),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
  const DeviceListPage({super.key});

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
      barrierDismissible: false, // user must tap button to dismiss dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete ${_devices[index].name}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
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

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
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
                    Icon(Icons.important_devices, size: 50, color: Colors.grey[300]), // smart glasses icon
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
                      onPressed: () => _confirmDelete(index), // show confirmation dialog
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
  State<DeviceConfigPage> createState() => _DeviceConfigPageState();
}

class _DeviceConfigPageState extends State<DeviceConfigPage> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _blindPeopleSupport = false; // Updated state for blind people support
  double _volume = 50;

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitConfiguration() {
    final ssid = _ssidController.text;
    final password = _passwordController.text;
    final isEnabled = _blindPeopleSupport;
    final volume = _volume;
    // Handle the configuration submission logic here
    print('Device: ${widget.device.name}, SSID: $ssid, Password: $password, Blind People Support: $isEnabled, Volume: $volume');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure ${widget.device.name}'),
      ),
      body: Container(
        color: Colors.grey[800],
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'ID: ${widget.device.id}',
              style: TextStyle(fontSize: 16, color: Colors.grey[300]),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Model: ${widget.device.model}',
              style: TextStyle(fontSize: 16, color: Colors.grey[300]),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'Network SSID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('Blind People Support'), // Updated title
              value: _blindPeopleSupport, // Updated value
              onChanged: (bool value) {
                setState(() {
                  _blindPeopleSupport = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title: const Text('Volume'),
              subtitle: Slider(
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
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitConfiguration,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
