// ignore_for_file:

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Setting.dart';
import 'package:himotoku/Data/Theme.dart';

class SettingsTheme extends StatefulWidget {
  const SettingsTheme({Key? key}) : super(key: key);

  @override
  _SettingsThemeState createState() => _SettingsThemeState();
}

class _SettingsThemeState extends State<SettingsTheme> {
  StreamSubscription<void>? cancelSubscription;
  String? theme;

  @override
  void initState() {
    try {
      Stream<void> settingsChanged =
          isarDB.settings.watchObjectLazy(0, fireImmediately: true);
      cancelSubscription = settingsChanged.listen((event) {
        updateSettings();
      });
    } catch (e) {
      log(e.toString());
    }
    super.initState();
  }

  updateSettings() async {
    var settings = await isarDB.settings.get(0);
    setState(() {
      theme = settings!.theme;
    });
  }

  @override
  void dispose() {
    cancelSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Theme")),
      body: ListView(
        children: List.generate(ThemesMap.length, (index) {
          return RadioListTile(
            title: Text(ThemesMap.keys.elementAt(index)),
            activeColor: Theme.of(context).colorScheme.surfaceTint,
            value: ThemesMap.keys.elementAt(index),
            groupValue: theme,
            onChanged: (value) async {
              await isarDB.writeTxn(() async {
                var settings = await isarDB.settings.get(0);
                await isarDB.settings.put(settings!.copyWith(newTheme: value));
              });
            },
          );
        }),
      ),
    );
  }
}
