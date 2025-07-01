import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/date_input_field.dart';

void main() {
  testWidgets('DateInputField updates controller text', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DateInputField(controller: controller),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '01/01/2025');
    expect(controller.text, '01/01/2025');
  });
}
