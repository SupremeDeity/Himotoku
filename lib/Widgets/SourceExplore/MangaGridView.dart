// ignore_for_file: , non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';
import 'package:himotoku/Data/Manga.dart';
import 'package:himotoku/Sources/Source.dart';
import 'package:himotoku/Widgets/Library/ComfortableTile.dart';

class MangaGridView extends StatefulWidget {
  const MangaGridView(this.source, {Key? key, this.searchQuery = ""})
      : super(key: key);

  final Source source;

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
    try {
      List<Manga>? newItems = await widget.source
          .getMangaList(pageKey, searchQuery: widget.searchQuery);
      if (newItems != null) {
        final isLastPage = newItems.length < 1;

        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(newItems, nextPageKey.toInt());
        }
      } else {
        _pagingController.nextPageKey = null;
      }
    } catch (error) {
      _pagingController.error = error;
      Logger logger = Logger();
      logger.e(error);
      if (error == APP_ERROR.SOURCE_SEARCH_NOT_SUPPORTED) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Search is currently not supported by this source.")));
      }
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
        itemBuilder: (context, item, index) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: ComfortableTile(item),
        ),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 2 / 3),
    );
  }
}
