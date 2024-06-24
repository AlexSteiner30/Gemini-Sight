import 'package:app/pages/device.dart';
import 'package:flutter/material.dart';

class DeviceConfigPage extends StatefulWidget {
  final Device device;

  const DeviceConfigPage({super.key, required this.device});

  @override
  _DeviceConfigPageState createState() => _DeviceConfigPageState();
}

class _DeviceConfigPageState extends State<DeviceConfigPage> {
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
