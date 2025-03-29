import 'package:flutter/material.dart';
import 'package:flutter_swd392/features/storytelling/screens/story_list_screen.dart';
import 'package:flutter_swd392/screens/all_child_indicator_screen.dart';
import 'package:flutter_swd392/screens/all_child_teeth.dart';
import 'package:flutter_swd392/screens/create_record_screen.dart';
import 'package:flutter_swd392/screens/profile_screen.dart';
import 'package:flutter_swd392/screens/vaccine_record_list.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các trang
  final List<Widget> _pages = [
    Center(child: StoryListScreen()),
    Center(child: VaccineRecordListScreen()),
    Center(child: AllChildIndicatorScreen()),
    Center(child: AllChildTeeth()),
    Center(child: UserScreen()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
