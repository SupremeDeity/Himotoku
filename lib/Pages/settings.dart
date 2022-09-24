import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yomu/Pages/Settings/settings-theme.dart';
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
              Get.to(() => SettingsTheme());
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
