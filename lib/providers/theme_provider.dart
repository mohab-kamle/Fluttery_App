import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Box? _themeBox;  // Declare a box for theme settings

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _themeBox!.put('isDark', isDark);  // Store theme preference in 'themeBox'
    notifyListeners();
  }

  void _loadTheme() async {
    _themeBox = await Hive.openBox('themeBox');  // Open the 'themeBox'
    _isDarkMode = _themeBox!.get('isDark', defaultValue: false);  // Retrieve theme preference
    notifyListeners();
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
