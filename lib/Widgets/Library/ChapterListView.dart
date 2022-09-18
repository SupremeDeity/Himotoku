import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  bool isFocused = false;
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> fetchPage(int pageKey) async {
    try {
      // final newItems = await ExtensionsMap[widget.manga.extensionSource]!
      //     .getChapterPageList(
      //         widget.manga.chapters[widget.chapterIndex + pageKey].link,
      //         pageKey);
      // final isLastPage = newItems.length < 1;

      // if (isLastPage) {
      //   _pagingController.appendLastPage(newItems);
      // } else {
      //   final nextPageKey = pageKey + 1;
      //   _pagingController.appendPage(newItems, nextPageKey.toInt());
      // }

      // ONLY ONE CHAPTER
      //TODO: FIX THIS LOL
      final newItems = await ExtensionsMap[widget.manga.extensionSource]!
          .getChapterPageList(
              widget.manga.chapters[widget.chapterIndex].link, pageKey);
      _pagingController.appendLastPage(newItems);
    } catch (error) {
      _pagingController.error = error;
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
      body: GestureDetector(
        onTap: () => setState(() {
          isFocused = !isFocused;
        }),
        child: PagedListView<int, String>(
          cacheExtent: 200,
          primary: true,
          shrinkWrap: true,
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<String>(
            itemBuilder: (context, item, index) => CachedNetworkImage(
              httpHeaders: {
                "Referer": ExtensionsMap[widget.manga.extensionSource]!.baseUrl
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
      ),
    );
  }
}
