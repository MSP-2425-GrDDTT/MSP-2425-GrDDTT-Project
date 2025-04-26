// home_page.dart
import 'package:flutter/material.dart';
import '../live_tracking_page.dart';
import '../settings/settings_screen.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent back navigation
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF3EC7E4),
        appBar: AppBar(
          backgroundColor: Color(0xFF3EC7E4),
          title: const Text(
              'MyWaze',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontSize: 28,
              )
          ),
          automaticallyImplyLeading: false, // Remove the back arrow
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            )
          ],
        ),
        body: LiveTrackingPage(),
      ),
    );
  }
}
