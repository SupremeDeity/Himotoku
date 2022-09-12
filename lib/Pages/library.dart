import 'package:flutter/material.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Widgets/BottomNavBar.dart';
import 'package:yomu/Widgets/Library/ComfortableTile.dart';

class Library extends StatelessWidget {
  const Library({Key? key}) : super(key: key);

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
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(10, (index) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            // child: ComfortableTile(Manga("", "", "")),
          );
        }),
      ),
    );
  }
}
