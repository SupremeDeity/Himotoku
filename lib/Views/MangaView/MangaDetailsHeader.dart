import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:url_launcher/url_launcher.dart';

class MangaDetailsHeader extends StatefulWidget {
  MangaDetailsHeader(this.manga, {Key? key}) : super(key: key);
  final Manga manga;
  @override
  _MangaDetailsHeaderState createState() => _MangaDetailsHeaderState();
}

class _MangaDetailsHeaderState extends State<MangaDetailsHeader> {
  // Minimum synopsis length before cutoff.
  var synopsisCutoffMin = 350;

  void addToLibrary() async {
    await isarDB.writeTxn(() async {
      widget.manga.inLibrary = !widget.manga.inLibrary;
      await isarDB.mangas.put(widget.manga);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      // color: Colors.black45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    filterQuality: FilterQuality.medium,
                    alignment: Alignment.centerLeft,
                    imageUrl: widget.manga.mangaCover,
                    memCacheHeight: 512,
                    maxHeightDiskCache: 512,
                  ),
                ),
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
                        widget.manga.mangaName,
                        maxLines: 2,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${widget.manga.authorName}\n${widget.manga.mangaStudio}",
                                maxLines: 2,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.manga.status,
                        maxLines: 1,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.manga.source,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                    isSelected: widget.manga.inLibrary,
                    onPressed: addToLibrary,
                    icon: Icon(
                      Icons.library_add_outlined,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    selectedIcon: Icon(Icons.library_add_check),
                  ),
                  Text(
                    widget.manga.inLibrary ? "In Library" : "Add to Library",
                    style: TextStyle(
                        color: widget.manga.inLibrary
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () => launchUrl(
                        Uri.parse(widget.manga.mangaLink),
                        mode: LaunchMode.externalApplication),
                    icon: Icon(
                      Icons.open_in_browser,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  Text(
                    "Open in browser",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                ],
              )
            ],
          ),
          ExpansionTile(
            title: Text("Description"),
            childrenPadding: const EdgeInsets.all(8.0),
            children: [Text(widget.manga.synopsis)],
            initiallyExpanded: widget.manga.synopsis.length < synopsisCutoffMin,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              textAlign: TextAlign.left,
              "${widget.manga.chapters.length} Chapters",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
