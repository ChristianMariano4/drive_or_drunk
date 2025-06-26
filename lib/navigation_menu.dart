import 'package:drive_or_drunk_app/features/chat/chat_list_page.dart';
import 'package:drive_or_drunk_app/features/events/events_list_page.dart'
    show EventsListPage;
import 'package:drive_or_drunk_app/features/events/events_map_page.dart';
import 'package:drive_or_drunk_app/features/homepage.dart';
import 'package:drive_or_drunk_app/features/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  NavigationMenuState createState() => NavigationMenuState();
}

class NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;
  final _screens = [
    const HomePage(),
    const EventsMapPage(),
    ChatListPage(),
    ProfilePage(owner: FirebaseAuth.instance.currentUser!.uid),
    ProfilePage(owner: FirebaseAuth.instance.currentUser!.uid),
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
          indicatorColor: const Color(0xFF6B9EC5),
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
