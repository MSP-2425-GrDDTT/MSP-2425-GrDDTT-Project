import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class FakeSpeedMeter extends StatefulWidget {
  const FakeSpeedMeter({super.key});

  @override
  State<FakeSpeedMeter> createState() => _FakeSpeedMeterState();
}

class _FakeSpeedMeterState extends State<FakeSpeedMeter> {
  double _simulatedSpeed = 0;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  @override
  void initState() {
    super.initState();
    _accelSub = accelerometerEvents.listen((AccelerometerEvent event) {
      // Use Y axis (forward/back tilt)
      double tilt = event.y;

      // Map tilt (-10 to 10) → speed (0 to 100 km/h)
      double speed = (1 - ((tilt + 10) / 20)) * 100;
      speed = speed.clamp(0, 100);

      setState(() {
        _simulatedSpeed = speed;
      });
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: Center(
          child: Text(
            "${_simulatedSpeed.toStringAsFixed(1)} km/h",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
