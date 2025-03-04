import 'package:flutter/material.dart';
import 'package:flutter_swd392/screens/home_screen.dart';
import 'package:flutter_swd392/screens/login_screen.dart';
import 'package:flutter_swd392/screens/profile_screen.dart';
import 'package:flutter_swd392/screens/update_profile_screen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Dùng GetMaterialApp thay vì MaterialApp
      home: SignInScreen(),
    );
  }
}
