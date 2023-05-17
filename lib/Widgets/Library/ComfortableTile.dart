// ignore_for_file:

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Views/RouteBuilder.dart';
import 'package:himotoku/Views/manga_view.dart';

class ComfortableTile extends StatefulWidget {
  const ComfortableTile(this.manga, {Key? key, this.cacheImage = false})
      : super(key: key);

  final Manga manga;

  /// Whether to cache cover image.
  final bool cacheImage;

  @override
  _ComfortableTileState createState() => _ComfortableTileState();
}

class _ComfortableTileState extends State<ComfortableTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(createRoute(MangaView(widget.manga)));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GridTile(
          header: widget.manga.inLibrary && widget.manga.unreadCount > 0
              ? Row(children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      "${widget.manga.unreadCount}",
                    ),
                  ),
                ])
              : null,
          footer: GridTileBar(
            backgroundColor: Colors.black38,
            title: Text(
              widget.manga.mangaName,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          child: widget.cacheImage
              ? CachedNetworkImage(
                  httpHeaders: {"Referer": widget.manga.mangaLink},
                  fit: BoxFit.cover,
                  imageUrl: widget.manga.mangaCover,
                  memCacheHeight: 512,
                  maxHeightDiskCache: 512,
                )
              : Image.network(
                  headers: {"Referer": widget.manga.mangaLink},
                  widget.manga.mangaCover,
                  width: 512,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
