// Parent class for all "Sources"
import 'package:himotoku/Data/Manga.dart';

abstract class Source {
  /// Bypass cloudflare with baseurl referer header
  final baseUrl = "";
  final name = "";
  final iconUrl = "";

  Future<List<Manga>>? getMangaList(int pageKey, {String searchQuery = ""});

  // Second stage:
  /// Gets details like author, artist, status, chapter list of given `manga`.
  ///
  /// Source field of `manga` param must be valid.
  Future<Manga>? getMangaDetails(Manga manga);

  Future<List<String>>? getChapterPageList(String startLink);
}
