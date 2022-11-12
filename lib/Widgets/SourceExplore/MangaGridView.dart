// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:yomu/Widgets/Library/ComfortableTile.dart';

class MangaGridView extends StatefulWidget {
  const MangaGridView(this.extension, {Key? key, this.searchQuery = ""})
      : super(key: key);

  final Extension extension;

  final String searchQuery;

  @override
  State<MangaGridView> createState() => _MangaGridViewState();
}

class _MangaGridViewState extends State<MangaGridView> {
  final PagingController<int, Manga> _pagingController =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
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
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey.toInt());
      }
    } catch (error) {
      _pagingController.error = error;

      logger.e(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.searchQuery.isEmpty
        ? RefreshIndicator(
            onRefresh: () {
              return Future.sync(() => _pagingController.refresh());
            },
            child: MangaGrid(),
          )
        : MangaGrid();
  }

  PagedGridView<int, Manga> MangaGrid() {
    return PagedGridView<int, Manga>(
      shrinkWrap: true,
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Manga>(
        itemBuilder: (context, item, index) => ComfortableTile(item),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
    );
  }
}
