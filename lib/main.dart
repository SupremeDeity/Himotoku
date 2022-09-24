import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Data/Theme.dart';
import 'package:yomu/Pages/library.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Isar.open(
    [MangaSchema],
    // directory: applicationSupportDir.path,
    name: "mangaInstance",
  );
  runApp(const YomuMain());
}

class YomuMain extends StatefulWidget {
  const YomuMain({super.key});

  @override
  State<YomuMain> createState() => _YomuMainState();
}

class _YomuMainState extends State<YomuMain> {
  initPrefs() async {
    final preferences = await StreamingSharedPreferences.instance;

    Logger logger = Logger();

    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var defaultTheme = isDarkMode ? "Default Dark" : "Default Light";
    var currentTheme =
        preferences.getString("theme", defaultValue: defaultTheme).getValue();

    logger.i("Is DarkMode default: $isDarkMode");

    logger.i("Using theme: $currentTheme");
    Get.changeTheme(themeMap[currentTheme]!);
    logger.i(Get.theme.colorScheme.brightness);
    logger.i("Initialized app, removing splash screen.");
    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    initPrefs();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: Library(),
      themeMode: ThemeMode.system,
    );
  }
}
