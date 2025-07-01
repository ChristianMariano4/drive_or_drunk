import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/custom_text_form_field.dart';

void main() {
  testWidgets('CustomTextFormField updates controller text', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CustomTextFormField(
            controller: controller,
            labelText: 'Email',
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'foo');
    expect(controller.text, 'foo');
  });
}
