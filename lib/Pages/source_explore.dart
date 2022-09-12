import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:yomu/Widgets/Library/ComfortableTile.dart';
import 'package:yomu/Widgets/Library/MangaView.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(widget.extension),
                );
              },
              icon: const Icon(Icons.search))
        ],
        title: Text(
          widget.extension.getName(),
        ),
      ),
      // TODO: customize refreshindicator
      body: MangaView(widget.extension, _pagingController),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate(this.extension);

  final Extension extension;
  final PagingController<int, Manga> searchPagingController =
      PagingController(firstPageKey: 1);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return MangaView(
      extension,
      searchPagingController,
      searchQuery: query,
    );
    // return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Column();
  }
}
