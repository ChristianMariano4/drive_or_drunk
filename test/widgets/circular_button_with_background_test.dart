import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/circular_button_with_background.dart';

void main() {
  testWidgets('CircularButtonWithBackground wraps child with padding and color', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: CircularButtonWithBackground(
            backgroundColor: Colors.red,
            padding: EdgeInsets.all(8),
            child: Icon(Icons.add),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.red);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
