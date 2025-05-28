import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/models/user_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  DocumentReference? _userRef;

  User? get user => _user;
  DocumentReference? get userRef => _userRef;

  final _firestoreService = FirestoreService();

  Future<void> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _user = await _firestoreService.getUser(uid);
      _userRef = await _firestoreService.getUserReference(uid);
      notifyListeners();
    }
  }

  void updateUserLocally(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}
