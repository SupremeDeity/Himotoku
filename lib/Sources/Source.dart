// Parent class for all "Sources"

import 'package:himotoku/Data/models/Manga.dart';

abstract class Source {
  /// * Bypass cloudflare with baseurl referer header.
  final baseUrl = "";

  final iconUrl = "";
  final name = "";
  final Map<String, String> orderBySortOptions = {};
  final Map<String, String> statusSortOptions = {};
  final Map<String, String> typeSortOptions = {};
  final Map<String, String> genreSortOptions = {};

  Future<List<Manga>>? getMangaList(
    int pageKey, {
    String searchQuery = "",
    String orderBy,
    String statusBy,
    String typesBy,
    List<String>? genresBy,
  });

  // Second stage:
  /// Gets details like author, artist, status, chapter list of given `manga`.
  ///
  /// Source field of `manga` param must be valid.
  Future<Manga>? getMangaDetails(Manga manga);

  Future<List<String>>? getChapterPageList(String startLink);
}
