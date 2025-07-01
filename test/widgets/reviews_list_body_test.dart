import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/widgets/reviews_list_body.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDocumentReference<T> extends Fake implements DocumentReference<T> {}

class FakeFirestoreService extends FirestoreService {
  FakeFirestoreService(this.author);
  final user_model.User author;

  @override
  Future<user_model.User> getAuthor(Review review) async => author;
}

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });
  testWidgets('ReviewsListBody displays review and author', (tester) async {
    final author = user_model.User(id: 'u', name: 'Bob', username: 'b', email: 'b@a');
    final service = FakeFirestoreService(author);
    final review = Review(
      id: 'r',
      author: FakeDocumentReference(),
      type: ReviewType.driver,
      text: 'Nice',
      rating: 4,
      timestamp: Timestamp.now(),
    );

    await tester.pumpWidget(MaterialApp(
      home: ReviewsListBody(db: service, item: review),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('BOB'), findsOneWidget);
    expect(find.textContaining('Nice'), findsOneWidget);
  });
}
