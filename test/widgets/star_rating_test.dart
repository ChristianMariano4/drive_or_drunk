import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/star_rating.dart';

void main() {
  testWidgets('StarRating shows correct star icons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: StarRating(rating: 3.5, size: 24),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsNWidgets(3));
    expect(find.byIcon(Icons.star_half), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });
}
