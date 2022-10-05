import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:yomu/Widgets/Library/ComfortableTile.dart';

class MangaGridView extends StatefulWidget {
  MangaGridView(this.extension, this.pagingController,
      {Key? key, this.searchQuery = ""})
      : super(key: key);

  final Extension extension;
  PagingController<int, Manga> pagingController;
  String searchQuery;

  @override
  State<MangaGridView> createState() => _MangaGridViewState();
}

class _MangaGridViewState extends State<MangaGridView> {
  @override
  void initState() {
    widget.pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> fetchPage(int pageKey) async {
    Logger logger = Logger();
    try {
      final newItems = await widget.extension
          .getMangaList(pageKey, searchQuery: widget.searchQuery);
      final isLastPage = newItems.length < 1;

      if (isLastPage) {
        widget.pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        widget.pagingController.appendPage(newItems, nextPageKey.toInt());
      }
    } catch (error) {
      widget.pagingController.error = error;

      logger.e(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.searchQuery.isEmpty
        ? RefreshIndicator(
            onRefresh: () {
              return Future.sync(() => widget.pagingController.refresh());
            },
            child: MangaGrid(),
          )
        : MangaGrid();
  }

  PagedGridView<int, Manga> MangaGrid() {
    return PagedGridView<int, Manga>(
      shrinkWrap: true,
      pagingController: widget.pagingController,
      builderDelegate: PagedChildBuilderDelegate<Manga>(
        itemBuilder: (context, item, index) => ComfortableTile(item),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
    );
  }
}
