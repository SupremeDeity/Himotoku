import 'package:flutter/cupertino.dart';
import 'package:yomu/Data/Chapter.dart';
import 'package:yomu/Extensions/extension.dart';

class Manga {
  Manga({
    required this.source,
    required this.mangaName,
    required this.mangaCover,
    required this.mangaLink,
  });

  /// Source of Manga
  final Extension source;

  /// Image link to cover image.
  final String mangaCover;

  /// Title of manga.
  final String mangaName;

  /// Link to main page of manga.
  final String mangaLink;

  /// Author of manga
  String authorName = "Unknown";

  /// Studio of manga
  String mangaStudio = "Unknown";

  /// Status of manga
  String status = "Unknown";

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

  toJSON() {
    
  }

  /// Read chapters
  List<Chapter> chapters = [];
}
