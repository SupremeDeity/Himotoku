import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: Themes.strawberryTheme,
      routerDelegate: _router.delegate(),
      routeInformationParser: _router.defaultRouteParser(),
    );
  }
}
