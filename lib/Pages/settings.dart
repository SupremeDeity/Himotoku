import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yomu/Pages/Settings/settings-theme.dart';
import 'package:yomu/Routes/route.gr.dart';
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
      body: ListView(
        children: [
          ListTile(
            onTap: () {
            },
            contentPadding: const EdgeInsets.all(12),
            title: const Text("Theme"),
            leading: const Icon(Icons.style),
          ),
        ],
      ),
    );
  }
}
