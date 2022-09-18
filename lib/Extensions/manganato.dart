import 'package:hive_flutter/adapters.dart';
import 'package:yomu/Data/Chapter.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Manganato extends Extension {
  final sort = "all";

  final _baseChapterListQuery = ".chapter-name";
  final _baseUrl = "manganato.com";
  final String _chapterPageListQuery = ".container-chapter-reader > img";
  final _mangaAuthorQuery = ".table-value";
  final _mangaListQuery = ".genres-item-img"; // base query to get manga list

  @override
  String get baseUrl => "https://readmanganato.com/";

  @override
  getChapterPageList(String startLink, int pageKey) async {
    try {
      var url = Uri.parse(startLink);

      var response = await http.get(url);
      var parsedHtml = parse(response.body);

      List<String> pageList = [];

      // Query1: gets author, artist
      var q1 = parsedHtml.querySelectorAll(_chapterPageListQuery);

      for (int x = 0; x < q1.length; x++) {
        pageList.add(q1[x].attributes['src']!);
      }

      return pageList;
    } catch (e) {
      print(e);
      // return manga;
    }
  }

  @override
  getMangaDetails(Manga manga) async {
    try {
      var url = Uri.parse(manga.mangaLink);

      var response = await http.get(
        url,
      );
      var parsedHtml = parse(response.body);

      List<Chapter> chapterList = [];

      // Query1: gets author, status
      var q1 = parsedHtml.querySelectorAll(_mangaAuthorQuery);
      var q2 = parsedHtml.querySelectorAll(_baseChapterListQuery);

      var mangaBox = await Hive.openBox<Manga>('mangaBox');

      Manga updatedManga = Manga(
        extensionSource: manga.extensionSource,
        mangaName: manga.mangaName,
        mangaCover: manga.mangaCover,
        mangaLink: manga.mangaLink,
      );

      updatedManga.setAuthorName = q1[1].text;
      updatedManga.setStatus = q1[2].text;

      // Get chapter list
      for (int x = 0; x < q2.length; x++) {
        // TODO: IMPLMENT ERROR CATCH FOR NULL HERE
        var chapterName = q2[x].text;
        var chapterLink = q2[x].attributes['href']!;

        chapterList.add(Chapter(chapterName, chapterLink));
      }
      updatedManga.setChapters = chapterList;

      mangaBox.put('${updatedManga.extensionSource}-${updatedManga.mangaName}',
          updatedManga);

      return updatedManga;
    } catch (e) {
      print(e);
      // return manga;
    }
  }

  // TODO: IMPLEMENT SORT AND FILTER
  @override
  getMangaList(int pageKey, {String searchQuery = ""}) async {
    try {
      var url = Uri.https(
          _baseUrl, "/advanced_search", {'s': sort, 'page': '$pageKey'});

      var response = await http.get(url);
      var parsedHtml = parse(response.body);
      List<Manga> mangaList = [];

      // Query1: gets title and link
      var q1 = parsedHtml.querySelectorAll(_mangaListQuery);

      for (int x = 0; x < q1.length; x++) {
        // TODO: IMPLMENT ERROR CATCH FOR NULL HERE
        var title = q1[x].attributes['title'];
        var mangaLink = q1[x].attributes['href'];
        var mangaCover = q1[x].children[0].attributes['src'];

        Manga m = Manga(
            extensionSource: name,
            mangaName: title!,
            mangaCover: mangaCover!,
            mangaLink: mangaLink!);

        mangaList.add(m);
      }

      return mangaList;
    } catch (e) {
      print(e);
    }
  }

  @override
  String get iconUrl => "https://manganato.com/themes/hm/images/logo.png";

  @override
  String get name => "Manganato";
}
