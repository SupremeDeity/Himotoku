import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';

class Manganato extends Extension {
  @override
  String getIconUrl() {
    return "https://manganato.com/themes/hm/images/logo.png";
  }

  @override
  getMangaList(int pageKey, {String searchQuery = ""}) {
    // TODO: implement getMangaList
    throw UnimplementedError();
  }

  @override
  String getName() {
    return "Manganato";
  }

  @override
  Manga getMangaDetails(Manga manga) {
    // TODO: implement getMangaDetails
    throw UnimplementedError();
  }
}
