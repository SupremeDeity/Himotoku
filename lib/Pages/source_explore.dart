import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:yomu/Widgets/Library/ComfortableTile.dart';
import 'package:yomu/Widgets/Library/MangaGridView.dart';

class SourceExplore extends StatefulWidget {
  const SourceExplore(this.extension, {Key? key}) : super(key: key);

  final Extension extension;

  @override
  _SourceExploreState createState() => _SourceExploreState();
}

class _SourceExploreState extends State<SourceExplore> {
  // TODO: maybe allow extra loading using paramater of pagingcontroller
  final PagingController<int, Manga> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void didUpdateWidget(SourceExplore oldWidget) {
    if (oldWidget.extension != widget.extension) {
      _pagingController.refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                // showSearch(
                //   context: context,
                //   delegate: CustomSearchDelegate(widget.extension),
                // );
              },
              icon: const Icon(Icons.search))
        ],
        title: Text(
          widget.extension.getName(),
        ),
      ),
      // TODO: customize refreshindicator
      body: MangaGridView(widget.extension, _pagingController),
    );
  }
}
