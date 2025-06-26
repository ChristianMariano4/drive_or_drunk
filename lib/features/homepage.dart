import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/widgets/home_page/header_image.dart';
import 'package:drive_or_drunk_app/widgets/home_page/tab_search_section.dart';
import 'package:drive_or_drunk_app/widgets/home_page/trending_section.dart';
import 'package:drive_or_drunk_app/widgets/theme_change_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
          const ThemeChangeButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HeaderImage(),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSizes.md,
                  right: AppSizes.md,
                ),
                child: TabSearchSection(),
              ),
              const TrendingSection()
            ],
          ),
        ),
      ),
    );
  }
}
