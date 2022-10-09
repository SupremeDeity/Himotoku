import 'package:isar/isar.dart';

part 'Manga.g.dart';

@Collection()
class Manga {
  Manga({
    required this.extensionSource,
    required this.mangaName,
    required this.mangaCover,
    required this.mangaLink,
  });

  /// Author of manga
  String authorName = "-";

  /// Read chapters
  List<Chapter> chapters = [];

  /// Source of Manga
  @Index()
  final String extensionSource;

  /// Required id by IsarDB
  Id? id;

  @Index()
  bool inLibrary = false;

  /// Image link to cover image.
  String mangaCover;

  /// Link to main page of manga.
  String mangaLink;

  /// Title of manga.
  @Index(composite: [CompositeIndex('extensionSource')])
  String mangaName;

  /// Studio of manga
  String mangaStudio = "-";

  /// Status of manga
  String status = "-";

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

  @Ignore()
  Manga copyWith({
    Id? id,
    String? extensionSource,
    bool? inLibrary,
    String? mangaCover,
    String? mangaName,
    String? mangaLink,
    String? authorName,
    String? mangaStudio,
    String? status,
    List<Chapter>? chapters,
    String? synopsis,
  }) {
    return Manga(
      extensionSource: extensionSource ?? this.extensionSource,
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
      ..synopsis = synopsis ?? this.synopsis;
  }
}

@Embedded()
class Chapter {
  bool isRead = false;
  String? link;
  String? name;
}
