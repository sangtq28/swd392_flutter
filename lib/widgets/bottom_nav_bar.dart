import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.audio_file),
            label: 'Story'
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.vaccines),
            label: 'Vaccine'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Indicators'
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Teeth'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile'
        ),

      ],

      currentIndex: selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
    );
  }
}
