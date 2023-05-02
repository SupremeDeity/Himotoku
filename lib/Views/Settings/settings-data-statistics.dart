// ignore_for_file:

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Data/models/Setting.dart';
import 'package:isar/isar.dart';

class DataStatisticsSettings extends StatefulWidget {
  const DataStatisticsSettings({Key? key}) : super(key: key);

  @override
  _DataStatisticsSettingsState createState() => _DataStatisticsSettingsState();
}

class _DataStatisticsSettingsState extends State<DataStatisticsSettings> {
  StreamSubscription<void>? cancelSubscription;
  int databaseSize = 0;
  int cachedSize = 0;
  int miscSize = 0;
  int totalEntries = 0;
  int libraryEntries = 0;
  int nonLibraryEntries = 0;
  int miscEntries = 0;

  @override
  void dispose() {
    cancelSubscription!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    try {
      Stream<void> mangasChanged =
          isarDB.mangas.watchLazy(fireImmediately: true);
      cancelSubscription = mangasChanged.listen((event) async {
        calculateStats();
      });
    } catch (e) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data and Statistics")),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 12.0),
          child: Row(
            children: [
              Text(
                "Statistics",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          dense: true,
          title: Text(
            "Database Size",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            sizeConvert(databaseSize),
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        ListTile(
          dense: true,
          title: Text(
            "Cached Size",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            sizeConvert(cachedSize),
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          trailing: Text(
            "(Includes non-library comics)",
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        ListTile(
          dense: true,
          title: Text(
            "Misc Size",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            sizeConvert(miscSize),
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        ListTile(
          dense: true,
          title: Text(
            "Total Cached Entries",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${totalEntries}",
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          trailing: Text(
            "(Library + Non-Library)",
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        ListTile(
          dense: true,
          title: Text(
            "Library Entries",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${libraryEntries}",
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        ListTile(
          dense: true,
          title: Text(
            "Non-Library Entries",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "$nonLibraryEntries",
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 12.0),
          child: Row(
            children: [
              Text(
                "Actions",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          onTap: () {
            clearNonLibraryEntry();
          },
          leading: Icon(
            Icons.delete_forever_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            "Clear Non-Library Entries Cache.",
          ),
        ),
      ]),
    );
  }

  clearNonLibraryEntry() async {
    await isarDB.writeTxn(() async {
      await isarDB.mangas.where().inLibraryEqualTo(false).deleteAll();
    });
  }

  String sizeConvert(int size) {
    final int KB = 1024;
    final int MB = 1024 * 1024;
    final int GB = 1024 * 1024 * 1024;

    if (size > GB) return "${size / GB} GB";
    if (size > MB) return "${size / MB} MB";
    if (size > KB) return "${size / KB} KB";
    return "${size} B";
  }

  void calculateStats() {
    setState(() {
      databaseSize =
          isarDB.getSizeSync(includeIndexes: true, includeLinks: true);
      cachedSize =
          isarDB.mangas.getSizeSync(includeIndexes: true, includeLinks: true);
      miscSize =
          isarDB.settings.getSizeSync(includeIndexes: true, includeLinks: true);
      totalEntries = isarDB.mangas.countSync();
      libraryEntries = isarDB.mangas.where().inLibraryEqualTo(true).countSync();
      nonLibraryEntries =
          isarDB.mangas.where().inLibraryEqualTo(false).countSync();
      miscEntries = isarDB.settings.countSync();
    });
  }
}
