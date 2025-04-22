 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  String? selectedVehicleType;

  final List<String> vehicleTypes = [
    'Car',
    'Motorcycle',
    'Truck',
    'Electric Vehicle',
    'Taxi',
  ];

  Future<void> saveVehicleType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vehicleType', type);
    setState(() {
      selectedVehicleType = type;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vehicle type saved: $type')),
    );
  }

  Future<void> loadSavedType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedVehicleType = prefs.getString('vehicleType');
    });
  }

  @override
  void initState() {
    super.initState();
    loadSavedType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Vehicle Type')),
      body: ListView(
        children: vehicleTypes.map((type) {
          return RadioListTile<String>(
            title: Text(type),
            value: type,
            groupValue: selectedVehicleType,
            onChanged: (value) {
              if (value != null) saveVehicleType(value);
            },
          );
        }).toList(),
      ),
    );
  }
}
