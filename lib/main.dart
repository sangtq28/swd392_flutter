import 'package:flutter/material.dart';
import 'package:flutter_swd392/features/storytelling/screens/story_list_screen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Dùng GetMaterialApp thay vì MaterialApp
      home: StoryListScreen(),
    );
  }
}
