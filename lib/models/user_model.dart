import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, FirebaseFirestore;
import 'package:drive_or_drunk_app/core/constants/constants.dart'
    show Collections;
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/services/user_service.dart';

class User {
  final String? id;
  final String name;
  final String username;
  final String email;
  final bool isVerified;
  final int? age;
  final String? profilePicture;
  final List<DocumentReference> registeredEvents;
  final List<DocumentReference> favoriteEvents;
  final List<DocumentReference> favoriteUsers;
  final List<DocumentReference> reviews;
  // TODO: add a conversations field to the User model
  // TODO: add a list of favorite users field to the User model

  User({
    this.id,
    required this.name,
    this.isVerified = false,
    this.age,
    required this.username,
    required this.email,
    this.profilePicture,
    this.registeredEvents = const [],
    this.favoriteEvents = const [],
    this.favoriteUsers = const [],
    this.reviews = const [],
  });

  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      isVerified: data['isVerified'] ?? false,
      age: data['age'] ?? 0,
      profilePicture: data['profilePicture'],
      registeredEvents:
          List<DocumentReference>.from(data['registeredEvents'] ?? []),
      favoriteEvents:
          List<DocumentReference>.from(data['favoriteEvents'] ?? []),
      favoriteUsers: List<DocumentReference>.from(data['favoriteUsers'] ?? []),
      reviews: List<DocumentReference>.from(data['reviews'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'isVerified': isVerified,
      'age': age,
      'profilePicture': profilePicture,
      'registeredEvents': registeredEvents,
      'favoriteEvents': favoriteEvents,
      'favoriteUsers': favoriteUsers,
      'reviews': reviews,
    };
  }
}

Future<DocumentReference?> getUserReference(
    String id, FirebaseFirestore db) async {
  return db.collection(Collections.users).doc(id);
}

Future<void> addUser(User user, FirebaseFirestore db) async {
  if (user.id == null) {
    db.collection(Collections.users).add(user.toMap());
  } else {
    db.collection(Collections.users).doc(user.id).set(user.toMap());
  }
}

Future<User?> getUser(String id, FirebaseFirestore db) async {
  final doc = await db.collection(Collections.users).doc(id).get();
  if (doc.exists) {
    return User.fromMap(doc.data()!, doc.id);
  }
  return null;
}

Stream<List<User>> searchUsersByName(String name, FirebaseFirestore db) {
  final query = db
      .collection('User')
      .where('name', isGreaterThanOrEqualTo: name)
      .where('name', isLessThanOrEqualTo: '$name\uf8ff');

  return query.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => User.fromMap(doc.data(), doc.id)).toList());
}

Stream<List<User>> getUsers(FirebaseFirestore db) {
  return db.collection(Collections.users).snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => User.fromMap(doc.data(), doc.id)).toList());
}

Future<void> updateUser(
    String id, Map<String, dynamic> data, FirebaseFirestore db) async {
  await db.collection(Collections.users).doc(id).update(data);
}

Future<void> deleteUser(String id, FirebaseFirestore db) async {
  await db.collection(Collections.users).doc(id).delete();
}

Future<void> addReview(
    DocumentReference review, User user, FirebaseFirestore db) async {
  user.reviews.add(review);
  await updateUser(user.id!, user.toMap(), db);
}

Future<void> addFavoriteUser(
    DocumentReference user, User currentUser, FirebaseFirestore db) async {
  currentUser.favoriteUsers.add(user);
  await updateUser(currentUser.id!, currentUser.toMap(), db);
  UserService().updateLocally(currentUser);
}

Future<void> removeFavoriteUser(
    DocumentReference user, User currentUser, FirebaseFirestore db) async {
  currentUser.favoriteUsers.remove(user);
  await updateUser(currentUser.id!, currentUser.toMap(), db);
  UserService().updateLocally(currentUser);
}

Future<void> addFavoriteEvent(
    Event event, String userId, FirebaseFirestore db) async {
  final user = await getUser(userId, db);
  final eventRef = await db
      .collection(Collections.events)
      .doc(event.id)
      .get()
      .then((snapshot) => snapshot.reference);
  user!.favoriteEvents.add(eventRef);
  await updateUser(user.id!, user.toMap(), db);
  UserService().updateLocally(user);
}

Future<void> removeFavoriteEvent(
    Event event, String userId, FirebaseFirestore db) async {
  final user = await getUser(userId, db);
  final eventRef = await db
      .collection(Collections.events)
      .doc(event.id)
      .get()
      .then((snapshot) => snapshot.reference);
  user!.favoriteEvents.remove(eventRef);
  await updateUser(user.id!, user.toMap(), db);
  UserService().updateLocally(user);
}

Future<List<Review>> getReviewsByType(
    User user, FirebaseFirestore db, String reviewType) async {
  final List<Review> reviewsByType = [];
  for (final reviewRef in user.reviews) {
    final reviewDoc = await reviewRef.get();
    if (reviewDoc.exists) {
      final data = reviewDoc.data() as Map<String, dynamic>;
      if (data['type'] == reviewType) {
        reviewsByType.add(Review.fromMap(data, reviewDoc.id));
      }
    }
  }
  return reviewsByType;
}

Future<double> calculateRatingAverage(
    User user, FirebaseFirestore db, String reviewType) async {
  double totalRating = 0;
  double count = 0;
  double averageRating = 0;

  for (final reviewRef in user.reviews) {
    final reviewDoc = await reviewRef.get();
    if (reviewDoc.exists) {
      final data = reviewDoc.data() as Map<String, dynamic>;
      if (data['type'] == reviewType && data['rating'] != null) {
        totalRating += data['rating'];
        count++;
      }
    }
  }
  if (count > 0) {
    averageRating = totalRating / count;
  }
  return averageRating;
}
