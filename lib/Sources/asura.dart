import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/time_util.dart';
import 'package:himotoku/Sources/Source.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Asura extends Source {
  final _baseChapterListQuery = "#chapterlist .eph-num a";
  final _baseUrl = "asurascans.com";
  final _chapterPageListQuery = "#readerarea img:not(.asurascans)";
  final _mangaAuthorQuery = ".fmed span";
  final _mangaListQuery = ".listupd .bs a"; // base query to get manga list
  final _mangaStatusQuery = ".imptdt i";
  final _mangaSynopsisQuery = "div[itemprop=\"description\"]";
  final _mangaGenresQuery = ".mgen > a";

  @override
  String get baseUrl => _baseUrl;

  @override
  Future<List<String>>? getChapterPageList(String startLink) async {
    try {
      var url = Uri.parse(startLink);

      var response = await http
          .get(url)
          .onError((error, stackTrace) => throw APP_ERROR.SOURCE_HOST_ERROR);

      var parsedHtml = parse(response.body);

      List<String> pageList = [];

      // Query1: gets author, artist
      var q1 = parsedHtml.querySelectorAll(_chapterPageListQuery);

      for (int x = 0; x < q1.length; x++) {
        pageList.add(q1[x].attributes['src']!);
      }

      return pageList;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<Manga>? getMangaDetails(Manga manga) async {
    try {
      var url = Uri.parse(manga.mangaLink);

      var response = await http
          .get(url)
          .onError((error, stackTrace) => throw APP_ERROR.SOURCE_HOST_ERROR);
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
      // Query4: Gets genres
      var q5 = parsedHtml.querySelectorAll(_mangaGenresQuery);

      final allManga = isarDB.mangas;
      for (int x = 0; x < q3.length; x++) {
        var chapterName = q3[x].children[0].text.trim();
        DateTime? chapterReleaseDate =
            DateNormalize(q3[x].children[1].text.trim(), "MMMM dd, yyyy");
        var chapterLink = q3[x].attributes['href']!;

        var isRead =
            x < manga.chapters.length ? manga.chapters[x].isRead : false;

        final nChap = Chapter()
          ..name = chapterName
          ..link = chapterLink
          ..isRead = isRead
          ..releaseDate = chapterReleaseDate;

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
        genres: q5.map((e) => e.text.trim()).toList(),
      );

      await isarDB.writeTxn(() async {
        await allManga.put(updatedManga);
      });
      return updatedManga;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<List<Manga>>? getMangaList(
    int pageKey, {
    String searchQuery = "",
    String orderBy = "",
    String statusBy = "",
    String typesBy = "",
    Map<String, bool> genresBy = const {},
  }) async {
    try {
      Uri url;
      if (searchQuery.isEmpty ||
          statusBy.isEmpty ||
          typesBy.isEmpty ||
          orderBy.isEmpty) {
        url = Uri.https(_baseUrl, "/manga", {
          'page': "$pageKey",
          "order": orderBy,
          "status": statusBy,
          "type": typesBy,
          "genre[]": genresBy.entries
              .where((element) => element.value)
              .map((e) => genreSortOptions[e.key])
              .toList()
        });
      } else {
        url = Uri.https(_baseUrl, "/page/$pageKey", {'s': searchQuery});
      }

      var response = await http
          .get(url)
          .onError((error, stackTrace) => throw APP_ERROR.SOURCE_HOST_ERROR);
      var parsedHtml = parse(response.body);
      List<Manga> mangaList = [];

      // Query1: gets title and link
      var q1 = parsedHtml.querySelectorAll(_mangaListQuery);
      // Query2: gets cover art
      var q2 = parsedHtml.querySelectorAll("$_mangaListQuery img");

      // ? sample code to print all filters and values
      // var q3 = parsedHtml.querySelectorAll(".dropdown-menu.c4.genrez li");
      // for (int x = 0; x < q3.length; x++) {
      //   debugPrint(
      //       "'${q3[x].text.trim()}': '${q3[x].firstChild?.attributes['value']}',");
      // }

      for (int x = 0; x < q1.length; x++) {
        var title = q1[x].attributes['title'];
        var mangaLink = q1[x].attributes['href'];
        var mangaCover = q2[x].attributes['src'];

        Manga m = Manga(
          source: name,
          mangaName: title!,
          mangaCover: mangaCover!,
          mangaLink: mangaLink!,
        );

        mangaList.add(m);
      }

      return mangaList;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  String get iconUrl =>
      "https://asurascans.com/wp-content/uploads/2021/03/Group_1.png";

  @override
  String get name => "Asura Scans";

  @override
  Map<String, String> orderBySortOptions = {
    "Default": "default",
    "A-Z": "title",
    "Z-A": "titlereverse",
    "Update": "update",
    "Added": "latest",
    "Popular": "popular",
  };

  @override
  Map<String, String> typeSortOptions = {
    "All": "",
    "Manga": "manga",
    "Manhwa": "manhwa",
    "Manhua": "manhua",
    "Comic": "comic",
    "Novel": "novel",
  };

  @override
  Map<String, String> statusSortOptions = {
    "All": "",
    "Ongoing": "ongoing",
    "Completed": "completed",
    "Hiatus": "hiatus",
    "Dropped": "dropped",
    "Coming Soon": "coming soon",
  };

  @override
  Map<String, String> genreSortOptions = {
    'Action': 'action',
    'Adaptation': 'adaptation',
    'Adult': 'adult',
    'Adventure': 'adventure',
    'Another chance': 'another-chance',
    'apocalypse': 'apocalypse',
    'Comedy': 'comedy',
    'Coming Soon': 'coming-soon',
    'Cultivation': 'cultivation',
    'Demon': 'demon',
    'Discord': 'discord',
    'Drama': 'drama',
    'Dungeons': 'dungeons',
    'Ecchi': 'ecchi',
    'Fantasy': 'fantasy',
    'Game': 'game',
    'Genius': 'genius',
    'Genius MC': 'genius-mc',
    'Harem': 'harem',
    'Hero': 'hero',
    'Historical': 'historical',
    'Isekai': 'isekai',
    'Josei': 'josei',
    'Kool Kids': 'kool-kids',
    'Loli': 'loli',
    'Magic': 'magic',
    'Martial Arts': 'martial-arts',
    'Mature': 'mature',
    'Mecha': 'mecha',
    'Modern Setting': 'modern-setting',
    'Monsters': 'monsters',
    'Murim': 'murim',
    'Mystery': 'mystery',
    'Necromancer': 'necromancer',
    'Noble': 'noble',
    'Overpowered': 'overpowered',
    'Pets': 'pets',
    'Post-Apocalyptic': 'post-apocalyptic',
    'Psychological': 'psychological',
    'Rebirth': 'rebirth',
    'Regression': 'regression',
    'Reincarnation': 'reincarnation',
    'Return': 'return',
    'Returned': 'returned',
    'Returner': 'returner',
    'Revenge': 'revenge',
    'Romance': 'romance',
    'School Life': 'school-life',
    'Sci-fi': 'sci-fi',
    'Seinen': 'seinen',
    'Shoujo': 'shoujo',
    'Shounen': 'shounen',
    'Slice of Life': 'slice-of-life',
    'Sports': 'sports',
    'Super Hero': 'super-hero',
    'Superhero': 'superhero',
    'Supernatural': 'supernatural',
    'Survival': 'survival',
    'Suspense': 'suspense',
    'System': 'system',
    'Thriller': 'thriller',
    'Time Travel': 'time-travel',
    'Time Travel (Future)': 'time-travel-future',
    'tower': 'tower',
    'Tragedy': 'tragedy',
    'Video Game': 'video-game',
    'Video Games': 'video-games',
    'Villain': 'villain',
    'Virtual Game': 'virtual-game',
    'Virtual Reality': 'virtual-reality',
    'Virtual World': 'virtual-world',
    'Webtoon': 'webtoon',
    'Wuxia': 'wuxia',
  };
}
