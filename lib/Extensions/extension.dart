// Parent class for all "Extensions"
abstract class Extension {
  String getName();

  String getIconUrl();

  getMangaList(int pageKey, {String searchQuery = ""});
}
