// ignore_for_file:

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/Manga.dart';
import 'package:himotoku/Pages/RouteBuilder.dart';
import 'package:himotoku/Pages/manga_view.dart';

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
        child: Stack(
          children: [
            SizedBox.expand(
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                transformAlignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(4),
                width: double.infinity,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [
                      0.2,
                      0.4,
                      0.6,
                      0.8,
                      1.0
                    ],
                        colors: [
                      Colors.black,
                      Colors.black87,
                      Colors.black54,
                      Colors.black38,
                      Colors.transparent
                    ])),
                child: Text(
                  widget.manga.mangaName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
