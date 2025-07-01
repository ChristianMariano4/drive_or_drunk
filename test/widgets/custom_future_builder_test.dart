import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';

void main() {
  testWidgets('CustomFutureBuilder displays data when future completes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomFutureBuilder<String>(
          future: Future.value('hello'),
          component: (data) => Text(data),
        ),
      ),
    );

    // pump until the future completes
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('hello'), findsOneWidget);
  });
}
