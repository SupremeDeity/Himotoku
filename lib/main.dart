import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Data/Setting.dart';
import 'package:yomu/Data/Theme.dart';
import 'package:yomu/Pages/library.dart';

// TODO: 3) Add Sort to Library
// TODO: 4) Add Sort to SourceExplore
// TODO: 5) Add Default sort setting of library to Settings
// TODO: 6) Fix ReaperScans
// TODO: 7) Add verbose logging while in release
// TODO: 8) Add "About"

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Isar.open(
    [MangaSchema, SettingSchema],
    name: "isarInstance",
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
    var isarInstance = Isar.getInstance('isarInstance')!;
    Logger logger = Logger();

    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var defaultTheme = isDarkMode ? "Default Dark" : "Default Light";
    var currentSettings = await isarInstance.settings.get(0);

    if (currentSettings == null) {
      print("first time init");
      await isarInstance.writeTxn(() async {
        await isarInstance.settings
            .put(Setting().copyWith(newTheme: defaultTheme));
      });
    }

    logger.i("Is DarkMode default: $isDarkMode");

    logger.i("Using theme: ${currentSettings?.theme}");
    Get.changeTheme(themeMap[currentSettings?.theme ?? defaultTheme]!);
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
