import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, FirebaseException, FirebaseFirestore, Timestamp;
import 'package:drive_or_drunk_app/core/constants/constants.dart'
    show Collections;
import 'package:drive_or_drunk_app/models/user_model.dart';

class ReviewType {
  static const String drunkard = 'drunkard';
  static const String driver = 'driver';
}

class Review {
  final String? id;
  final DocumentReference author;
  final String text;
  final String type;
  final int rating;
  final Timestamp timestamp;

  Review(
      {this.id,
      required this.author,
      required this.type,
      required this.text,
      required this.rating,
      required this.timestamp});

  factory Review.fromMap(Map<String, dynamic> data, String documentId) {
    return Review(
        id: documentId,
        author: data['author'],
        type: data['type'],
        text: data['text'],
        timestamp: data['timestamp'] as Timestamp,
        rating: (data['rating'] as num).toInt());
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'type': type,
      'text': text,
      'rating': rating,
      'timestamp': timestamp,
    };
  }
}

Future<DocumentReference> addReview(Review review, FirebaseFirestore db) async {
  if (review.id != null) {
    throw FirebaseException(
      plugin: 'Firestore',
      message: 'A review with that ID already exists.',
    );
  }
  return db.collection(Collections.reviews).add(review.toMap());
}

Future<Review?> getReview(String id, FirebaseFirestore db) async {
  final doc = await db.collection(Collections.reviews).doc(id).get();
  if (doc.exists) {
    return Review.fromMap(doc.data()!, doc.id);
  }
  return null;
}

Stream<List<Review>> getReviews(FirebaseFirestore db) {
  return db.collection(Collections.reviews).snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Review.fromMap(doc.data(), doc.id)).toList());
}

Future<void> updateReview(
    String id, Map<String, dynamic> data, FirebaseFirestore db) async {
  await db.collection(Collections.reviews).doc(id).update(data);
}

Future<void> deleteReview(String id, FirebaseFirestore db) async {
  await db.collection(Collections.reviews).doc(id).delete();
}

Future<User> getAuthor(Review review, FirebaseFirestore db) async {
  final authorDoc = await review.author.get();
  final data = authorDoc.data() as Map<String, dynamic>;
  return User.fromMap(data, authorDoc.id);
}
