import 'package:flutter/material.dart';
import 'package:flutter_swd392/screens/login_screen.dart';
import 'package:flutter_swd392/screens/pricing_page.dart';
import 'package:flutter_swd392/screens/profile_screen.dart';
import 'package:flutter_swd392/screens/register_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register UI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: PricingPage(), // Load SignIn Screen
    );
  }
}
