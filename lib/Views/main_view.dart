import 'package:flutter/material.dart';
import 'package:himotoku/Views/explore.dart';
import 'package:himotoku/Views/library.dart';
import 'package:himotoku/Views/settings.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  var _currentIndex = 0;
  var routes = const [
    Library(),
    Explore(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(children: routes, index: _currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
        ],
        currentIndex: _currentIndex,
        onTap: (itemIndex) {
          if (itemIndex != _currentIndex) {
            setState(() {
              _currentIndex = itemIndex;
            });
          }
        },
      ),
    );
  }
}
