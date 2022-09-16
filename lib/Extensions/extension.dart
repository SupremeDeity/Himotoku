// Parent class for all "Extensions"
import 'package:yomu/Data/Manga.dart';

abstract class Extension {
  // First stage:
  String getName();

  String getIconUrl();

  getMangaList(int pageKey, {String searchQuery = ""});

  // Second stage:
  /// Gets details like author, artist, status, chapter list of given `manga`.
  ///
  /// Source field of `manga` param must be valid.
  getMangaDetails(Manga manga);
}
