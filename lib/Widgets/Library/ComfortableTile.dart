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
          footer: GridTileBar(
            backgroundColor: Colors.black38,
            title: Text(
              widget.manga.mangaName,
              maxLines: 2,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          child: widget.cacheImage
              ? CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.manga.mangaCover,
                  memCacheHeight: 512,
                  maxHeightDiskCache: 512,
                )
              : Image.network(
                  widget.manga.mangaCover,
                  width: 512,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
