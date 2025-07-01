import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/images/custom_rounder_image.dart';

void main() {
  testWidgets('CustomRoundedImage renders provided base64 image', (tester) async {
    const base64Image =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8HwQACfsD/UsGrTQAAAAASUVORK5CYII=';

    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: CustomRoundedImage(image: base64Image),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}
