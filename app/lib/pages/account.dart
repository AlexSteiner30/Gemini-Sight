import 'package:app/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';

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
      required this.gps,
      required this.contacts,
      required this.health,
      required this.phone});

  final GoogleSignInAccount user;

  bool googleMaps;
  bool googleDrive;
  bool gmail;
  bool googleCalendar;
  bool youtube;
  bool gps;
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
            SwitchListTile(
              title: const Text('Google Maps'),
              value: widget.googleMaps,
              onChanged: (bool value) {
                setState(() {
                  widget.googleMaps = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Google Drive'),
              value: widget.googleDrive,
              onChanged: (bool value) {
                setState(() {
                  widget.googleDrive = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Gmail'),
              value: widget.gmail,
              onChanged: (bool value) {
                setState(() {
                  widget.gmail = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Google Calendar'),
              value: widget.googleCalendar,
              onChanged: (bool value) {
                setState(() {
                  widget.googleCalendar = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Youtube'),
              value: widget.youtube,
              onChanged: (bool value) {
                setState(() {
                  widget.youtube = value;
                });
              },
            ),
            SwitchListTile(
                title: const Text('GPS'),
                value: widget.gps,
                onChanged: (bool value) async {
                  const permission = Permission.location;
                  if (await permission.isDenied) {
                    await permission.request();
                  }
                  var status = await Permission.location.status;
                  setState(() {
                    if (value) {
                      if (status.isGranted) {
                        widget.gps = true;
                      } else {
                        widget.gps = false;
                      }
                    } else {
                      widget.gps = value;
                    }
                  });
                }),
            SwitchListTile(
              title: const Text('Contacts'),
              value: widget.contacts,
              onChanged: (bool value) async {
                const permission = Permission.contacts;
                if (await permission.isDenied) {
                  await permission.request();
                }
                var status = await Permission.contacts.status;
                setState(() {
                  if (value) {
                    if (status.isGranted) {
                      widget.contacts = true;
                    } else {
                      widget.contacts = false;
                    }
                  } else {
                    widget.contacts = value;
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                Navigator.pushAndRemoveUntil(
                  // ignore: use_buildwidget.context_synchronously, use_build_context_synchronously
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
