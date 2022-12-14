// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Sources/SourceHelper.dart';
import 'package:himotoku/Views/RouteBuilder.dart';
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
  bool isUpdating = false;

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
    sortAndFilterLibrary();
  }

  sortAndFilterLibrary() async {
    var inLibrary = isarDB.mangas
        .where()
        .inLibraryEqualTo(true)
        .filter()
        .optional(
            filterOptions?.started == true,
            (query) =>
                query.chaptersElement((chapter) => chapter.isReadEqualTo(true)))
        .optional(
            filterOptions?.unread == true,
            (query) => query
                .chaptersElement((chapter) => chapter.isReadEqualTo(false)));

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
      default:
        sortQuery = null;
        break;
      // case LibrarySort.unread:
      //   break;
    }

    library = await sortQuery?.findAll() ?? await inLibrary.findAll();
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
            sortAndFilterLibrary();

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
            // Cause update in modal.
            setModalState(() {
              if (sortSettings == LibrarySort.status) {
                sortSettings = LibrarySort.statusDesc;
              } else {
                sortSettings = LibrarySort.status;
              }
            });
            // Update library.
            sortAndFilterLibrary();

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
            sortAndFilterLibrary();
            await isarDB.writeTxn(() async {
              var settings = await isarDB.settings.get(0);
              await isarDB.settings.put(settings!.copyWith(
                  newFilterOptions:
                      settings.filterOptions.copyWith(newStarted: value)));
            });
          },
          title: const Text("Started"),
        ),
        CheckboxListTile(
          value: filterOptions?.unread,
          onChanged: (value) async {
            setModalState(() {
              filterOptions?.unread = value!;
            });
            sortAndFilterLibrary();
            await isarDB.writeTxn(() async {
              var settings = await isarDB.settings.get(0);
              await isarDB.settings.put(settings!.copyWith(
                  newFilterOptions:
                      settings.filterOptions.copyWith(newUnread: value)));
            });
          },
          title: const Text("Unread"),
        )
      ],
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text("Library"),
      actions: [
        IconButton(
            onPressed: () {},
            icon: Icon(Icons.refresh_rounded),
            tooltip: "Update library"),
        IconButton(
          onPressed: () {
            showSearch(
                context: context, delegate: CustomSearchClass(filterOptions!));
          },
          icon: const Icon(Icons.search),
          tooltip: "Search in library",
        )
      ],
      automaticallyImplyLeading: false,
    );
  }

  FloatingActionButton filterFloatingButton(BuildContext context) {
    return FloatingActionButton(
        tooltip: "Sort and Filter",
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
          ? GridView.builder(
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
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("(?????????????????? ?????????",
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

  @pragma('vm:entry-point')
  static void refreshLibrary() async {
    var mangaInLibrary =
        await isarDB.mangas.where().inLibraryEqualTo(true).findAll();
    int notifID = 1;

    for (int mangaIndex = 0; mangaIndex < mangaInLibrary.length; mangaIndex++) {
      final int progress =
          min(((mangaIndex + 1) / mangaInLibrary.length * 100).round(), 100);

      Manga manga = mangaInLibrary[mangaIndex];

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('library_update', 'Library updates',
              channelDescription:
                  'A channel for displaying library update notifications.',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              showProgress: true,
              maxProgress: 100,
              autoCancel: false,
              category: AndroidNotificationCategory.progress,
              channelShowBadge: false,
              ongoing: true,
              enableVibration: false,
              progress: progress,
              actions: [AndroidNotificationAction("CANCEL", "Cancel")]);
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await FlutterLocalNotificationsPlugin().show(
        notifID,
        'Updating library (${mangaIndex + 1}/${mangaInLibrary.length})',
        manga.mangaName,
        notificationDetails,
      );

      await SourcesMap[manga.source]?.getMangaDetails(manga);
    }

    // setState(() {
    //   isUpdating = false;
    // });
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
