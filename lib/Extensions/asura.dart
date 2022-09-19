import 'package:isar/isar.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Asura extends Extension {
  final _baseChapterListQuery = "#chapterlist .eph-num a";
  final _baseUrl = "asurascans.com";
  final _chapterPageListQuery = "p > img";
  final _defaultSort = "/manga";
  final _mangaAuthorQuery = ".fmed span";
  final _mangaListQuery = ".listupd .bs a"; // base query to get manga list
  final _mangaStatusQuery = ".imptdt i";
  final _mangaSynopsisQuery = "div ~ p";

  @override
  String get baseUrl => "https://www.asurascans.com/";

  @override
  getChapterPageList(String startLink, int pageKey) async {
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
      print(e);
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

      var isarInstance = Isar.getInstance('mangaInstance');

      Manga updatedManga = Manga(
        extensionSource: name,
        mangaName: manga.mangaName,
        mangaCover: manga.mangaCover,
        mangaLink: manga.mangaLink,
      );

      if (q1[1].previousElementSibling?.text == "Author") {
        updatedManga.setAuthorName = q1[1].text;
      }
      if (q1[1].previousElementSibling?.text == "Artist") {
        updatedManga.setMangaStudio = q1[2].text;
      }

      updatedManga.setSynopsis = q4?.text ?? "";

      updatedManga.setStatus = q2[0].text;

      // Get chapter list
      print("Chapters: ${q3.length}");
      for (int x = 0; x < q3.length; x++) {
        // TODO: IMPLMENT ERROR CATCH FOR NULL HERE
        var chapterName = q3[x].children[0].text;
        var chapterLink = q3[x].attributes['href']!;

        final nChap = Chapter()
          ..name = chapterName
          ..link = chapterLink;

        chapterList.add(nChap);
      }
      updatedManga.setChapters = chapterList;

      try {
        final allManga = isarInstance?.mangas;
        // check if manga already exists
        final _manga = await allManga!
            .where()
            .mangaNameExtensionSourceEqualTo(manga.mangaName, name)
            .findAll();

        isarInstance?.writeTxn(() async {
          if (_manga.isNotEmpty) {
            updatedManga.id = _manga[0].id;
          }
          allManga.put(updatedManga);
        });
      } catch (e) {
        print(e);
      }

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
      var q1 = parsedHtml.querySelectorAll(_mangaListQuery);
      // Query2: gets cover art
      var q2 = parsedHtml.querySelectorAll("$_mangaListQuery img");

      for (int x = 0; x < q1.length; x++) {
        // TODO: IMPLMENT ERROR CATCH FOR NULL HERE
        var title = q1[x].attributes['title'];
        var mangaLink = q1[x].attributes['href'];
        var mangaCover = q2[x].attributes['src'];

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
  String get iconUrl =>
      "https://www.asurascans.com/wp-content/uploads/2021/03/Group_1.png";

  @override
  String get name => "Asura Scans";
}
