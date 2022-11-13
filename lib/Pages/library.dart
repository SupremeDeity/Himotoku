// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:yomu/Data/Constants.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Data/Setting.dart';
import 'package:yomu/Pages/explore.dart';
import 'package:yomu/Widgets/BottomNavBar.dart';
import 'package:yomu/Widgets/Library/ComfortableTile.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  StreamSubscription<void>? cancelSubscription;
  var isarInstance = Isar.getInstance(ISAR_INSTANCE_NAME);
  List<Manga> mangaInLibrary = [];
  LibrarySort sortSettings = LibrarySort.az;
  FilterOptions? filterOptions;

  @override
  void dispose() {
    cancelSubscription!.cancel();
    super.dispose();
  }

  updateSettings() async {
    var settings = await isarInstance?.settings.get(0);
    setState(() {
      sortSettings =
          settings != null ? settings.sortSettings : DEFAULT_LIBRARY_SORT;
      filterOptions =
          settings != null ? settings.filterOptions : FilterOptions();
    });
    getLibrary();
  }

  @override
  void initState() {
    Stream<void> instanceChanged =
        isarInstance!.mangas.watchLazy(fireImmediately: true);
    cancelSubscription = instanceChanged.listen((event) {
      updateSettings();
    });

    super.initState();
  }

  getLibrary() async {
    var inLibrary = isarInstance!.mangas
        .filter()
        .inLibraryEqualTo(true)
        .optional(filterOptions?.started == true,
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

            await isarInstance!.writeTxn(() async {
              var settings = await isarInstance!.settings.get(0);
              await isarInstance!.settings
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

            await isarInstance!.writeTxn(() async {
              var settings = await isarInstance!.settings.get(0);
              await isarInstance!.settings
                  .put(settings!.copyWith(newSortSettings: sortSettings));
            });
          },
          title: const Text("Status"),
        ),
        // ListTile(
        //   leading: sortSettings == LibrarySort.added
        //       ? const Icon(Icons.arrow_upward)
        //       : (sortSettings == LibrarySort.addedDesc
        //           ? const Icon(Icons.arrow_downward)
        //           : null),
        //   onTap: () {
        //     if (sortSettings == LibrarySort.added) {
        //       sortSettings = LibrarySort.addedDesc;
        //     } else {
        //       sortSettings = LibrarySort.added;
        //     }

        //     // Cause update in modal.
        //     setModalState(() {});
        //     // Update library.
        //     getLibrary();
        //   },
        //   title: const Text("Added"),
        // )
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
            await isarInstance!.writeTxn(() async {
              var settings = await isarInstance!.settings.get(0);
              await isarInstance!.settings.put(settings!.copyWith(
                  newFilterOptions:
                      settings.filterOptions.copyWith(newStarted: value)));
            });
          },
          title: const Text("Started"),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
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
                        bottom: const TabBar(
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
          child: const Icon(Icons.filter_list_rounded)),
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Library"),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: CustomSearchClass(filterOptions!));
            },
            icon: const Icon(Icons.search),
          )
        ],
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const BottomNavBar(0),
      body: mangaInLibrary.isNotEmpty
          ? GridView.builder(
              itemCount: mangaInLibrary.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 2 / 3,
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ComfortableTile(mangaInLibrary[index]),
                );
              },
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
                                  .pushReplacement(PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const Explore(),
                                      transitionDuration:
                                          const Duration(milliseconds: 0))),
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
  var isarInstance = Isar.getInstance(ISAR_INSTANCE_NAME);
  var results = [];
  FilterOptions filterCondition;

  CustomSearchClass(this.filterCondition);

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
      results = isarInstance!.mangas
          .filter()
          .inLibraryEqualTo(true)
          .optional(filterCondition.started == true,
              (query) => query.chaptersElement((q) => q.isReadEqualTo(true)))
          .mangaNameContains(query, caseSensitive: false)
          .findAllSync();
    }
  }
}
