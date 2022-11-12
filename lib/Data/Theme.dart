// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/material.dart';

/// Provides definitions for pre-made themes
class Themes {
  static Color crimsonBackground = const Color.fromARGB(1, 14, 59, 67);
  static Color crimsonPrimary = const Color.fromRGBO(251, 99, 118, 1);
  static Color periwinklePrimary = const Color.fromARGB(255, 128, 128, 255);

  static Color defaultPrimaryVariant = const Color.fromARGB(255, 0, 50, 240);

  static ThemeData get crimsonDarkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: crimsonPrimary,
        brightness: Brightness.dark,
      ).copyWith(surface: crimsonPrimary),
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
    ).copyWith(
        colorScheme: ThemeData.light().colorScheme.copyWith(
              inversePrimary: defaultPrimaryVariant,
              surface: ThemeData.light().primaryColor,
              onSurface: ThemeData.light().colorScheme.onBackground,
            ));
  }

  static ThemeData get crimsonLightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: crimsonPrimary,
        brightness: Brightness.light,
      ).copyWith(
        surface: crimsonPrimary,
      ),
    );
  }

  static ThemeData get PeriwinkleLight {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: periwinklePrimary,
        brightness: Brightness.light,
      ).copyWith(
        surface: periwinklePrimary,
      ),
    );
  }

  static ThemeData get PeriwinkleDark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: periwinklePrimary,
        brightness: Brightness.dark,
      ).copyWith(
        surface: periwinklePrimary,
      ),
    );
  }

  static ThemeData get WarmBlack {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 0, 67, 70),
        brightness: Brightness.dark,
      ).copyWith(
        surface: const Color.fromARGB(255, 0, 67, 70),
      ),
    );
  }

  static ThemeData get WarmLight {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 0, 67, 70),
        brightness: Brightness.light,
      ).copyWith(
        surface: const Color.fromARGB(255, 0, 67, 70),
      ),
    );
  }
}

Map<String, ThemeData> themeMap = {
  "Default Light": Themes.defaultLight,
  "Default Dark": Themes.defaultDark,
  "Crimson Light": Themes.crimsonLightTheme,
  "Crimson Dark": Themes.crimsonDarkTheme,
  "Periwinkle Light": Themes.PeriwinkleLight,
  "Periwinkle Dark": Themes.PeriwinkleDark,
  "Warm Black": Themes.WarmBlack,
  "Warm Light": Themes.WarmLight
};
