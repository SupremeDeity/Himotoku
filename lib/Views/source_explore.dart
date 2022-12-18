import 'package:flutter/material.dart';
import 'package:himotoku/Sources/Source.dart';
import 'package:himotoku/Widgets/SourceExplore/MangaGridView.dart';

class SourceExplore extends StatefulWidget {
  const SourceExplore(this.source, {Key? key}) : super(key: key);

  final Source source;

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
                  delegate: CustomSearchClass(widget.source),
                );
              },
              icon: const Icon(Icons.search))
        ],
        title: Text(
          widget.source.name,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Sort",
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: ((bc) => StatefulBuilder(
                  builder: ((context, setModalState) => Scaffold(
                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        centerTitle: true,
                        title: Text("Sort"),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            DropdownButton(
                              value: "latest",
                              items: [
                                DropdownMenuItem(
                                    child: Text("Latest"), value: "latest"),
                                DropdownMenuItem(
                                    child: Text("Popular"), value: "popular"),
                              ],
                              onChanged: (v) {},
                            )
                          ],
                        ),
                      ))),
                )),
          );
        },
        child: Icon(Icons.sort_sharp),
      ),
      body: MangaGridView(widget.source),
    );
  }
}

class CustomSearchClass extends SearchDelegate {
  var results = [];

  CustomSearchClass(this.source);

  Source source;

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
            source,
            searchQuery: query,
          )
        : Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
