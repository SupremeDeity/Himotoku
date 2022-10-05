import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
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
  final _mangaSynopsisQuery = "#panel-story-info-description";

  @override
  String get baseUrl => _baseUrl;

  @override
  getChapterPageList(String startLink) async {
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
      var logger = Logger();

      logger.e(e);
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
      var q3 = parsedHtml.querySelector(_mangaSynopsisQuery);

      // var mangaBox = await Hive.openBox<Manga>('mangaBox');
      var isarInstance = Isar.getInstance('mangaInstance');

      Manga updatedManga = Manga(
        extensionSource: name,
        mangaName: manga.mangaName,
        mangaCover: manga.mangaCover,
        mangaLink: manga.mangaLink,
      );

      updatedManga.setAuthorName = q1[1].text.trim();
      updatedManga.setStatus = q1[2].text.trim();
      updatedManga.setSynopsis = q3!.text.trim();

      try {
        final allManga = isarInstance?.mangas;
        // check if manga already exists
        final _manga = await allManga!
            .where()
            .mangaNameExtensionSourceEqualTo(manga.mangaName, name)
            .findAll();

        // Get chapter list
        for (int x = 0; x < q2.length; x++) {
          var chapterName = q2[x].text.trim();
          var chapterLink = q2[x].attributes['href']!;
          var isRead = _manga.isNotEmpty
              ? (x < _manga[0].chapters.length
                  ? _manga[0].chapters[x].isRead
                  : false)
              : false;

          final nChap = Chapter()
            ..name = chapterName
            ..link = chapterLink
            ..isRead = isRead;

          chapterList.add(nChap);
        }
        updatedManga.setChapters = chapterList;

        await isarInstance?.writeTxn(() async {
          if (_manga.isNotEmpty) {
            updatedManga.id = _manga[0].id;
            updatedManga.setInLibrary = _manga[0].inLibrary;
          }
          await allManga.put(updatedManga);
        });
        return updatedManga;
      } catch (e) {
        var logger = Logger();

        logger.e(e);
      }
    } catch (e) {
      var logger = Logger();

      logger.e(e);
    }
  }

  @override
  getMangaList(int pageKey, {String searchQuery = ""}) async {
    try {
      var url;
      if (searchQuery.isEmpty) {
        url = Uri.https(
            _baseUrl, "/advanced_search", {'s': sort, 'page': '$pageKey'});
      } else {
        url = Uri.https(
            _baseUrl, "/search/story/$searchQuery", {'page': '$pageKey'});
      }

      var response = await http.get(url);
      var parsedHtml = parse(response.body);
      List<Manga> mangaList = [];

      // Query1: gets title and link

      var q1 = parsedHtml.querySelectorAll(
          searchQuery.isEmpty ? _mangaListQuery : ".item-img.bookmark_check");

      for (int x = 0; x < q1.length; x++) {
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
      var logger = Logger();

      logger.e(e);
    }
  }

  @override
  String get iconUrl => "https://manganato.com/themes/hm/images/logo.png";

  @override
  String get name => "Manganato";
}
