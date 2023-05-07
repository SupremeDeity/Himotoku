import 'package:flutter/material.dart';
import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/time_util.dart';
import 'package:himotoku/Sources/Source.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class MangaBuddy extends Source {
  final _baseChapterListQuery = ".chapter-list a";
  final _baseUrl = "mangabuddy.com";
  final String _chapterPageListQuery = "#chapter-images img";
  final _mangaMetadataQuery = ".detail .meta.box p";
  final _mangaListQuery = ".book-detailed-item"; // base query to get manga list
  final _mangaSynopsisQuery = ".summary .content";

  @override
  String get baseUrl => _baseUrl;

  @override
  Future<List<String>>? getChapterPageList(String startLink) async {
    try {
      var url = Uri.parse(startLink);

      var response = await http.get(url).onError(
          (error, stackTrace) => Future.error(APP_ERROR.SOURCE_HOST_ERROR));
      var parsedHtml = parse(response.body);

      List<String> pageList = [];

      // Query1: gets author, artist
      var q1 = parsedHtml.querySelectorAll(_chapterPageListQuery);

      // ! mangabuddy and some sources load 2 images and let the rest be lazily
      // ! loaded. We extract the image links directly from a variable which
      // ! contains the links.

      if (response.body.contains("var chapImages = '")) {
        var startString = "var chapImages = '";
        var startIndex = response.body.indexOf(startString);
        var endIndex =
            response.body.indexOf("'", startIndex + startString.length);
        var chapterImagesFromJs = response.body
            .substring(startIndex + startString.length, endIndex)
            .split(',');
        if (q1.length < chapterImagesFromJs.length) {
          pageList = chapterImagesFromJs;
        }
      }
      if (pageList.isEmpty) {
        for (int x = 0; x < q1.length; x++) {
          pageList.add(q1[x].attributes['src']!);
        }
      }

      debugPrint("$pageList");
      return pageList;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<Manga>? getMangaDetails(Manga manga) async {
    try {
      var url = Uri.parse(manga.mangaLink);

      var response = await http.get(url).onError(
          (error, stackTrace) => Future.error(APP_ERROR.SOURCE_HOST_ERROR));
      var parsedHtml = parse(response.body);

      List<Chapter> chapterList = [];

      // Query1: gets author, status, genre
      var q1 = parsedHtml.querySelectorAll(_mangaMetadataQuery);

      var q2 = parsedHtml.querySelectorAll(_baseChapterListQuery);
      var q3 = parsedHtml.querySelector(_mangaSynopsisQuery);

      final allManga = isarDB.mangas;

      // Get chapter list
      for (int x = 0; x < q2.length; x++) {
        var chapterName = q2[x].children[0].children[0].text.trim();
        var chapterLink =
            Uri.https(baseUrl, q2[x].attributes['href']!).toString();
        var isRead =
            x < manga.chapters.length ? manga.chapters[x].isRead : false;
        DateTime? chapterReleaseDate =
            DateNormalize(q2[x].children[0].children[1].text, "MMM dd, yyy");

        final nChap = Chapter()
          ..name = chapterName
          ..link = chapterLink
          ..isRead = isRead
          ..releaseDate = chapterReleaseDate;

        chapterList.add(nChap);
      }

      var authors = q1[0]
          .text
          .replaceAll(RegExp(r'^Authors :|\s+'), " ")
          .replaceAll(RegExp(r' ,'), ",")
          .trim();
      var genres = q1[2]
          .text
          .replaceAll(RegExp(r'^Genres :|\s+'), " ")
          .replaceAll(RegExp(r' ,'), ",")
          .trim()
          .split(", ");
      var status = q1[1].text.replaceAll(RegExp(r'^Status :|\s+'), " ").trim();

      // Note: MangaBuddy does not have "Artist/Studio"
      Manga updatedManga = manga.copyWith(
        chapters: chapterList,
        authorName: authors,
        status: status,
        synopsis: q3!.text.trim(),
        id: manga.id,
        inLibrary: manga.inLibrary,
        genres: genres,
      );

      await isarDB.writeTxn(() async {
        await allManga.put(updatedManga);
      });
      return updatedManga;
    } catch (e) {
      return Future.error(e);
    }
  }

  createGenreList({Map<String, bool> genresBy = const {}}) {
    return genresBy.entries
        .where((element) => element.value)
        .map((e) => genreSortOptions[e.key])
        .toList();
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
      url = Uri.https(_baseUrl, "/search", {
        'page': "$pageKey",
        'q': searchQuery,
        'sort':
            orderBy.isEmpty ? orderBySortOptions.values.elementAt(0) : orderBy,
        'status':
            statusBy.isEmpty ? statusSortOptions.values.elementAt(0) : statusBy,
        'genre[]': createGenreList(genresBy: genresBy)
      });

      var response = await http.get(url).onError(
          (error, stackTrace) => Future.error(APP_ERROR.SOURCE_HOST_ERROR));
      var parsedHtml = parse(response.body);
      List<Manga> mangaList = [];

      // Query1: gets title and link

      var q1 = parsedHtml.querySelectorAll(_mangaListQuery);

      // var q2 = parsedHtml.querySelectorAll(".checkbox__input");
      // for (var span in q2) {
      //   debugPrint(
      //       "'${span.nextElementSibling?.text}': '${span.firstChild?.attributes['value']}',");
      // }

      for (int x = 0; x < q1.length; x++) {
        var title = q1[x].children[1].firstChild?.text;
        var meta = q1[x].firstChild!.firstChild!;
        var mangaLink = Uri.https(baseUrl, meta.attributes['href']!);

        var mangaCover = meta.firstChild!.attributes['data-src']!;

        Manga m = Manga(
            source: name,
            mangaName: title!,
            mangaCover: mangaCover,
            mangaLink: mangaLink.toString());

        mangaList.add(m);
      }

      return mangaList;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  String get iconUrl =>
      "https://mangabuddy.com/static/sites/mangabuddy/icons/apple-touch-icon.png";

  @override
  String get name => "MangaBuddy";

  @override
  Map<String, String> get orderBySortOptions => {
        "Views": "views",
        "Updated": "updated_at",
        "Created": "created_at",
        "Name A-Z": "name",
        "Rating": "rating",
      };
  @override
  Map<String, String> get statusSortOptions => {
        "All": "all",
        "Ongoing": "ongoing",
        "Complete": "completed",
      };

  @override
  Map<String, String> get genreSortOptions => {
        'Action': 'action',
        'Adaptation': 'adaptation',
        'Adult': 'adult',
        'Adventure': 'adventure',
        'Animal': 'animal',
        'Anthology': 'anthology',
        'Cartoon': 'cartoon',
        'Comedy': 'comedy',
        'Comic': 'comic',
        'Cooking': 'cooking',
        'Demons': 'demons',
        'Doujinshi': 'doujinshi',
        'Drama': 'drama',
        'Ecchi': 'ecchi',
        'Fantasy': 'fantasy',
        'Full Color': 'full-color',
        'Game': 'game',
        'Gender bender': 'gender-bender',
        'Ghosts': 'ghosts',
        'Harem': 'harem',
        'Historical': 'historical',
        'Horror': 'horror',
        'Isekai': 'isekai',
        'Josei': 'josei',
        'Long strip': 'long-strip',
        'Mafia': 'mafia',
        'Magic': 'magic',
        'Manga': 'manga',
        'Manhua': 'manhua',
        'Manhwa': 'manhwa',
        'Martial arts': 'martial-arts',
        'Mature': 'mature',
        'Mecha': 'mecha',
        'Medical': 'medical',
        'Military': 'military',
        'Monster': 'monster',
        'Monster girls': 'monster-girls',
        'Monsters': 'monsters',
        'Music': 'music',
        'Mystery': 'mystery',
        'Office': 'office',
        'Office workers': 'office-workers',
        'One shot': 'one-shot',
        'Police': 'police',
        'Psychological': 'psychological',
        'Reincarnation': 'reincarnation',
        'Romance': 'romance',
        'School life': 'school-life',
        'Sci fi': 'sci-fi',
        'Science fiction': 'science-fiction',
        'Seinen': 'seinen',
        'Shoujo': 'shoujo',
        'Shoujo ai': 'shoujo-ai',
        'Shounen': 'shounen',
        'Shounen ai': 'shounen-ai',
        'Slice of life': 'slice-of-life',
        'Smut': 'smut',
        'Soft Yaoi': 'soft-yaoi',
        'Sports': 'sports',
        'Super Power': 'super-power',
        'Superhero': 'superhero',
        'Supernatural': 'supernatural',
        'Thriller': 'thriller',
        'Time travel': 'time-travel',
        'Tragedy': 'tragedy',
        'Vampire': 'vampire',
        'Vampires': 'vampires',
        'Video games': 'video-games',
        'Villainess': 'villainess',
        'Web comic': 'web-comic',
        'Webtoons': 'webtoons',
        'Yaoi': 'yaoi',
        'Yuri': 'yuri',
        'Zombies': 'zombies',
      };
}
