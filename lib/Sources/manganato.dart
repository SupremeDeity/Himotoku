import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Sources/Source.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Manganato extends Source {
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

      // Query1: gets author, status
      var q1 = parsedHtml.querySelectorAll(_mangaAuthorQuery);
      var q2 = parsedHtml.querySelectorAll(_baseChapterListQuery);
      var q3 = parsedHtml.querySelector(_mangaSynopsisQuery);

      final allManga = isarDB.mangas;

      // Get chapter list
      for (int x = 0; x < q2.length; x++) {
        var chapterName = q2[x].text.trim();
        var chapterLink = q2[x].attributes['href']!;
        var isRead =
            x < manga.chapters.length ? manga.chapters[x].isRead : false;

        final nChap = Chapter()
          ..name = chapterName
          ..link = chapterLink
          ..isRead = isRead;

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
  Future<List<Manga>>? getMangaList(int pageKey,
      {String searchQuery = ""}) async {
    try {
      Uri url;
      if (searchQuery.isEmpty) {
        url = Uri.https(
            _baseUrl, "/advanced_search", {'s': sort, 'page': '$pageKey'});
      } else {
        url = Uri.https(
            _baseUrl,
            "/search/story/${searchQuery.trim().replaceAll(RegExp('[\\s]'), "_")}",
            {'page': '$pageKey'});
      }

      var response = await http.get(url).onError(
          (error, stackTrace) => Future.error(APP_ERROR.SOURCE_HOST_ERROR));
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
  List<String>? getSortOptions() {
    // TODO: implement getSortOptions
    throw UnimplementedError();
  }
}
