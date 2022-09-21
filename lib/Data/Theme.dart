import 'package:flutter/material.dart';

/// Provides definitions for pre-made themes
class Themes {
  static ThemeData get strawberryDarkTheme {
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

  static ThemeData get strawberryLightTheme {
    return ThemeData(
      // brightness: Brightness.dark,
      // primaryColor: strawberryPrimary,
      // scaffoldBackgroundColor: strawberrySecondary,
      // fontFamily: 'Montserrat',
      // buttonTheme: ButtonThemeData(buttonColor: strawberryPrimary));
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
  "strawberryLight": Themes.strawberryLightTheme,
  "strawberryDark": Themes.strawberryDarkTheme
};
