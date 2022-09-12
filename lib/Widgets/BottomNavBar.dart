import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yomu/Routes/route.gr.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar(this.index, {Key? key}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    // Routes
    const routes = [
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
      onTap: (itemIndex) =>
          {AutoRouter.of(context).navigate(routes[itemIndex])},
    );
  }
}
