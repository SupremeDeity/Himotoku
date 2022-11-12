// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:yomu/Pages/explore.dart';
import 'package:yomu/Pages/library.dart';
import 'package:yomu/Pages/settings.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar(this.index, {Key? key}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    // Routes
    var routes = const [
      Library(),
      Explore(),
      Settings(),
    ];

    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.book), label: "Library"),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
      ],
      currentIndex: index,
      onTap: (itemIndex) {
        if (itemIndex != index) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => routes[itemIndex],
                transitionDuration: const Duration(milliseconds: 0)),
          );
        }
      },
    );
  }
}
