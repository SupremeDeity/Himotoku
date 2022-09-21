import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Routes/route.gr.dart';

class ComfortableTile extends StatelessWidget {
  const ComfortableTile(this.manga, {Key? key}) : super(key: key);

  final Manga manga;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(MangaView(mangaInstance: manga));
      },
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Image(
              image: CachedNetworkImageProvider(manga.mangaCover),
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.all(5),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black54,
              ),
              child: Text(
                manga.mangaName,
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
    );
  }
}
