// ignore_for_file:

import 'package:flutter/material.dart';
import 'package:himotoku/Pages/RouteBuilder.dart';
import 'package:himotoku/Pages/explore.dart';
import 'package:himotoku/Pages/library.dart';
import 'package:himotoku/Pages/settings.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar(this.index, {Key? key}) : super(key: key);
  final int index;

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
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
      currentIndex: widget.index,
      onTap: (itemIndex) {
        if (itemIndex != widget.index) {
          Navigator.of(context).pushReplacement(createRoute(routes[itemIndex]));
        }
      },
    );
  }
}
