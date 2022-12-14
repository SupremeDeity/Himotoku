// ignore_for_file: , non_constant_identifier_names

import 'package:flutter/material.dart';

/// Provides definitions for pre-made themes
class Themes {
  static Color crimsonBackground = const Color.fromARGB(1, 14, 59, 67);
  static Color crimsonPrimary = const Color.fromRGBO(251, 99, 118, 1);
  static Color defaultPrimaryVariant = const Color.fromARGB(255, 0, 50, 240);
  static Color periwinklePrimary = const Color.fromARGB(255, 128, 128, 255);
  static Color warmPrimary = const Color.fromARGB(255, 0, 67, 70);

  static ThemeData get crimsonDarkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: crimsonBackground,
      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(backgroundColor: crimsonBackground),
      colorScheme: ColorScheme.fromSeed(
        seedColor: crimsonPrimary,
        brightness: Brightness.dark,
      ),
    );
  }

  static ThemeData get defaultDark {
    return ThemeData.dark(
      useMaterial3: true,
    );
  }

  static ThemeData get defaultLight {
    return ThemeData.light(
      useMaterial3: true,
    ).copyWith(colorScheme: ColorScheme.highContrastLight());
  }

  static ThemeData get crimsonLightTheme {
    return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: crimsonPrimary,
        ));
  }

  static ThemeData get PeriwinkleLight {
    return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: periwinklePrimary,
        ));
  }

  static ThemeData get PeriwinkleDark {
    return ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: crimsonBackground,
        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(backgroundColor: crimsonBackground),
        colorScheme: ColorScheme.fromSeed(
          seedColor: periwinklePrimary,
          brightness: Brightness.dark,
        ));
  }

  static ThemeData get WarmDark {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: crimsonBackground,
      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(backgroundColor: crimsonBackground),
      colorScheme: ColorScheme.fromSeed(
        seedColor: warmPrimary,
        brightness: Brightness.dark,
      ),
    );
  }

  static ThemeData get WarmLight {
    return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: warmPrimary,
        ));
  }
}

Map<String, ThemeData> ThemesMap = {
  "Crimson Light": Themes.crimsonLightTheme,
  "Crimson Dark": Themes.crimsonDarkTheme,
  "Periwinkle Light": Themes.PeriwinkleLight,
  "Periwinkle Dark": Themes.PeriwinkleDark,
  "Warm Light": Themes.WarmLight,
  "Warm Dark": Themes.WarmDark,
};
