import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/ExtensionHelper.dart';
import 'package:yomu/Routes/route.gr.dart';

class MangaView extends StatefulWidget {
  const MangaView(this.mangaInstance, {Key? key}) : super(key: key);

  final Manga mangaInstance;

  @override
  _MangaViewState createState() => _MangaViewState();
}

class _MangaViewState extends State<MangaView> {
  Manga? manga;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isInLibrary = false;
  var isarInstance = Isar.getInstance('mangaInstance');

  initGetManga() async {
    var isarInstance = Isar.getInstance('mangaInstance');
    print(isarInstance?.isOpen);
    var mangas = await isarInstance?.mangas
        .where()
        .mangaNameExtensionSourceEqualTo(widget.mangaInstance.mangaName,
            widget.mangaInstance.extensionSource)
        .findAll();
    Manga m = mangas!.isNotEmpty
        ? mangas[0]
        : await ExtensionsMap[widget.mangaInstance.extensionSource]!
            .getMangaDetails(widget.mangaInstance);

    setState(() {
      manga = m;
      isInLibrary = m.inLibrary;
    });
  }

  @override
  void initState() {
    initGetManga();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        Manga m = await ExtensionsMap[widget.mangaInstance.extensionSource]!
            .getMangaDetails(widget.mangaInstance);

        setState(() {
          manga = m;
          isInLibrary = m.inLibrary;
        });
      },
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: Scaffold(
        appBar: AppBar(),
        body: manga != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    dragStartBehavior: DragStartBehavior.start,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      // color: Colors.black45,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CachedNetworkImage(
                                    alignment: Alignment.centerLeft,
                                    imageUrl: manga!.mangaCover),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.mangaInstance.mangaName,
                                        maxLines: 3,
                                        style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${manga!.authorName}\n${manga!.mangaStudio}",
                                                style: const TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        manga!.status,
                                        style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    iconSize: 22,
                                    onPressed: addToLibrary,
                                    icon: Icon(
                                        isInLibrary
                                            ? Icons.library_add
                                            : Icons.library_add_outlined,
                                        color: isInLibrary
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                  ),
                                  Text(
                                    isInLibrary
                                        ? "In Library"
                                        : "Add to library",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                      iconSize: 22,
                                      onPressed: () {
                                        launchUrl(
                                          Uri.parse(manga!.mangaLink),
                                        );
                                      },
                                      icon: const Icon(Icons.open_in_browser)),
                                  const Text(
                                    "Open in browser",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(manga!.synopsis),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${manga!.chapters.length} Chapters",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: List.generate(
                          manga!.chapters.length,
                          (index) => ListTile(
                                title: Text(manga!.chapters[index].name!),
                                dense: true,
                                contentPadding: const EdgeInsets.all(10),
                                onTap: () => AutoRouter.of(context).navigate(
                                    ChapterListView(
                                        manga: manga!, chapterIndex: index)),
                              )),
                    ),
                  )
                ],
              )
            : Center(child: const CircularProgressIndicator()),
      ),
    );
  }

  void addToLibrary() async {
    await isarInstance!.writeTxn(() async {
      manga!.setInLibrary = !manga!.inLibrary;
      await isarInstance!.mangas.put(manga!);
    });
    setState(() {
      isInLibrary = manga!.inLibrary;
    });
  }
}
