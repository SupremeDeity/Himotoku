// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Views/RouteBuilder.dart';
import 'package:himotoku/Sources/SourceHelper.dart';
import 'package:isar/isar.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/models/Setting.dart';
import 'package:himotoku/Views/explore.dart';
import 'package:himotoku/Widgets/Library/ComfortableTile.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  StreamSubscription<void>? cancelSubscription;
  FilterOptions? filterOptions;
  List<Manga> mangaInLibrary = [];
  LibrarySort sortSettings = LibrarySort.az;

  @override
  void dispose() {
    cancelSubscription!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    Stream<void> instanceChanged =
        isarDB.mangas.watchLazy(fireImmediately: true);
    cancelSubscription = instanceChanged.listen((event) {
      updateSettings();
    });

    super.initState();
  }

  updateSettings() async {
    var settings = await isarDB.settings.get(0);
    setState(() {
      sortSettings =
          settings != null ? settings.sortSettings : DEFAULT_LIBRARY_SORT;
      filterOptions =
          settings != null ? settings.filterOptions : FilterOptions();
    });
    getLibrary();
  }

  getLibrary() async {
    var inLibrary = isarDB.mangas.filter().inLibraryEqualTo(true).optional(
        filterOptions?.started == true,
        (query) => query.chaptersElement((q) => q.isReadEqualTo(true)));

    QueryBuilder<Manga, Manga, QAfterSortBy>? sortQuery;
    List<Manga> library = [];

    switch (sortSettings) {
      case LibrarySort.az:
        sortQuery = inLibrary.sortByMangaName();
        break;
      case LibrarySort.za:
        sortQuery = inLibrary.sortByMangaNameDesc();
        break;
      case LibrarySort.status:
        sortQuery = inLibrary.sortByStatus();
        break;
      case LibrarySort.statusDesc:
        sortQuery = inLibrary.sortByStatusDesc();
        break;
    }

    library = await sortQuery.findAll();
    setState(() {
      mangaInLibrary = library;
    });
  }

  ListView SortTab(StateSetter setModalState) {
    return ListView(
      children: [
        ListTile(
          leading: sortSettings == LibrarySort.az
              ? const Icon(Icons.arrow_upward)
              : (sortSettings == LibrarySort.za
                  ? const Icon(Icons.arrow_downward)
                  : null),
          title: const Text("Alphabetically"),
          onTap: () async {
            if (sortSettings == LibrarySort.az) {
              sortSettings = LibrarySort.za;
            } else {
              sortSettings = LibrarySort.az;
            }

            // Cause update in modal.
            setModalState(() {});

            // Update library.
            getLibrary();

            await isarDB.writeTxn(() async {
              var settings = await isarDB.settings.get(0);
              await isarDB.settings
                  .put(settings!.copyWith(newSortSettings: sortSettings));
            });
          },
        ),
        ListTile(
          leading: sortSettings == LibrarySort.status
              ? const Icon(Icons.arrow_upward)
              : (sortSettings == LibrarySort.statusDesc
                  ? const Icon(Icons.arrow_downward)
                  : null),
          onTap: () async {
            if (sortSettings == LibrarySort.status) {
              sortSettings = LibrarySort.statusDesc;
            } else {
              sortSettings = LibrarySort.status;
            }

            // Cause update in modal.
            setModalState(() {});
            // Update library.
            getLibrary();

            await isarDB.writeTxn(() async {
              var settings = await isarDB.settings.get(0);
              await isarDB.settings
                  .put(settings!.copyWith(newSortSettings: sortSettings));
            });
          },
          title: const Text("Status"),
        ),
      ],
    );
  }

  ListView FilterTab(StateSetter setModalState) {
    return ListView(
      children: [
        CheckboxListTile(
          value: filterOptions?.started,
          onChanged: (value) async {
            setModalState(() {
              filterOptions?.started = value!;
            });
            getLibrary();
            await isarDB.writeTxn(() async {
              var settings = await isarDB.settings.get(0);
              await isarDB.settings.put(settings!.copyWith(
                  newFilterOptions:
                      settings.filterOptions.copyWith(newStarted: value)));
            });
          },
          title: const Text("Started"),
        )
      ],
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      title: const Text("Library"),
      actions: [
        IconButton(
          onPressed: () {
            showSearch(
                context: context, delegate: CustomSearchClass(filterOptions!));
          },
          icon: const Icon(Icons.search),
        )
      ],
      automaticallyImplyLeading: false,
    );
  }

  FloatingActionButton filterFloatingButton(BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Theme.of(context).colorScheme.background,
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) => DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: AppBar(
                      primary: false,
                      toolbarHeight: 0,
                      automaticallyImplyLeading: false,
                      bottom: TabBar(
                        labelColor: Theme.of(context).colorScheme.onBackground,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        tabs: [
                          Tab(
                            text: "Sort",
                          ),
                          Tab(
                            text: "Filter",
                          )
                        ],
                      ),
                    ),
                    body: TabBarView(children: [
                      SortTab(setModalState),
                      FilterTab(setModalState),
                    ]),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.filter_list_rounded));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: filterFloatingButton(context),
      appBar: appBar(context),
      body: mangaInLibrary.isNotEmpty
          ? RefreshIndicator(
              onRefresh: () async {
                for (Manga manga in mangaInLibrary) {
                  await SourcesMap[manga.source]!.getMangaDetails(manga);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
              },
              child: GridView.builder(
                itemCount: mangaInLibrary.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 2 / 3,
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ComfortableTile(
                      mangaInLibrary[index],
                      cacheImage: true,
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("(ﾉಥ益ಥ）ﾉ ┻━┻",
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                  const Text("You have nothing in your library."),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Navigate to "),
                          TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacement(createRoute(Explore())),
                              child: const Text("Explore")),
                          const Text("to add to your library.")
                        ],
                      )),
                ],
              ),
            ),
    );
  }
}

class CustomSearchClass extends SearchDelegate {
  CustomSearchClass(this.filterCondition);

  FilterOptions filterCondition;
  var results = [];

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
        ? GridView.builder(
            itemCount: results.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemBuilder: (context, index) {
              return ComfortableTile(results[index]);
            },
          )
        : Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    getResults();
    return query.isNotEmpty
        ? GridView.builder(
            itemCount: results.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemBuilder: (context, index) {
              return ComfortableTile(results[index]);
            },
          )
        : Container();
  }

  getResults() {
    if (query.isNotEmpty) {
      results.clear();
      results = isarDB.mangas
          .filter()
          .inLibraryEqualTo(true)
          .optional(filterCondition.started == true,
              (query) => query.chaptersElement((q) => q.isReadEqualTo(true)))
          .mangaNameContains(query, caseSensitive: false)
          .findAllSync();
    }
  }
}
