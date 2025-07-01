import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/custom_dropdown.dart';

void main() {
  testWidgets('CustomDropdown shows provided child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return MaterialButton(
              onPressed: () {
                CustomDropdown.show(
                  context: context,
                  child: const Text('Dropdown content'),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Dropdown content'), findsOneWidget);
  });

  testWidgets('CustomDropdown dismiss callback is triggered', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(builder: (context) {
          return MaterialButton(
            onPressed: () {
              CustomDropdown.show(
                context: context,
                child: const Text('Dropdown content'),
                onDismiss: () => dismissed = true,
              );
            },
            child: const Text('Open'),
          );
        }),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
  });
}
