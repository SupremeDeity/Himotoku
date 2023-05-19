import 'package:flutter/foundation.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Data/models/Setting.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

late Isar isarDB;

Future<void> getIsar() async {
  var dir = await getApplicationDocumentsDirectory();
  isarDB = Isar.openSync(
    [MangaSchema, SettingSchema],
    name: ISAR_INSTANCE_NAME,
    compactOnLaunch: const CompactCondition(minRatio: 2.0),
    inspector: !kReleaseMode,
    directory: dir.path,
  );
}
