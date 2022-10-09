import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Widgets/BottomNavBar.dart';
import 'package:yomu/Widgets/Library/ComfortableTile.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  List<Manga> mangaInLibrary = [];
  var cancelSubscription;
  var isarInstance = Isar.getInstance('isarInstance');

  getLibrary() async {
    var library =
        await isarInstance!.mangas.where().inLibraryEqualTo(true).findAll();

    setState(() {
      mangaInLibrary = library;
    });
  }

  @override
  void initState() {
    Stream<void> instanceChanged =
        isarInstance!.mangas.watchLazy(fireImmediately: true);
    cancelSubscription = instanceChanged.listen((event) {
      getLibrary();
    });

    super.initState();
  }

  @override
  void dispose() {
    cancelSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Sort & Filter",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                );
              },
            );
          },
          child: Icon(Icons.filter_list_rounded)),
      appBar: AppBar(
        backgroundColor: context.theme.appBarTheme.backgroundColor,
        title: const Text("Library"),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchClass());
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
              itemBuilder: (context, index) {
                return ComfortableTile(mangaInLibrary[index]);
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("(ﾉಥ益ಥ）ﾉ ┻━┻",
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                  Text("You have nothing in your library."),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: "Tip: ",
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        TextSpan(
                          text: "Navigate to ",
                        ),
                        TextSpan(
                          text: "Explore",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: " to add manga to library",
                        )
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class CustomSearchClass extends SearchDelegate {
  var isarInstance = Isar.getInstance('isarInstance');
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

  getResults() {
    if (query.isNotEmpty) {
      results.clear();
      results = isarInstance!.mangas
          .filter()
          .inLibraryEqualTo(true)
          .mangaNameContains(query, caseSensitive: false)
          .findAllSync();
    }
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
}
