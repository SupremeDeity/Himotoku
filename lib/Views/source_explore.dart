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
  String orderBy = "";
  String typeBy = "";
  String statusBy = "";
  // ! use bool for genre exclusion
  Map<String, bool> genreBy = {};

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
                  builder: ((modalContext, setModalState) => Scaffold(
                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        title: Text("Filter and Sort"),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FilledButton(
                                onPressed: () {
                                  // ? As long as state changes, the page auto reloads
                                  setState(() {});

                                  Navigator.of(modalContext).pop();
                                },
                                child: Text("Submit")),
                          )
                        ],
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: ListView(
                            children: [
                              if (widget
                                  .source.orderBySortOptions.values.isNotEmpty)
                                ListTile(
                                  leading: Text(
                                    "Sort by:",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing: DropdownButton(
                                    value: orderBy.isNotEmpty
                                        ? orderBy
                                        : widget
                                            .source.orderBySortOptions.values
                                            .elementAt(0),
                                    items: List.generate(
                                        widget.source.orderBySortOptions.length,
                                        (index) => DropdownMenuItem(
                                            child: Text(widget
                                                .source.orderBySortOptions.keys
                                                .elementAt(index)),
                                            value: widget.source
                                                .orderBySortOptions.values
                                                .elementAt(index))),
                                    onChanged: (v) {
                                      orderBy = v ?? "";
                                      setModalState(() {});
                                    },
                                  ),
                                ),
                              if (widget
                                  .source.statusSortOptions.values.isNotEmpty)
                                ListTile(
                                  leading: Text(
                                    "Status:",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing: DropdownButton(
                                    value: statusBy.isNotEmpty
                                        ? statusBy
                                        : widget.source.statusSortOptions.values
                                            .elementAt(0),
                                    items: List.generate(
                                        widget.source.statusSortOptions.length,
                                        (index) => DropdownMenuItem(
                                            child: Text(widget
                                                .source.statusSortOptions.keys
                                                .elementAt(index)),
                                            value: widget
                                                .source.statusSortOptions.values
                                                .elementAt(index))),
                                    onChanged: (v) {
                                      statusBy = v ?? "";
                                      setModalState(() {});
                                    },
                                  ),
                                ),
                              if (widget
                                  .source.typeSortOptions.values.isNotEmpty)
                                ListTile(
                                  leading: Text(
                                    "Type:",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing: DropdownButton(
                                    value: typeBy.isNotEmpty
                                        ? typeBy
                                        : widget.source.typeSortOptions.values
                                            .elementAt(0),
                                    items: List.generate(
                                        widget.source.typeSortOptions.length,
                                        (index) => DropdownMenuItem(
                                            child: Text(widget
                                                .source.typeSortOptions.keys
                                                .elementAt(index)),
                                            value: widget
                                                .source.typeSortOptions.values
                                                .elementAt(index))),
                                    onChanged: (v) {
                                      typeBy = v ?? "";
                                      setModalState(() {});
                                    },
                                  ),
                                ),
                              if (widget.source.genreSortOptions.isNotEmpty)
                                ExpansionTile(
                                  title: Text("Genres"),
                                  children: [
                                    ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: widget
                                            .source.genreSortOptions.length,
                                        itemBuilder: (context, index) {
                                          var genreName = widget
                                              .source.genreSortOptions.keys
                                              .elementAt(index);
                                          return CheckboxListTile(
                                            value: genreBy[genreName] ?? false,
                                            onChanged: (value) {
                                              if (value ?? false) {
                                                genreBy[genreName] = true;
                                              } else {
                                                genreBy.remove(genreName);
                                              }

                                              setModalState(() {});
                                              debugPrint("$genreBy");
                                            },
                                            title: Text(genreName),
                                          );
                                        }),
                                  ],
                                )
                            ],
                          ),
                        ),
                      ))),
                )),
          );
        },
        child: Icon(Icons.sort_sharp),
      ),
      body: MangaGridView(
        widget.source,
        orderBy: orderBy,
        statusBy: statusBy,
        typeBy: typeBy,
        genreBy: genreBy.keys.toList(),
      ),
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
