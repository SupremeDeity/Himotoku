import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/Manga.dart';
import 'package:himotoku/Sources/Source.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Asura extends Source {
  final _baseChapterListQuery = "#chapterlist .eph-num a";
  final _baseUrl = "asura.gg";
  final _chapterPageListQuery = "#readerarea img:not(.asurascans)";
  final _defaultSort = "/manga";
  final _mangaAuthorQuery = ".fmed span";
  final _mangaListQuery = ".listupd .bs a"; // base query to get manga list
  final _mangaStatusQuery = ".imptdt i";
  final _mangaSynopsisQuery = "div[itemprop=\"description\"]";

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
      if (kDebugMode) {
        var logger = Logger();

        logger.e(e);
      }
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

      // Query1: gets author, artist
      var q1 = parsedHtml.querySelectorAll(_mangaAuthorQuery);
      // Query2: gets status
      var q2 = parsedHtml.querySelectorAll(_mangaStatusQuery);
      // Query3: Gets chapter list
      var q3 = parsedHtml.querySelectorAll(_baseChapterListQuery);
      // Query4: Gets synopsis
      var q4 = parsedHtml.querySelector(_mangaSynopsisQuery);

      var isarInstance = Isar.getInstance(ISAR_INSTANCE_NAME);

      try {
        final allManga = isarInstance!.mangas;
        for (int x = 0; x < q3.length; x++) {
          var chapterName = q3[x].children[0].text.trim();
          var chapterLink = q3[x].attributes['href']!;

          var isRead =
              x < manga.chapters.length ? manga.chapters[x].isRead : false;

          final nChap = Chapter()
            ..name = chapterName
            ..link = chapterLink
            ..isRead = isRead;
          chapterList.add(nChap);
        }
        Manga updatedManga = manga.copyWith(
          authorName: q1[1].previousElementSibling?.text.trim() == "Author"
              ? q1[1].text.trim()
              : null,
          mangaStudio: q1[2].previousElementSibling?.text.trim() == "Artist"
              ? q1[2].text.trim()
              : null,
          synopsis: q4?.text.trim() ?? "",
          status: q2[0].text.trim(),
          chapters: chapterList,
          id: manga.id,
          inLibrary: manga.inLibrary,
        );

        await isarInstance.writeTxn(() async {
          await allManga.put(updatedManga);
        });
        return updatedManga;
      } catch (e) {
        if (kDebugMode) {
          var logger = Logger();

          logger.e(e);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        var logger = Logger();

        logger.e(e);
      }
    }
  }

  @override
  getMangaList(int pageKey, {String searchQuery = ""}) async {
    try {
      Uri url;
      if (searchQuery.isEmpty) {
        url = Uri.https(_baseUrl, _defaultSort, {'page': "$pageKey"});
      } else {
        url = Uri.https(_baseUrl, "/page/$pageKey", {'s': searchQuery});
      }
      var response = await http.get(url);
      var parsedHtml = parse(response.body);
      List<Manga> mangaList = [];

      // Query1: gets title and link
      var q1 = parsedHtml.querySelectorAll(_mangaListQuery);
      // Query2: gets cover art
      var q2 = parsedHtml.querySelectorAll("$_mangaListQuery img");

      for (int x = 0; x < q1.length; x++) {
        var title = q1[x].attributes['title'];
        var mangaLink = q1[x].attributes['href'];
        var mangaCover = q2[x].attributes['src'];

        Manga m = Manga(
            source: name,
            mangaName: title!,
            mangaCover: mangaCover!,
            mangaLink: mangaLink!);

        mangaList.add(m);
      }

      return mangaList;
    } catch (e) {
      if (kDebugMode) {
        var logger = Logger();

        logger.e(e);
      }
    }
  }

  @override
  String get iconUrl =>
      "https://asura.gg/wp-content/uploads/2021/03/Group_1.png";

  @override
  String get name => "Asura Scans";
}
