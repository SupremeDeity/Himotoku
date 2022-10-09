import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class ReaperScans extends Extension {
  final baseSourceExplore = "/comics";
  final _chapterNameQuery = "p.truncate";
  final _baseChapterListQuery = "a[href*=\"chapter-\"].transition.block";
  final _baseUrl = "reaperscans.com";
  final _chapterPageListQuery = "img.display-block";
  // final _mangaAuthorQuery = ".summary-content"; -> Disabled
  final _mangaListQuery =
      "a[href*=\"comic\"].transition.relative"; // base query to get manga list

  final _mangaSynopsisQuery = ".prose";

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

      for (int x = 1; x < q1.length; x++) {
        pageList.add(q1[x].attributes['src']!);
      }

      return pageList;
    } catch (e) {
      var logger = Logger();

      logger.e(e);
      // return manga;
    }
  }

  @override
  getMangaDetails(Manga manga) async {
    try {
      var url = Uri.parse(manga.mangaLink);

      var response = await http.get(url);
      var parsedHtml = parse(response.body);

      List<Chapter> chapterList = [];

      var q2 = parsedHtml.querySelectorAll(_chapterNameQuery);
      // Query3: Gets chapter list
      var q3 = parsedHtml.querySelectorAll(_baseChapterListQuery);
      // Query4: Gets synopsis
      var q4 = parsedHtml.querySelector(_mangaSynopsisQuery);

      var isarInstance = Isar.getInstance('isarInstance');

      // Get chapter list

      try {
        final allManga = isarInstance?.mangas;
        // check if manga already exists
        final _manga = await allManga!
            .where()
            .mangaNameExtensionSourceEqualTo(manga.mangaName, name)
            .findAll();

        for (int x = 0; x < q3.length; x++) {
          print(q2[x].text);
          var chapterName = q2[x].text;
          var chapterLink = q3[x].attributes['href']!;

          var isRead = _manga.isNotEmpty
              ? (x < _manga[0].chapters.length
                  ? _manga[0].chapters[x].isRead
                  : false)
              : false;

          final nChap = Chapter()
            ..name = chapterName.trim()
            ..link = chapterLink.trim()
            ..isRead = isRead;
          chapterList.add(nChap);
        }

        Manga updatedManga = manga.copyWith(
          synopsis: q4?.text.trim() ?? "",
          chapters: chapterList,
          id: _manga.isNotEmpty ? _manga[0].id : null,
          inLibrary: _manga.isNotEmpty ? _manga[0].inLibrary : null,
        );

        await isarInstance?.writeTxn(() async {
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
      // return manga;
    }
  }

  // TODO: IMPLEMENT SORT AND FILTER
  @override
  getMangaList(int pageKey, {String searchQuery = ""}) async {
    try {
      var url;
      // if (searchQuery.isEmpty) {
      //   url = Uri.https(_baseUrl, "", {'page': "$pageKey"});
      // } else {
      //   url = Uri.https(_baseUrl, "/page?$pageKey", {'s': searchQuery});
      // }
      url = Uri.https(_baseUrl, baseSourceExplore, {'page': "$pageKey"});
      var response = await http.get(url);
      var parsedHtml = parse(response.body);
      List<Manga> mangaList = [];

      // Query1: gets title and link
      var q1 = parsedHtml.querySelectorAll(_mangaListQuery);

      for (int x = 0; x < q1.length; x++) {
        var title = q1[x].nextElementSibling!.text;
        var mangaLink = q1[x].attributes['href'];
        var mangaCover = q1[x].children[0].attributes['src'];

        Manga m = Manga(
          extensionSource: name.trim(),
          mangaName: title.trim(),
          mangaCover: mangaCover!.trim(),
          mangaLink: mangaLink!.trim(),
        );

        mangaList.add(m);
      }

      return mangaList;
    } catch (e) {
      var logger = Logger();

      logger.e(e);
    }
  }

  @override
  String get iconUrl => "https://reaperscans.com/images/logo-reaper-2.png";

  @override
  String get name => "Reaper Scans";
}
