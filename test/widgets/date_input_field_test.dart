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

  testWidgets('DateInputField validates required on save', (tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Form(
            key: formKey,
            child: DateInputField(controller: controller, required: true),
          ),
        ),
      ),
    );

    formKey.currentState!.save();
    await tester.pump();

    expect(find.text('Please enter a date'), findsOneWidget);
  });

  testWidgets('DateInputField clear icon clears text', (tester) async {
    final controller = TextEditingController(text: '01/01/2025');
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: DateInputField(controller: controller),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(controller.text, '');
  });
}
