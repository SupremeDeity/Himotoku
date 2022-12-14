import 'package:flutter/material.dart';
import 'package:himotoku/Views/RouteBuilder.dart';
import 'package:himotoku/Views/Settings/settings-about.dart';
import 'package:himotoku/Views/Settings/settings-backup.dart';
import 'package:himotoku/Views/Settings/settings-reader.dart';
import 'package:himotoku/Views/Settings/settings-theme.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map<String, dynamic> settingsMap = const {
    "Appearance": [Icons.palette, SettingsTheme()],
    "Reader": [Icons.menu_book_rounded, ReaderSettings()],
    "Backup": [Icons.backup_outlined, ImportExportSettings()],
    "About": [Icons.info_outline_rounded, SettingsAbout()],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
          children: List.generate(
        settingsMap.length,
        (index) => ListTile(
          onTap: () {
            Navigator.of(context)
                .push(createRoute(settingsMap.values.elementAt(index)[1]));
          },
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            settingsMap.keys.elementAt(index),
          ),
          leading: Icon(
            settingsMap.values.elementAt(index)[0],
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      )),
    );
  }
}
