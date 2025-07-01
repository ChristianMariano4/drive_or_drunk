import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/chat/chat_bubble.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';

void main() {
  testWidgets('ChatBubble shows message and correct color for user 1', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: ChatBubble(message: 'Hi', userNumber: 1),
        ),
      ),
    );

    expect(find.text('Hi'), findsOneWidget);
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.primaryColor);
  });
}
