import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yomu/Data/Chapter.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Data/Theme.dart';
import 'package:yomu/Routes/route.gr.dart';

void main() async {
  await Hive.initFlutter();
  // preload manga
  Hive.registerAdapter(MangaAdapter());
  Hive.registerAdapter(ChapterAdapter());
  var mangaBox = await Hive.openBox<Manga>('mangaBox');
  mangaBox.deleteFromDisk();
  runApp(YomuMain());
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
    initHive();
    super.initState();
  }

  initHive() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: Themes.strawberryTheme,
      routerDelegate: _router.delegate(),
      routeInformationParser: _router.defaultRouteParser(),
    );
  }
}
