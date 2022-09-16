import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yomu/Data/Chapter.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Routes/route.gr.dart';

void main() async {
  await Hive.initFlutter();
  Hive.deleteFromDisk();
  // preload manga
  Hive.registerAdapter(MangaAdapter());
  Hive.registerAdapter(ChapterAdapter());
  await Hive.openBox<Manga>('mangaBox');

  runApp(YomuMain());
}

class YomuMain extends StatefulWidget {
  const YomuMain({super.key});

  @override
  State<YomuMain> createState() => _YomuMainState();
}

class _YomuMainState extends State<YomuMain> {
  final _router = YomuRouter();

  initHive() async {}

  @override
  void initState() {
    initHive();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.dark(),
      routerDelegate: _router.delegate(),
      routeInformationParser: _router.defaultRouteParser(),
    );
  }
}
