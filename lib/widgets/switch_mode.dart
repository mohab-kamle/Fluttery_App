import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SwitchMode extends StatelessWidget {
  const SwitchMode({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Switch(
      value: themeProvider.isDarkMode,
      onChanged: (isDark) => themeProvider.toggleTheme(isDark),
      thumbIcon: WidgetStateProperty.all(
        Icon(
          themeProvider.isDarkMode
              ? Icons.brightness_3_sharp
              : Icons.brightness_4,
          color: themeProvider.isDarkMode ? Colors.white : null,
        ),
      ),
    );
  }
}
