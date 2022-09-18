import 'package:flutter/material.dart';

/// Provides definitions for pre-made themes
class Themes {
  static ThemeData get strawberryTheme {
    return ThemeData(
      // brightness: Brightness.dark,
      // primaryColor: strawberryPrimary,
      // scaffoldBackgroundColor: strawberrySecondary,
      // fontFamily: 'Montserrat',
      // buttonTheme: ButtonThemeData(buttonColor: strawberryPrimary));
      colorScheme: ColorScheme.fromSeed(
        seedColor: strawberryPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        surface: strawberryPrimary,
      ),
    );
  }

  static Color strawberryPrimary = const Color.fromRGBO(251, 99, 118, 1);
  static Color strawberrySecondary = const Color.fromRGBO(42, 50, 75, 1.0);
}
