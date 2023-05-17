import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/time_util.dart';
import 'package:himotoku/Sources/Source.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Manganato extends Source {
  final _baseChapterListQuery = ".chapter-name";
  final _baseUrl = "manganato.com";
  final String _chapterPageListQuery = ".container-chapter-reader > img";
  final _mangaMetadataQuery = ".table-value";
  final _mangaListQuery = ".genres-item-img"; // base query to get manga list
  final _mangaSynopsisQuery = "#panel-story-info-description";

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
        var chapterName = q2[x].text.trim();
        var chapterLink = q2[x].attributes['href']!;
        var isRead =
            x < manga.chapters.length ? manga.chapters[x].isRead : false;
        DateTime? chapterReleaseDate = DateNormalize(
            q2[x].nextElementSibling?.nextElementSibling?.text ?? "",
            "MMM dd,yy");

        final nChap = Chapter()
          ..name = chapterName
          ..link = chapterLink
          ..isRead = isRead
          ..releaseDate = chapterReleaseDate;

        chapterList.add(nChap);
      }

      // Note: Manganato does not have "Artist/Studio"
      Manga updatedManga = manga.copyWith(
        chapters: chapterList,
        authorName: q1[1].text.trim(),
        status: q1[2].text.trim(),
        synopsis: q3!.text.replaceFirst(r"Description :", "").trim(),
        id: manga.id,
        inLibrary: manga.inLibrary,
        genres: q1[3].text.trim().split(" - "),
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

      String g_i = "";
      String g_e = "";
      for (var entry in genresBy.entries) {
        if (entry.value) {
          g_i += "_" + genreSortOptions[entry.key]!;
        }
        if (!entry.value) {
          g_e += "_" + genreSortOptions[entry.key]!;
        }
      }

      url = Uri.https(_baseUrl, "/advanced_search", {
        'orby': orderBy,
        'sts': statusBy,
        'page': '$pageKey',
        'keyw': searchQuery.trim().replaceAll(RegExp("\\s+"), "_"),
        'g_i': g_i,
        'g_e': g_e,
      });

      var response = await http.get(url).onError(
          (error, stackTrace) => Future.error(APP_ERROR.SOURCE_HOST_ERROR));
      var parsedHtml = parse(response.body);
      List<Manga> mangaList = [];

      // Query1: gets title and link

      var q1 = parsedHtml.querySelectorAll(_mangaListQuery);

      // var q2 =
      //     parsedHtml.querySelectorAll(".advanced-search-tool-genres-list span");
      // for (var span in q2) {
      //   debugPrint("'${span.text}': '${span.attributes['data-i']}',");
      // }

      for (int x = 0; x < q1.length; x++) {
        var title = q1[x].attributes['title'];
        var mangaLink = q1[x].attributes['href'];

        var mangaCover = q1[x].children[0].attributes['src'];

        Manga m = Manga(
            source: name,
            mangaName: title!,
            mangaCover: mangaCover!,
            mangaLink: mangaLink!);

        mangaList.add(m);
      }

      return mangaList;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  String get iconUrl => "https://manganato.com/themes/hm/images/logo.png";

  @override
  String get name => "Manganato";

  @override
  Map<String, String> get orderBySortOptions => {
        "Latest": "latest",
        "Top View": "topview",
        "New": "newest",
        "A-Z": "az",
      };
  @override
  Map<String, String> get statusSortOptions => {
        "Ongoing and Complete": "",
        "Ongoing": "ongoing",
        "Complete": "completed",
      };

  @override
  Map<String, String> get genreSortOptions => {
        'Action': '2',
        'Adult': '3',
        'Adventure': '4',
        'Comedy': '6',
        'Cooking': '7',
        'Doujinshi': '9',
        'Drama': '10',
        'Ecchi': '11',
        'Erotica': '48',
        'Fantasy': '12',
        'Gender bender': '13',
        'Harem': '14',
        'Historical': '15',
        'Horror': '16',
        'Isekai': '45',
        'Josei': '17',
        'Manhua': '44',
        'Manhwa': '43',
        'Martial arts': '19',
        'Mature': '20',
        'Mecha': '21',
        'Medical': '22',
        'Mystery': '24',
        'One shot': '25',
        'Pornographic': '47',
        'Psychological': '26',
        'Romance': '27',
        'School life': '28',
        'Sci fi': '29',
        'Seinen': '30',
        'Shoujo': '31',
        'Shoujo ai': '32',
        'Shounen': '33',
        'Shounen ai': '34',
        'Slice of life': '35',
        'Smut': '36',
        'Sports': '37',
        'Supernatural': '38',
        'Tragedy': '39',
        'Webtoons': '40',
        'Yaoi': '41',
        'Yuri': '42',
      };
}
