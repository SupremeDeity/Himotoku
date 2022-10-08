import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:yomu/Widgets/SourceExplore/MangaGridView.dart';

class SourceExplore extends StatefulWidget {
  const SourceExplore(this.extension, {Key? key}) : super(key: key);

  final Extension extension;

  @override
  _SourceExploreState createState() => _SourceExploreState();
}

class _SourceExploreState extends State<SourceExplore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchClass(widget.extension),
                );
              },
              icon: const Icon(Icons.search))
        ],
        title: Text(
          widget.extension.name,
        ),
      ),
      body: MangaGridView(widget.extension),
    );
  }
}

class CustomSearchClass extends SearchDelegate {
  var results = [];

  CustomSearchClass(this.extension);

  Extension extension;

  @override
  List<Widget> buildActions(BuildContext context) {
// this will show clear query button
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
  Widget buildLeading(BuildContext context) {
// adding a back button to close the search
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return query.isNotEmpty
        ? MangaGridView(
            extension,
            searchQuery: query,
          )
        : Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
