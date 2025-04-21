import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color primaryLight = Color(0xFF4285F4); // Blue
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF000000);

  // Dark theme colors
  static const Color primaryDark = Color(0xFFBB86FC); // Purple
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textDark = Color(0xFFFFFFFF);
}
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: AppColors.backgroundLight, // or AppColors.backgroundDark for dark theme
  labelStyle: TextStyle(color: AppColors.textLight), // label color
  hintStyle: TextStyle(color: Colors.grey),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: Colors.grey.shade400),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: AppColors.primaryLight), // or primaryDark
  ),
),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      disabledBackgroundColor: Colors.grey,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    color: AppColors.primaryLight,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: AppColors.textLight),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: AppBarTheme(
    color: AppColors.primaryDark,
    iconTheme: IconThemeData(color: Colors.black),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      disabledBackgroundColor: Colors.grey,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: AppColors.backgroundDark, // or AppColors.backgroundDark for dark theme
  labelStyle: TextStyle(color: AppColors.textDark), // label color
  hintStyle: TextStyle(color: Colors.grey),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: Colors.grey.shade400),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: AppColors.primaryDark), // or primaryDark
  ),
),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: AppColors.textDark),
  ),
);
