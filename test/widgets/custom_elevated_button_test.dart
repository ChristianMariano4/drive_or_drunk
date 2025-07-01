import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/custom_elevated_button.dart';

void main() {
  testWidgets('CustomElevatedButton displays label and reacts to tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CustomElevatedButton(
            onPressed: () => tapped = true,
            labelText: 'Press Me',
          ),
        ),
      ),
    );

    expect(find.text('Press Me'), findsOneWidget);

    await tester.tap(find.byType(CustomElevatedButton));
    expect(tapped, isTrue);
  });
}
