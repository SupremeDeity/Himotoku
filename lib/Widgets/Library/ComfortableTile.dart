// ignore_for_file:

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:himotoku/Data/Constants.dart';
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
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: widget.manga.mangaCover,
            memCacheWidth: 512,
            cacheManager: CacheManager(Config(
                // TODO(SupremeDeity): Do something about this
                widget.cacheImage ? MTILE_CACHE_KEY : "tempMangaTileWidget",
                stalePeriod: widget.cacheImage
                    ? Duration(days: 30)
                    : Duration(seconds: 0))),
          ),
        ),
      ),
    );
  }
}
