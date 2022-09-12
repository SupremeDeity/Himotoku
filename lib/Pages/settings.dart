import 'package:flutter/material.dart';
import 'package:yomu/Widgets/BottomNavBar.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const BottomNavBar(2),
    );
  }
}
