import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Data/Setting.dart';
import 'package:yomu/Extensions/ExtensionHelper.dart';

class ChapterListView extends StatefulWidget {
  ChapterListView(this.manga, this.chapterIndex, {Key? key}) : super(key: key);

  int chapterIndex;
  Manga manga;

  @override
  State<ChapterListView> createState() => _ChapterListViewState();
}

class _ChapterListViewState extends State<ChapterListView> {
  bool isFocused = false;
  bool isRead = false;
  var isarInstance = Isar.getInstance('isarInstance')!;
  List<String> pages = [];
  bool fullscreen = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void initState() {
    updateSettings();
    // Check if page is already read.
    setState(() {
      isRead = widget.manga.chapters[widget.chapterIndex].isRead;
    });

    // Get all page links chapter.
    getPages();

    _scrollController.addListener(() {
      if (!isRead) {
        if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 800) {
          setChapterAsRead();
        }
      }
    });

    super.initState();
  }

  updateSettings() async {
    var settings = await isarInstance.settings.get(0);
    setState(() {
      fullscreen = settings!.fullscreen;
    });
    if (fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  getPages() async {
    try {
      final newItems = await ExtensionsMap[widget.manga.extensionSource]!
          .getChapterPageList(widget.manga.chapters[widget.chapterIndex].link!);
      setState(() {
        pages = newItems;
      });
    } catch (e) {
      var logger = Logger();

      logger.e(e);
    }
  }

  setChapterAsRead() async {
    setState(() {
      isRead = true;
    });
    await isarInstance.writeTxn(() {
      widget.manga.chapters[widget.chapterIndex].isRead = true;
      return isarInstance.mangas.put(widget.manga);
    });
  }

  setCurrentScroll(double value) {
    _scrollController.jumpTo(value);
  }

  CachedNetworkImage ChapterPage(int index) {
    return CachedNetworkImage(
      httpHeaders: {"Referer": widget.manga.mangaLink},
      imageUrl: pages[index],
      filterQuality: FilterQuality.medium,
      errorWidget: (context, url, error) {
        return Text("Error: $error");
      },
      progressIndicatorBuilder: (context, url, progress) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 200,
          ),
          child: Center(
            child: CircularProgressIndicator(
              value: progress.progress,
              color: context.theme.colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }

  Container HeaderView(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      // Note: SafeArea not used to avoid giving a empty invisible gap at the top
      height: MediaQuery.of(context).viewPadding.top + 60,
      width: double.infinity,
      color: context.theme.colorScheme.primary,
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.manga.chapters[widget.chapterIndex].name ?? "Unknown",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container FooterView(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.primary.withAlpha(220),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton.icon(
            label: Text("Prev"),
            onPressed: widget.chapterIndex < widget.manga.chapters.length - 1
                ? () {
                    Get.off(
                      () => ChapterListView(
                          widget.manga, widget.chapterIndex + 1),
                      transition: Transition.noTransition,
                      preventDuplicates: false,
                    );
                  }
                : null,
            icon: const Icon(
              size: 30,
              Icons.skip_previous_rounded,
            )),
        ElevatedButton.icon(
            label: Text("Next"),
            // color: context.theme.colorScheme
            //     .onSecondaryContainer,
            onPressed: widget.chapterIndex > 0
                ? () {
                    Get.off(
                        () => ChapterListView(
                            widget.manga, widget.chapterIndex - 1),
                        transition: Transition.noTransition,
                        preventDuplicates: false);
                  }
                : null,
            icon: const Icon(
              size: 30,
              Icons.skip_next_rounded,
            )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: pages.isNotEmpty
          ? Stack(
              children: [
                GestureDetector(
                    onTap: () {
                      if (fullscreen) {
                        if (!isFocused) {
                          SystemChrome.setEnabledSystemUIMode(
                              SystemUiMode.edgeToEdge);
                        } else {
                          SystemChrome.setEnabledSystemUIMode(
                              SystemUiMode.immersive);
                        }
                      }
                      setState(() {
                        isFocused = !isFocused;
                      });
                    },
                    child: ListView(
                      // cacheExtent: 200,
                      controller: _scrollController,
                      children: List.generate(
                          pages.length, (index) => ChapterPage(index)),
                    )),
                isFocused
                    ? Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: SafeArea(
                          bottom: true,
                          left: false,
                          right: false,
                          top: false,
                          child: FooterView(context),
                        ),
                      )
                    : Container(),
                isFocused ? HeaderView(context) : Container()
              ],
            )
          : Center(
              child: CircularProgressIndicator(
              color: context.theme.colorScheme.secondary,
            )),
    );
  }
}
