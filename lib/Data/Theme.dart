import 'package:flutter/material.dart';

/// Provides definitions for pre-made themes
class Themes {
  static Color strawberryBackground = const Color.fromARGB(1, 14, 59, 67);
  static Color strawberryPrimary = const Color.fromRGBO(251, 99, 118, 1);

  static ThemeData get strawberryDarkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: strawberryPrimary,
        brightness: Brightness.dark,
      ).copyWith(surface: strawberryPrimary),
    );
  }

  static ThemeData get defaultDark {
    return ThemeData(useMaterial3: true, brightness: Brightness.dark);
  }

  static ThemeData get defaultLight {
    return ThemeData(useMaterial3: true, brightness: Brightness.light);
  }

  static ThemeData get strawberryLightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: strawberryPrimary,
        brightness: Brightness.light,
      ).copyWith(
        surface: strawberryPrimary,
      ),
    );
  }
}

Map<String, ThemeData> themeMap = {
  "Default Light": Themes.defaultLight,
  "Default Dark": Themes.defaultDark,
  "Strawberry Light": Themes.strawberryLightTheme,
  "Strawberry Dark": Themes.strawberryDarkTheme
};
