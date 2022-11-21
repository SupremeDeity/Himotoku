import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:himotoku/Sources/SourceHelper.dart';
// import 'package:himotoku/FileOutput.dart';
import 'package:isar/isar.dart';
import 'package:himotoku/Data/Constants.dart';

import 'package:himotoku/Data/Manga.dart';
import 'package:himotoku/Data/Setting.dart';
import 'package:himotoku/Data/Theme.dart';
import 'package:himotoku/Pages/library.dart';

// import 'package:himotoku/test.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    const himotokuMain(),
  );
}

class himotokuMain extends StatefulWidget {
  const himotokuMain({super.key});

  @override
  State<himotokuMain> createState() => _himotokuMainState();
}

class _himotokuMainState extends State<himotokuMain> {
  ThemeData? currentTheme;
  Isar? isarInstance;

  @override
  void initState() {
    initPrefs();

    super.initState();
  }

  getTheme() async {
    var settings = await isarInstance!.settings.get(0);
    setState(() {
      currentTheme = themeMap[settings!.theme];
    });
  }

  initPrefs() async {
    Isar.openSync(
      [MangaSchema, SettingSchema],
      name: ISAR_INSTANCE_NAME,
      compactOnLaunch: const CompactCondition(minRatio: 2.0),
    );

    setState(() {
      isarInstance = Isar.getInstance(ISAR_INSTANCE_NAME);
    });

    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var defaultTheme = isDarkMode ? "Default Dark" : "Default Light";
    var currentSettings = await isarInstance!.settings.get(0);

    if (currentSettings == null) {
      isarInstance!.writeTxnSync(() {
        isarInstance!.settings
            .putSync(Setting().copyWith(newTheme: defaultTheme));
      });
    }
    Stream<void> instanceChanged =
        isarInstance!.settings.watchLazy(fireImmediately: true);
    instanceChanged.listen(
      (event) async {
        getTheme();
      },
    );
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Library(),
      themeMode: ThemeMode.system,
      theme: currentTheme,
    );
  }
}
