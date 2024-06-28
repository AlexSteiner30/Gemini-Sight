import 'package:app/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class AccountPage extends StatefulWidget {
  AccountPage(
      {super.key,
      required this.user,
      required this.googleMaps,
      required this.googleDrive,
      required this.gmail,
      required this.googleCalendar,
      required this.youtube,
      required this.location,
      required this.contacts,
      required this.health,
      required this.phone});

  final GoogleSignInAccount user;

  bool googleMaps;
  bool googleDrive;
  bool gmail;
  bool googleCalendar;
  bool youtube;
  bool location;
  bool contacts;
  bool health;
  bool phone;

  @override
  // ignore: library_private_types_in_public_api, no_logic_inwidget.create_state
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
              backgroundImage: NetworkImage(widget.user.photoUrl ?? ''),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Email'),
              subtitle: Text(widget.user.email),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            const Text('Access Manager',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: ListView(
                children: [
                  SwitchListTile(
                    title: const Text('Google Maps'),
                    value: widget.googleMaps,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('googleMaps', value);
                      setState(() {
                        widget.googleMaps = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Google Drive'),
                    value: widget.googleDrive,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('googleDrive', value);
                      setState(() {
                        widget.googleDrive = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Gmail'),
                    value: widget.gmail,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('gmail', value);
                      setState(() {
                        widget.gmail = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Google Calendar'),
                    value: widget.googleCalendar,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('googleCalendar', value);
                      setState(() {
                        widget.googleCalendar = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Youtube'),
                    value: widget.youtube,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('youtube', value);
                      setState(() {
                        widget.youtube = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Location'),
                    value: widget.location,
                    onChanged: (bool value) async {
                      const permission = Permission.location;
                      if (await permission.isDenied) {
                        await permission.request();
                      }

                      var state = false;
                      var status = await Permission.location.status;
                      final prefs = await SharedPreferences.getInstance();

                      if (value) {
                        if (status.isGranted) {
                          state = true;
                          prefs.setBool('location', state);
                        } else {
                          state = false;
                          prefs.setBool('location', state);
                        }
                      } else {
                        state = value;
                        prefs.setBool('location', state);
                      }

                      setState(() {
                        widget.location = state;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Contacts'),
                    value: widget.contacts,
                    onChanged: (bool value) async {
                      const permission = Permission.contacts;
                      if (await permission.isDenied) {
                        await permission.request();
                      }

                      var state = false;
                      var status = await Permission.contacts.status;
                      final prefs = await SharedPreferences.getInstance();

                      if (value) {
                        if (status.isGranted) {
                          state = true;
                          prefs.setBool('contacts', state);
                        } else {
                          state = false;
                          prefs.setBool('contacts', state);
                        }
                      } else {
                        state = value;
                        prefs.setBool('contacts', state);
                      }

                      setState(() {
                        widget.health = state;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Health'),
                    value: widget.health,
                    onChanged: (bool value) async {
                      const permission = Permission.activityRecognition;
                      if (await permission.isDenied) {
                        await permission.request();
                      }

                      var state = false;
                      var status = await Permission.activityRecognition.status;
                      final prefs = await SharedPreferences.getInstance();

                      if (value) {
                        if (status.isGranted) {
                          state = true;
                          prefs.setBool('health', state);
                        } else {
                          state = false;
                          prefs.setBool('health', state);
                        }
                      } else {
                        state = value;
                        prefs.setBool('health', state);
                      }

                      setState(() {
                        widget.health = state;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Phone'),
                    value: widget.phone,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('phone', value);
                      setState(() {
                        widget.phone = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                authentication_key = '';
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
          ],
        ),
      ),
    );
  }
}
