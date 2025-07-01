import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_or_drunk_app/widgets/custom_stream_builder.dart';

void main() {
  testWidgets('CustomStreamBuilder shows list items', (tester) async {
    final controller = StreamController<List<int>>();

    await tester.pumpWidget(
      MaterialApp(
        home: CustomStreamBuilder<int>(
          stream: controller.stream,
          customListTileBuilder: (item) => Text('item $item'),
        ),
      ),
    );

    controller.add([1, 2]);
    await tester.pump();

    expect(find.text('item 1'), findsOneWidget);
    expect(find.text('item 2'), findsOneWidget);

    await controller.close();
  });
}
