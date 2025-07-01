import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/custom_filled_button.dart';

void main() {
  testWidgets('CustomFilledButton displays label and reacts to tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CustomFilledButton(
            onPressed: () => tapped = true,
            labelText: 'Submit',
          ),
        ),
      ),
    );

    expect(find.text('Submit'), findsOneWidget);

    await tester.tap(find.byType(CustomFilledButton));
    expect(tapped, isTrue);
  });
}
