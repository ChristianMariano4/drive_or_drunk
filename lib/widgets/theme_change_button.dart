import 'package:drive_or_drunk_app/core/theme/theme_provider.dart'
    show ThemeProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeChangeButton extends StatelessWidget {
  const ThemeChangeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(context.watch<ThemeProvider>().themeMode == ThemeMode.light
          ? Icons.dark_mode
          : Icons.light_mode),
      onPressed: () {
        context.read<ThemeProvider>().toggleTheme();
      },
    );
  }
}
