import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/home_page/header_image.dart';

void main() {
  testWidgets('HeaderImage shows title text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: HeaderImage(),
        ),
      ),
    );

    expect(find.text('Drive or Drunk?'), findsOneWidget);
  });
}
