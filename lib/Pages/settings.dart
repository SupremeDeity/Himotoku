import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yomu/Pages/Settings/settings-backup.dart';
import 'package:yomu/Pages/Settings/settings-reader.dart';
import 'package:yomu/Pages/Settings/settings-theme.dart';
import 'package:yomu/Widgets/BottomNavBar.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  final Map<String, dynamic> settingsMap = const {
    "Appearance": [Icons.palette, SettingsTheme()],
    "Reader": [Icons.menu_book_rounded, ReaderSettings()],
    "Backup": [Icons.backup_outlined, ImportExportSettings()],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const BottomNavBar(2),
      body: ListView(
          children: List.generate(
        settingsMap.length,
        (index) => ListTile(
          onTap: () {
            Get.to(settingsMap.values.elementAt(index)[1],
                transition: Transition.noTransition);
          },
          contentPadding: const EdgeInsets.all(12),
          title: Text(settingsMap.keys.elementAt(index)),
          leading: Icon(settingsMap.values.elementAt(index)[0]),
        ),
      )),
    );
  }
}
