import 'package:app/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
            const Text('Manage Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
