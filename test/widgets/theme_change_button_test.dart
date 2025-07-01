import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drive_or_drunk_app/widgets/theme_change_button.dart';

class FakeThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

void main() {
  testWidgets('ThemeChangeButton toggles theme', (tester) async {
    final provider = FakeThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<FakeThemeProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Material(
            child: ThemeChangeButton(),
          ),
        ),
      ),
    );

    expect(provider.themeMode, ThemeMode.light);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(provider.themeMode, ThemeMode.dark);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });
}
