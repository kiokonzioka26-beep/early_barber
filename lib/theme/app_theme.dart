import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF000000); // Black
  static const Color secondaryColor = Color(0xFFD4AF37); // Gold
  static const Color backgroundColor = Color(0xFFFFFFFF); // White

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: backgroundColor,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
  );
}