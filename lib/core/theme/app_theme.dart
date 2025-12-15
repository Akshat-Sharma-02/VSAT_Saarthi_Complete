import 'package:flutter/material.dart';

class AppTheme {
  // Coolors palette
  static const black = Color(0xFF000000);
  static const navy = Color(0xFF14213D);
  static const orange = Color(0xFFFCA311);
  static const grey = Color(0xFFE5E5E5);
  static const white = Color(0xFFFFFFFF);

  /// 🌙 DARK THEME
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    primaryColor: orange,
    appBarTheme: const AppBarTheme(
      backgroundColor: navy,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: white,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: white),
    ),
  );

  /// ☀️ LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    primaryColor: navy,
    appBarTheme: AppBarTheme(
      backgroundColor: orange,
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: white,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );
}
