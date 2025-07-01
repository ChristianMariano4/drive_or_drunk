import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/widgets/profile_ratingcard.dart';
import 'package:drive_or_drunk_app/widgets/reviews_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDocumentReference<T> extends Fake implements DocumentReference<T> {}

class FakeFirestoreService extends FirestoreService {
  FakeFirestoreService({required this.author, this.avg = 4.0, this.reviews = const []});

  final user_model.User author;
  final double avg;
  final List<Review> reviews;

  @override
  Future<double> getAverageRating(user_model.User owner, String type) async => avg;

  @override
  Future<List<Review>> getReviewsByType(user_model.User owner, String type) async => reviews;

  @override
  Future<user_model.User> getAuthor(Review review) async => author;
}

void main() {
  testWidgets('ProfileRatingcard shows message when no reviews', (tester) async {
    final owner = user_model.User(id: '1', name: 'Owner', username: 'o', email: 'o@a');
    final service = FakeFirestoreService(author: owner, reviews: []);

    await tester.pumpWidget(MaterialApp(
      home: ProfileRatingcard(owner: owner, reviewType: ReviewType.driver, db: service),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('No reviews available for this user.\n'), findsOneWidget);
  });

  testWidgets('ProfileRatingcard shows rating and preview', (tester) async {
    final owner = user_model.User(id: '1', name: 'Owner', username: 'o', email: 'o@a');
    final review = Review(
      id: 'r',
      author: FakeDocumentReference(),
      type: ReviewType.driver,
      text: 'Great driver',
      rating: 5,
      timestamp: Timestamp.now(),
    );
    final service = FakeFirestoreService(author: owner, reviews: [review]);

    await tester.pumpWidget(MaterialApp(
      home: ProfileRatingcard(owner: owner, reviewType: ReviewType.driver, db: service),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byType(ReviewsPreview), findsOneWidget);
    expect(find.text('Great driver'), findsOneWidget);
  });
}
