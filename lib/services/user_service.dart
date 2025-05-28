import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/features/authentication/user_provider.dart';
import 'package:drive_or_drunk_app/models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  late UserProvider userProvider;

  void init(UserProvider provider) {
    userProvider = provider;
  }

  void refreshUser() => userProvider.loadUser();
  void updateLocally(User user) => userProvider.updateUserLocally(user);
  User getUser() => userProvider.user!;
  DocumentReference getUserRef() => userProvider.userRef!;
}
