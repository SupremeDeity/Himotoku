// Parent class for all "Extensions"
import 'package:yomu/Data/Manga.dart';

abstract class Extension {
  /// Bypass cloudflare with baseurl referer header
  final baseUrl = "";
  final name = "";
  final iconUrl = "";

  getMangaList(int pageKey, {String searchQuery = ""});

  // Second stage:
  /// Gets details like author, artist, status, chapter list of given `manga`.
  ///
  /// Source field of `manga` param must be valid.
  getMangaDetails(Manga manga);

  getChapterPageList(String startLink);
}
