import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class ReaperScans extends Extension {
  final baseSourceExplore = "/all-series/comics";

  final _baseChapterListQuery = ".chapter-link";
  final _baseUrl = "reaperscans.com";
  final _chapterPageListQuery = ".reading-content img";
  final _mangaAuthorQuery = ".summary-content";
  final _mangaListQuery =
      "div[id*=\"manga-item-\"] a"; // base query to get manga list

  final _mangaSynopsisQuery = ".summary__content";

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
        pageList.add(q1[x].attributes['data-src']!.trim());
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

      // Query1: gets author, artist
      var q1 = parsedHtml.querySelectorAll(_mangaAuthorQuery);

      // Query3: Gets chapter list
      var q3 = parsedHtml.querySelectorAll("$_baseChapterListQuery a");
      var q5 = parsedHtml.querySelectorAll("$_baseChapterListQuery p");
      // Query4: Gets synopsis
      var q4 = parsedHtml.querySelector(_mangaSynopsisQuery);

      var isarInstance = Isar.getInstance('mangaInstance');

      Manga updatedManga = Manga(
        extensionSource: name,
        mangaName: manga.mangaName,
        mangaCover: manga.mangaCover,
        mangaLink: manga.mangaLink,
      );

      if (q1.length > 4 &&
          q1[3].previousElementSibling!.text.trim() == "Author(s)") {
        updatedManga.setAuthorName = q1[3].text.trim();
      }

      if (q1.length > 4 &&
          q1[3].previousElementSibling!.text.trim() == "Artist(s)") {
        updatedManga.setMangaStudio = q1[4].text.trim();
      }

      if (q1.last.previousElementSibling!.text.trim() == "Status") {
        updatedManga.setStatus = q1.last.text.trim();
      }

      updatedManga.setSynopsis = q4?.text.trim() ?? "";
      // Get chapter list

      try {
        final allManga = isarInstance?.mangas;
        // check if manga already exists
        final _manga = await allManga!
            .where()
            .mangaNameExtensionSourceEqualTo(manga.mangaName, name)
            .findAll();

        for (int x = 0; x < q3.length; x++) {
          var chapterName = q5[x].text.trim();
          var chapterLink = q3[x].attributes['href']!;

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
      // return manga;
    }
  }

  // TODO: IMPLEMENT SORT AND FILTER
  @override
  getMangaList(int pageKey, {String searchQuery = ""}) async {
    try {
      var url;
      if (searchQuery.isEmpty) {
        url = Uri.https(
            _baseUrl, baseSourceExplore, {"m_orderby": "total_views"});
      } else {
        url = Uri.https(_baseUrl, "", {'s': searchQuery});
      }

      var response = await http.get(url);
      bool popular = true;
      var body = {
        "action": "madara_load_more",
        "page": (pageKey).toString(),
        "template": "madara-core/content/content-archive",
        // "vars[orderby]": "post_title",
        // "vars[paged]": "1",
        // "vars[posts_per_page]": "20",
        // "vars[post_type]": "wp-manga",
        // "vars[post_status]": "publish",
        "vars[meta_key]": popular ? "_wp_manga_views" : "_latest_update",
        // "vars[order]": "ASC",
        "vars[sidebar]": popular ? "full" : "right",
        "vars[manga_archives_item_layout]": "big_thumbnail",
        "vars[paged]": "1",
        "vars[orderby]": "meta_value_num",
        // "vars[template]": "archive",
        // "vars[sidebar]": "full",
        "vars[post_type]": "wp-manga",
        "vars[post_status]": "publish",
        "vars[order]": "asc",
        "vars[meta_query][0][key]": "_wp_manga_chapter_type",
        "vars[meta_query][0][value]": "manga"
      };

      var resp2 = await http.post(
          Uri.parse("https://$baseUrl/wp-admin/admin-ajax.php"),
          body: body);
      print(resp2.statusCode);
      print(resp2.headers);

      var parsedHtml2 = parse(resp2.body);

      var parsedHtml = parse(response.body);

      List<Manga> mangaList = [];

      // Query1: gets title and link
      var q1 = parsedHtml.querySelectorAll(_mangaListQuery);
      var qq1 = parsedHtml2.querySelectorAll(_mangaListQuery);

      // Query2: gets cover art
      var q2 = parsedHtml.querySelectorAll("$_mangaListQuery img");
      var qq2 = parsedHtml2.querySelectorAll("$_mangaListQuery img");

      // for (int x = 0; x < q1.length; x++) {
      //   var title = q1[x].attributes['title'];
      //   var mangaLink = q1[x].attributes['href'];
      //   var mangaCover = q2[x].attributes['data-src'];
      //   print("$x: $title");

      //   Manga m = Manga(
      //       extensionSource: name,
      //       mangaName: title!,
      //       mangaCover: mangaCover!,
      //       mangaLink: mangaLink!);

      //   mangaList.add(m);
      // }

      for (int x = 0; x < qq1.length; x++) {
        var title = qq1[x].attributes['title'];
        var mangaLink = qq1[x].attributes['href'];
        var mangaCover = qq2[x].attributes['data-src'];
        print("$x: $title");

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
  String get iconUrl =>
      "https://reaperscans.com/wp-content/uploads/2021/07/logo-reaper-2.png";

  @override
  String get name => "Reaper Scans";
}
