import 'package:flutter/material.dart';

/// Provides definitions for pre-made themes
class Themes {
  static ThemeData get strawberryDarkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: strawberryPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        surface: strawberryPrimary,
      ),
    );
  }

  static ThemeData get strawberryLightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: strawberryPrimary,
        brightness: Brightness.light,
      ).copyWith(
        surface: strawberryPrimary,
      ),
    );
  }

  static Color strawberryPrimary = const Color.fromRGBO(251, 99, 118, 1);
}

Map<String, ThemeData> themeMap = {
  "Default Light": ThemeData.light(),
  "Default Dark": ThemeData.dark(),
  "Strawberry Light": Themes.strawberryLightTheme,
  "Strawberry Dark": Themes.strawberryDarkTheme
};
