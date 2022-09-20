import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:isar/isar.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/ExtensionHelper.dart';
import 'package:yomu/Routes/route.gr.dart' as routes;

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

  getPages() async {
    try {
      final newItems = await ExtensionsMap[widget.manga.extensionSource]!
          .getChapterPageList(widget.manga.chapters[widget.chapterIndex].link!);
      setState(() {
        pages = newItems;
      });
    } catch (e) {
      print(e);
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
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: isFocused
          ? [
              IconButton(
                  onPressed:
                      widget.chapterIndex < widget.manga.chapters.length - 1
                          ? () {
                              AutoRouter.of(context).popAndPush(
                                  routes.ChapterListView(
                                      manga: widget.manga,
                                      chapterIndex: widget.chapterIndex + 1));
                            }
                          : null,
                  icon: const Icon(
                    Icons.arrow_left,
                    size: 45,
                  )),
              IconButton(
                  onPressed: widget.chapterIndex > 0
                      ? () {
                          AutoRouter.of(context).popAndPush(
                              routes.ChapterListView(
                                  manga: widget.manga,
                                  chapterIndex: widget.chapterIndex - 1));
                        }
                      : null,
                  icon: const Icon(
                    Icons.arrow_right,
                    size: 45,
                  )),
            ]
          : null,
      body: pages.isNotEmpty
          ? GestureDetector(
              onTap: () => setState(() {
                isFocused = !isFocused;
              }),
              child: PagedListView<int, String>(
                cacheExtent: 200,
                // primary: true,
                shrinkWrap: true,
                pagingController: _pagingController,
                scrollController: _scrollController,

                builderDelegate: PagedChildBuilderDelegate<String>(
                  itemBuilder: (context, item, index) => CachedNetworkImage(
                    httpHeaders: {
                      "Referer":
                          ExtensionsMap[widget.manga.extensionSource]!.baseUrl
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
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
