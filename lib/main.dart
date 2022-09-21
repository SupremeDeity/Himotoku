import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Data/Theme.dart';
import 'package:yomu/Routes/route.gr.dart';

void main() async {
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
  final _router = YomuRouter();
  SharedPreferences? prefs;

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if (!(prefs!.containsKey("theme"))) {
      var brightness = SchedulerBinding.instance.window.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;
      prefs!.setString(
          "theme", isDarkMode ? "strawberryDark" : "strawberryLight");
    }
    print("object");
  }

  @override
  void initState() {
    initPrefs();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: themeMap[prefs?.getString("theme")],
      routerDelegate: _router.delegate(),
      routeInformationParser: _router.defaultRouteParser(),
    );
  }
}
