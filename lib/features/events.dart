import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/models/user_model.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class eventsPage extends StatelessWidget {
  eventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Events"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SearchBar(
        onSearch: (String query) {
          // Implement search functionality here
          print("Searching for: $query");
        },
      ),
    );
  }
}
