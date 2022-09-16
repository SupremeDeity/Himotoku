import 'package:hive_flutter/adapters.dart';

part "Chapter.g.dart";

@HiveType(typeId: 1)
class Chapter {
  Chapter(this.name, this.link);

  @HiveField(0)
  String name;

  @HiveField(1)
  String link;

  @HiveField(2)
  bool isRead = false;
}
