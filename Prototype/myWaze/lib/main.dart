import 'package:flutter/material.dart';
import 'package:flutter_app_test/screens/guest/enter_app_options.dart';

const String google_maps_key = "AIzaSyABzruSY9X5pBiD50bfYUUEOUO8zloO1jE";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyWaze',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan.shade50),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
