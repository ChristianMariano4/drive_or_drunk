import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/image_input_field.dart';

void main() {
  testWidgets('ImageInputField shows select text', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Material(
        child: ImageInputField(onImageSelected: _onSelected),
      ),
    ));

    expect(find.text('Select Image'), findsOneWidget);
  });
}

void _onSelected(File _) {}
