import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/features/homepage.dart';
import 'package:flutter/material.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;
  final _screens = [
    const HomePage(),
    Container(color: Colors.purple),
    Container(color: Colors.yellow),
    Container(color: Colors.black)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: _selectedIndex,
          indicatorColor: Color(0xFF6B9EC5),
          onDestinationSelected: (index) => _onItemTapped(index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
            NavigationDestination(icon: Icon(Icons.message), label: 'Chat'),
            NavigationDestination(
                icon: Icon(Icons.account_circle), label: 'Profile'),
          ]),
      body: _screens[_selectedIndex],
    );
  }
}
