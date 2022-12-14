import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Sources/Source.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:collection/collection.dart';

class ReaperScans extends Source {
  final baseSourceExplore = "/comics";

  final _baseChapterListQuery = "a[href*=\"chapter-\"].transition.block";
  final _baseUrl = "reaperscans.com";
  final _chapterNameQuery = "p.truncate";
  final _chapterPageListQuery = "img.display-block";
  // final _mangaAuthorQuery = ".summary-content"; -> Disabled
  final _mangaListQuery =
      "a[href*=\"comic\"].transition.relative"; // base query to get manga list

  final _mangaStatusQuery = ".whitespace-nowrap.text-neutral-200";
  final _mangaSynopsisQuery = ".prose";

  @override
  String get baseUrl => _baseUrl;

  @override
  Future<List<String>> getChapterPageList(String startLink) async {
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

      var q2 = parsedHtml.querySelectorAll(_chapterNameQuery);
      // Query3: Gets chapter list
      var q3 = parsedHtml.querySelectorAll(_baseChapterListQuery);
      // Query4: Gets synopsis
      var q4 = parsedHtml.querySelector(_mangaSynopsisQuery);
      var q5 = parsedHtml.querySelectorAll(_mangaStatusQuery);

      // Get chapter list

      final allManga = isarDB.mangas;

      for (int x = 0; x < q3.length; x++) {
        var chapterName = q2[x].text;
        var chapterLink = q3[x].attributes['href']!;

        Chapter? chapterInMangaLib = manga.chapters.firstWhereOrNull(
            (element) =>
                element.name == chapterName || element.link == chapterLink);
        if (chapterInMangaLib != null) continue;

        var isRead =
            chapterInMangaLib != null ? chapterInMangaLib.isRead : false;

        final nChap = Chapter()
          ..name = chapterName
          ..link = chapterLink
          ..isRead = isRead;
        manga.chapters.add(nChap);
      }

      Manga updatedManga = manga.copyWith(
          synopsis: q4?.text.trim() ?? "",
          id: manga.id,
          inLibrary: manga.inLibrary,
          status: q5[1].text.trim());

      await isarDB.writeTxn(() async {
        await allManga.put(updatedManga);
      });

      return updatedManga;
    } catch (e) {
      return Future.error(e);
    }
  }

  // TODO: IMPLEMENT SORT AND FILTER
  @override
  Future<List<Manga>> getMangaList(int pageKey,
      {String searchQuery = ""}) async {
    try {
      if (searchQuery.isNotEmpty) {
        throw APP_ERROR.SOURCE_SEARCH_NOT_SUPPORTED;
      }
      Uri url;

      url = Uri.https(_baseUrl, baseSourceExplore, {'page': "$pageKey"});
      var response = await http.get(url).onError(
          (error, stackTrace) => Future.error(APP_ERROR.SOURCE_HOST_ERROR));
      var parsedHtml = parse(response.body);
      List<Manga> mangaList = [];

      // Query1: gets title and link
      var q1 = parsedHtml.querySelectorAll(_mangaListQuery);

      for (int x = 0; x < q1.length; x++) {
        var title = q1[x].nextElementSibling!.text;
        var mangaLink = q1[x].attributes['href'];
        var mangaCover = q1[x].children[0].attributes['src'];

        Manga m = Manga(
          source: name.trim(),
          mangaName: title.trim(),
          mangaCover: mangaCover!.trim(),
          mangaLink: mangaLink!.trim(),
        );

        mangaList.add(m);
      }

      return mangaList;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  String get iconUrl => "https://reaperscans.com/images/logo-reaper-2.png";

  @override
  String get name => "Reaper Scans";

  @override
  List<String>? getSortOptions() {
    // TODO: implement getSortOptions
    throw UnimplementedError();
  }
}
