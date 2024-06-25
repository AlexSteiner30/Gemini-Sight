import 'package:app/pages/account.dart';
import 'package:app/pages/bottom_nav_bar.dart';
import 'package:app/pages/chat.dart';
import 'package:app/pages/device.dart';
import 'package:app/pages/gallery.dart';
import 'package:app/pages/explore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final GoogleSignInAccount user;

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
  }

  int _currentIndex = 0;

  Future<void> _onNavBarTap(int index) async {
    /* 
    Index 
    0 -> Explore
    1 -> Store
    2 -> Gallery
    3 -> Chats
    4 -> Device
    5 -> Menu 
    */

    setState(() {
      _currentIndex = index;
    });

    if (_currentIndex == 0) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => ExploreScreen(
                  user: widget.user,
                )),
      );
    } else if (_currentIndex == 2) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => GalleryScreen(
                  user: widget.user,
                )),
      );
    } else if (_currentIndex == 4) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => DeviceListPage(user: widget.user)),
      );
    } else if (_currentIndex == 5) {
      final prefs = await SharedPreferences.getInstance();

      // ignore: no_leading_underscores_for_local_identifiers
      bool _googleMaps = prefs.getBool('googleMaps') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _googleDrive = prefs.getBool('googleDrive') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _gmail = prefs.getBool('gmail') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _googleCalendar = prefs.getBool('googleCalendar') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _youtube = prefs.getBool('youtube') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _location = prefs.getBool('location') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _contacts = prefs.getBool('contacts') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _health = prefs.getBool('health') ?? false;
      // ignore: no_leading_underscores_for_local_identifiers
      bool _phone = prefs.getBool('phone') ?? false;

      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => AccountPage(
              user: widget.user,
              googleMaps: _googleMaps,
              googleDrive: _googleDrive,
              gmail: _gmail,
              googleCalendar: _googleCalendar,
              youtube: _youtube,
              location: _location,
              contacts: _contacts,
              health: _health,
              phone: _phone),
        ),
      );
    }
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
