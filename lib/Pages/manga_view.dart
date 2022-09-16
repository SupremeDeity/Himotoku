import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/ExtensionHelper.dart';
import 'package:yomu/Extensions/asura.dart';

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

  initGetManga() async {
    var box = await Hive.openBox<Manga>('mangaBox');
    Manga m = box.get(
            '${widget.mangaInstance.extensionSource}-${widget.mangaInstance.mangaName}') ??
        await ExtensionsMap[widget.mangaInstance.extensionSource]!
            .getMangaDetails(widget.mangaInstance);

    setState(() {
      manga = m;
    });
  }

  @override
  void initState() {
    initGetManga();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {},
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: manga != null
            ? Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.black45,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    const Divider(
                                      thickness: 3,
                                    ),
                                    Text(
                                      "${manga!.authorName}\n${manga!.mangaStudio}",
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
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
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.library_add_rounded),
                                ),
                                const Text("Add to library")
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      launchUrl(
                                        Uri.parse(manga!.mangaLink),
                                      );
                                    },
                                    icon: const Icon(Icons.open_in_browser)),
                                const Text("Open in browser")
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                  ),
                  Text("Chapters: ${manga!.chapters.length}"),
                  const Divider(
                    thickness: 2,
                  ),
                  Expanded(
                    child: ListView(
                      children: List.generate(
                          manga!.chapters.length,
                          (index) => ListTile(
                                title: Text(manga!.chapters[index].name),
                                dense: true,
                                contentPadding: EdgeInsets.all(10),
                                onTap: () => print(manga!.chapters[index].link),
                              )),
                    ),
                  )
                ],
              )
            : Text("Loading"),
      ),
    );
  }
}
