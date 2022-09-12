import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Asura extends Extension {
  final _baseMangaListQuery = ".listupd .bs a"; // base query to get manga list
  final _baseUrl = "asurascans.com";
  final _defaultSort = "/manga";

  @override
  String getIconUrl() {
    return "https://www.asurascans.com/wp-content/uploads/2021/03/Group_1.png";
  }

  // TODO: IMPLEMENT SORT AND FILTER
  @override
  getMangaList(int pageKey, {String searchQuery = ""}) async {
    try {
      var url;
      if (searchQuery.isEmpty) {
        url = Uri.https(_baseUrl, _defaultSort, {'page': "$pageKey"});
      } else {
        print(searchQuery);
        url = Uri.https(_baseUrl, "/page/$pageKey", {'s': searchQuery});
      }
      var response = await http.get(url);
      var parsedHtml = parse(response.body);
      List<Manga> mangaList = [];

      // Query1: gets title and link
      var q1 = parsedHtml.querySelectorAll(_baseMangaListQuery);
      // Query2: gets cover art
      var q2 = parsedHtml.querySelectorAll("$_baseMangaListQuery img");

      for (int x = 0; x < q1.length; x++) {
        // TODO: IMPLMENT ERROR CATCH FOR NULL HERE
        var title = q1[x].attributes['title'];
        var mangaLink = q1[x].attributes['href'];
        var mangaCover = q2[x].attributes['src'];

        mangaList.add(Manga(title!, mangaCover!, mangaLink!));
      }

      return mangaList;
    } catch (e) {
      print(e);
    }
  }

  @override
  String getName() {
    return "Asura Scans";
  }
}
