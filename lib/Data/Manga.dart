import 'package:hive/hive.dart';
import 'package:yomu/Data/Chapter.dart';
import 'package:yomu/Extensions/extension.dart';

part 'Manga.g.dart';

@HiveType(typeId: 0)
class Manga {
  Manga({
    required this.extensionSource,
    required this.mangaName,
    required this.mangaCover,
    required this.mangaLink,
  });

  /// Source of Manga
  @HiveField(0)
  final String extensionSource;

  /// Image link to cover image.
  @HiveField(1)
  final String mangaCover;

  /// Title of manga.
  @HiveField(2)
  final String mangaName;

  /// Link to main page of manga.
  @HiveField(3)
  final String mangaLink;

  /// Author of manga
  @HiveField(4)
  String authorName = "Unknown";

  /// Studio of manga
  @HiveField(5)
  String mangaStudio = "Unknown";

  /// Status of manga
  @HiveField(6)
  String status = "Unknown";

  /// Read chapters
  @HiveField(7)
  List<Chapter> chapters = [];

  @HiveField(8)
  String synopsis = "";

  set setChapters(List<Chapter> updatedChapters) {
    chapters.addAll(updatedChapters);
  }

  set setStatus(String updatedStatus) {
    status = updatedStatus;
  }

  set setAuthorName(String updatedAuthorName) {
    authorName = updatedAuthorName;
  }

  set setMangaStudio(String updatedStudio) {
    mangaStudio = updatedStudio;
  }

  set setSynopsis(String updatedSynopsis) {
    synopsis = updatedSynopsis;
  }
}
