// ignore_for_file:

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Pages/manga_view.dart';

class ComfortableTile extends StatefulWidget {
  const ComfortableTile(this.manga, {Key? key}) : super(key: key);

  final Manga manga;

  @override
  _ComfortableTileState createState() => _ComfortableTileState();
}

class _ComfortableTileState extends State<ComfortableTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => MangaView(widget.manga),
        ));
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
