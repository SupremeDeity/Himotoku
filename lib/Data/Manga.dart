import 'package:isar/isar.dart';
import 'package:yomu/Extensions/extension.dart';

part 'Manga.g.dart';

@Collection()
class Manga {
  Manga({
    required this.extensionSource,
    required this.mangaName,
    required this.mangaCover,
    required this.mangaLink,
  });

  /// Required id by IsarDB
  Id? id;

  /// Source of Manga
  @Index()
  final String extensionSource;

  @Index()
  bool inLibrary = false;

  /// Image link to cover image.
  final String mangaCover;

  /// Title of manga.
  @Index(composite: [CompositeIndex('extensionSource')])
  final String mangaName;

  /// Link to main page of manga.
  final String mangaLink;

  /// Author of manga
  String authorName = "Unknown";

  /// Studio of manga
  String mangaStudio = "Unknown";

  /// Status of manga
  String status = "Unknown";

  /// Read chapters
  List<Chapter> chapters = [];

  String synopsis = "";

  @Ignore()
  set setChapters(List<Chapter> updatedChapters) {
    chapters.addAll(updatedChapters);
  }

  @Ignore()
  set setStatus(String updatedStatus) {
    status = updatedStatus;
  }

  @Ignore()
  set setAuthorName(String updatedAuthorName) {
    authorName = updatedAuthorName;
  }

  @Ignore()
  set setMangaStudio(String updatedStudio) {
    mangaStudio = updatedStudio;
  }

  @Ignore()
  set setSynopsis(String updatedSynopsis) {
    synopsis = updatedSynopsis;
  }

  @Ignore()
  set setInLibrary(bool updatedInLibrary) {
    inLibrary = updatedInLibrary;
  }
}

@Embedded()
class Chapter {
  String? name;

  String? link;

  bool isRead = false;
}
