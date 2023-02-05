// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Widgets/MangaView/MangaDetailsHeader.dart';
import 'package:himotoku/Views/RouteBuilder.dart';
import 'package:isar/isar.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Sources/SourceHelper.dart';
import 'package:himotoku/Widgets/Reader/ChapterListView.dart';

class MangaView extends StatefulWidget {
  const MangaView(this.mangaInstance, {Key? key}) : super(key: key);

  final Manga mangaInstance;

  @override
  _MangaViewState createState() => _MangaViewState();
}

class _MangaViewState extends State<MangaView> {
  // FIXME
  // field to accomodate a somewhat temporary fix for updating chapter list
  int causeUpdate = 0;

  Manga? manga;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    initGetManga();

    // Somewhat temporary fix to update chapter list after pressing back button
    isarDB.mangas.watchLazy().listen((event) {
      if (mounted) {
        setState(() {
          causeUpdate += 1;
        });
      }
    });

    super.initState();
  }

  initGetManga() async {
    var libmanga = await isarDB.mangas
        .where()
        .mangaLinkEqualTo(widget.mangaInstance.mangaLink)
        .findFirst();
    if (libmanga == null) {
      {
        libmanga = await SourcesMap[widget.mangaInstance.source]!
            .getMangaDetails(widget.mangaInstance);
      }
    }

    setState(() {
      manga = libmanga;
    });
  }

  Column ChapterListItem(int index, BuildContext context) {
    return Column(
      children: [
        ListTile(
            onTap: () {
              Navigator.of(context)
                  .push(createRoute(ChapterListView(manga!, index - 1)))
                  .then((value) {
                if (value != null) {
                  var error = "Error occured while fetching page.";

                  if (value == APP_ERROR.CHAPTER_NO_PAGES) {
                    error = "No pages found.";
                  }

                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      duration: Duration(milliseconds: 2300),
                      content: Text(
                        error,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ));
                }
              });
            },
            title: Text(
              manga!.chapters[index - 1].name!,
              style: TextStyle(
                color: manga!.chapters[index - 1].isRead
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.primary,
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: manga != null
          ? RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                try {
                  Manga? m =
                      await SourcesMap[manga!.source]!.getMangaDetails(manga!);

                  setState(() {
                    manga = m;
                  });
                } catch (e) {
                  if (e == APP_ERROR.SOURCE_HOST_ERROR) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error trying to fetch host.")));
                  }
                }
              },
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: manga!.chapters.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return MangaDetailsHeader(manga!);
                  } else {
                    return ChapterListItem(index, context);
                  }
                },
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
    );
  }
}
