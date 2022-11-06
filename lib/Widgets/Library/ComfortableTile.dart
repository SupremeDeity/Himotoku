import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Pages/manga_view.dart';

class ComfortableTile extends StatelessWidget {
  const ComfortableTile(this.manga, {Key? key}) : super(key: key);

  final Manga manga;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.to(() => MangaView(manga), transition: Transition.noTransition);
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
