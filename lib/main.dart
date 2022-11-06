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
import 'package:yomu/test.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Isar.open(
    [MangaSchema, SettingSchema],
    name: "isarInstance",
    compactOnLaunch: const CompactCondition(minRatio: 2.0),
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
