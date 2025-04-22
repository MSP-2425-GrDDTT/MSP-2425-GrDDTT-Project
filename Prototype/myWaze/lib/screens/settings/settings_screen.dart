import 'package:flutter/material.dart';
import 'vehicle_registration.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Register Vehicle Type'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VehicleRegistrationScreen(),
                ),
              );
            },
          ),
          //ADD OTHER SETTINGS HERE NAO ESQUECER
        ],
      ),
    );
  }
}
