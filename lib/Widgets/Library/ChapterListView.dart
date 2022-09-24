import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/ExtensionHelper.dart';

class ChapterListView extends StatefulWidget {
  ChapterListView(this.manga, this.chapterIndex, {Key? key}) : super(key: key);

  Manga manga;
  int chapterIndex;

  @override
  State<ChapterListView> createState() => _ChapterListViewState();
}

class _ChapterListViewState extends State<ChapterListView> {
  final PagingController<int, String> _pagingController =
      PagingController(firstPageKey: 0);
  final _scrollController = ScrollController();
  List<String> pages = [];
  var isarInstance = Isar.getInstance('mangaInstance');

  bool isRead = false;
  bool isFocused = false;
  double maxScrollExtent = 1000;
  double CurrentScrollExtent = 0;

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

  setReadStatus() async {
    setState(() {
      isRead = true;
    });
    await isarInstance!.writeTxn(() {
      widget.manga.chapters[widget.chapterIndex].isRead = true;
      return isarInstance!.mangas.put(widget.manga);
    });
  }

  @override
  void initState() {
    setState(() {
      isRead = widget.manga.chapters[widget.chapterIndex].isRead;
    });

    getPages();

    _pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });

    _scrollController.addListener(() {
      setState(() {
        maxScrollExtent = _scrollController.position.maxScrollExtent;
        CurrentScrollExtent = _scrollController.offset;
      });
      if (!isRead) {
        if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 800) {
          setReadStatus();
        }
      }
    });

    super.initState();
  }

  Future<void> fetchPage(int pageKey) async {
    try {
      final newItems = [pages[pageKey]];

      final isLastPage = pageKey + 1 >= pages.length;

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey.toInt());
      }
    } catch (error) {
      _pagingController.error = error;
      var logger = Logger();
      logger.e(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages.isNotEmpty
          ? GestureDetector(
              onTap: () {
                if (!isFocused) {
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                } else {
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                }
                setState(() {
                  isFocused = !isFocused;
                });
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PagedListView<int, String>(
                    cacheExtent: 200,
                    // primary: true,
                    shrinkWrap: true,
                    pagingController: _pagingController,
                    scrollController: _scrollController,
                    builderDelegate: PagedChildBuilderDelegate<String>(
                      itemBuilder: (context, item, index) => CachedNetworkImage(
                        httpHeaders: {
                          "Referer":
                              // ExtensionsMap[widget.manga.extensionSource]!.baseUrl.con
                              widget.manga.mangaLink
                        },
                        imageUrl: item,
                        filterQuality: FilterQuality.medium,
                        errorWidget: (context, url, error) {
                          return Text("Error: $error");
                        },
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, progress) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 200),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.progress,
                                color: context.theme.colorScheme.secondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  isFocused
                      ? SafeArea(
                          bottom: true,
                          left: false,
                          right: false,
                          top: true,
                          child: SizedBox(
                            height: 60,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              color: context
                                  .theme.colorScheme.secondaryContainer
                                  .withAlpha(200),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        iconSize: 50,
                                        // color: context.theme.colorScheme
                                        // .onSecondaryContainer,
                                        onPressed: widget.chapterIndex <
                                                widget.manga.chapters.length - 1
                                            ? () {
                                                Get.off(
                                                    () => ChapterListView(
                                                        widget.manga,
                                                        widget.chapterIndex +
                                                            1),
                                                    transition:
                                                        Transition.noTransition,
                                                    preventDuplicates: false);
                                              }
                                            : null,
                                        icon: const Icon(
                                          Icons.arrow_left,
                                        )),
                                    SizedBox(
                                      height: 30,
                                      width: 200,
                                      child: Slider.adaptive(
                                        value: CurrentScrollExtent,
                                        onChanged: (value) {
                                          setState(() {
                                            CurrentScrollExtent = value;
                                          });
                                        },
                                        min: 0,
                                        max: maxScrollExtent,
                                      ),
                                    ),
                                    IconButton(
                                        iconSize: 50,
                                        color: context.theme.colorScheme
                                            .onSecondaryContainer,
                                        onPressed: widget.chapterIndex > 0
                                            ? () {
                                                Get.off(
                                                    () => ChapterListView(
                                                        widget.manga,
                                                        widget.chapterIndex -
                                                            1),
                                                    transition:
                                                        Transition.noTransition,
                                                    preventDuplicates: false);
                                              }
                                            : null,
                                        icon: const Icon(
                                          Icons.arrow_right,
                                        )),
                                  ]),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(
              color: context.theme.colorScheme.secondary,
            )),
    );
  }
}
