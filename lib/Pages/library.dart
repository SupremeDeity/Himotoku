import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Widgets/BottomNavBar.dart';
import 'package:yomu/Widgets/Library/ComfortableTile.dart';
import 'package:yomu/Widgets/Library/MangaGridView.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  List<Manga> mangaInLibrary = [];
  var isarInstance = Isar.getInstance('mangaInstance');

  getLibrary() async {
    var library =
        await isarInstance!.mangas.where().inLibraryEqualTo(true).findAll();

    setState(() {
      mangaInLibrary = library;
    });
  }

  @override
  void initState() {
    getLibrary();
    Stream<void> instanceChanged = isarInstance!.mangas.watchLazy();
    instanceChanged.listen((event) {
      getLibrary();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library"),
        actions: [
          IconButton(
            onPressed: () {}, // TODO: Add search functionality
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
                children: [
                  Text(
                      ["(ﾉಥ益ಥ）ﾉ ┻━┻", "ಠ_ಠ", "¯\\_(ツ)_/¯"]
                          .elementAt(Random().nextInt(3)),
                      style: const TextStyle(
                          fontSize: 35, fontWeight: FontWeight.bold)),
                  const Text("You have nothing in your library."),
                  const Padding(
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
