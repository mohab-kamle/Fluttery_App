import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color primaryLight = Color.fromRGBO(33, 94, 156, 1);
  static const Color backgroundLight = Color.fromARGB(255, 255, 240, 240);
  static const Color textLight = Color(0xFF000000);
  static const Color surfaceLight = Color(0xFFF5F5F5);

  // Dark theme colors
  static const Color primaryDark = Color.fromRGBO(81, 151, 220, 1);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  
  // text button theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      textStyle: const TextStyle(fontSize: 16),
    ),
  ),
  // Icon Themes
  iconTheme: const IconThemeData(
    color: AppColors.primaryLight,
    size: 24,
  ),
  primaryIconTheme: const IconThemeData(
    color: AppColors.primaryLight,
    size: 24,
  ),
  
  // Bottom Navigation
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.backgroundLight,
    selectedItemColor: AppColors.primaryLight,
    unselectedItemColor: Colors.grey,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    elevation: 8,
  ),
  
  // Icon Buttons
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColors.primaryLight,

    ),
  ),
  
  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: false,
    fillColor: AppColors.surfaceLight,
    labelStyle: const TextStyle(color: AppColors.primaryLight,fontSize: 14),
    hintStyle: TextStyle(color: Colors.grey.shade600),
    prefixIconColor: AppColors.primaryLight,
    suffixIconColor: AppColors.primaryLight,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 2.0),
    ),
  ),
  
  // Elevated Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primaryLight,
      disabledBackgroundColor: Colors.grey.shade300,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  
  // App Bar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: Colors.white,
    elevation: 4,
    centerTitle: true,
  ),
  
  // Text Theme
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textLight),
    bodyMedium: TextStyle(color: AppColors.textLight),
    titleMedium: TextStyle(color: AppColors.primaryLight),
  ),
  
  // Switch Theme
  switchTheme: SwitchThemeData(
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) 
          ? AppColors.primaryLight.withAlpha(125) 
          : Colors.black;
    }),
    thumbColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) 
          ? AppColors.primaryLight 
          : Colors.black;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) 
          ? AppColors.primaryLight.withAlpha(125)
          : Colors.grey.withAlpha(125);
    }),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  
  // text button theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryDark,
      textStyle: const TextStyle(fontSize: 16),
    ),
  ),
  // Icon Themes
  iconTheme: const IconThemeData(
    color: AppColors.primaryDark,
    size: 24,
  ),
  primaryIconTheme: const IconThemeData(
    color: AppColors.primaryDark,
    size: 24,
  ),
  
  // Bottom Navigation
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.backgroundDark,
    selectedItemColor: AppColors.primaryDark,
    unselectedItemColor: Colors.grey,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    elevation: 8,
  ),
  
  // Icon Buttons
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColors.primaryDark,
    ),
  ),
  
  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark,
    labelStyle: const TextStyle(color: Colors.white,fontSize: 14),
    hintStyle: TextStyle(color: Colors.grey.shade400),
    prefixIconColor: AppColors.primaryDark,
    suffixIconColor: AppColors.primaryDark,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.primaryDark, width: 2.0),
    ),
  ),
  
  // Elevated Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primaryDark,
      disabledBackgroundColor: Colors.grey.shade800,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  
  // App Bar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: Colors.white,
    elevation: 4,
    centerTitle: true,
  ),
  
  // Text Theme
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textDark),
    bodyMedium: TextStyle(color: AppColors.textDark),
    titleMedium: TextStyle(color: AppColors.primaryDark),
  ),
  
  // Switch Theme
  switchTheme: SwitchThemeData(
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) 
          ? AppColors.primaryDark.withAlpha(125) 
          : Colors.white70;
    }),
    thumbColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) 
          ? AppColors.primaryDark 
          : Colors.grey;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.selected) 
          ? AppColors.primaryDark.withAlpha(125)
          : Colors.grey.withAlpha(125);
    }),
  ),

  // Bottom navigation bar theme
);
