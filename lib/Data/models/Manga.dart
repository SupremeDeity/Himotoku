// ignore_for_file: invalid_annotation_target,

import 'package:isar/isar.dart';

part 'Manga.g.dart';

@Collection()
class Manga {
  Manga({
    required this.source,
    required this.mangaName,
    required this.mangaCover,
    required this.mangaLink,
  });

  /// Author of manga
  String authorName = "-";

  /// Read chapters
  List<Chapter> chapters = [];

  /// Source of Manga
  @Index(type: IndexType.hash)
  final String source;

  /// Required id by IsarDB
  Id? id;

  @Index()
  bool inLibrary = false;

  /// Image link to cover image.
  String mangaCover;

  /// Link to main page of manga.
  @Index()
  String mangaLink;

  /// Title of manga.
  @Index(type: IndexType.hash)
  String mangaName;

  /// Studio of manga
  String mangaStudio = "-";

  /// Status of manga
  @Index(type: IndexType.hash)
  String status = "-";

  /// Synopsis/Description of comic
  String synopsis = "";

  List<String> genres = [];

  @Ignore()
  Manga copyWith({
    Id? id,
    String? source,
    bool? inLibrary,
    String? mangaCover,
    String? mangaName,
    String? mangaLink,
    String? authorName,
    String? mangaStudio,
    String? status,
    List<Chapter>? chapters,
    String? synopsis,
    List<String>? genres,
  }) {
    return Manga(
      source: source ?? this.source,
      mangaCover: mangaCover ?? this.mangaCover,
      mangaName: mangaName ?? this.mangaName,
      mangaLink: mangaLink ?? this.mangaLink,
    )
      ..id = id ?? this.id
      ..inLibrary = inLibrary ?? this.inLibrary
      ..authorName = authorName ?? this.authorName
      ..mangaStudio = mangaStudio ?? this.mangaStudio
      ..status = status ?? this.status
      ..chapters = chapters ?? this.chapters
      ..synopsis = synopsis ?? this.synopsis
      ..genres = genres ?? this.genres;
  }
}

@Embedded()
class Chapter {
  bool isRead = false;
  String? link;
  String? name;
  // ! Look into storing this as DateTime
  String? releaseDate;

  bool operator ==(Object other) =>
      other is Chapter && link == other.link && name == other.name;
}
