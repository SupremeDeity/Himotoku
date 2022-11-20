// ignore_for_file:

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/Setting.dart';
import 'package:himotoku/Data/Theme.dart';

class SettingsTheme extends StatefulWidget {
  const SettingsTheme({Key? key}) : super(key: key);

  @override
  _SettingsThemeState createState() => _SettingsThemeState();
}

class _SettingsThemeState extends State<SettingsTheme> {
  var isarInstance = Isar.getInstance(ISAR_INSTANCE_NAME)!;
  StreamSubscription<void>? cancelSubscription;
  String? theme;

  @override
  void initState() {
    try {
      Stream<void> settingsChanged =
          isarInstance.settings.watchObjectLazy(0, fireImmediately: true);
      cancelSubscription = settingsChanged.listen((event) {
        updateSettings();
      });
    } catch (e) {
      if (kDebugMode) {
        Logger logger = Logger();
        logger.e(e);
      }
    }
    super.initState();
  }

  updateSettings() async {
    var settings = await isarInstance.settings.get(0);
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
        children: List.generate(themeMap.length, (index) {
          return ListTile(
            title: Text(themeMap.keys.elementAt(index)),
            leading: Radio(
                activeColor: Theme.of(context).colorScheme.surfaceTint,
                value: themeMap.keys.elementAt(index),
                groupValue: theme,
                onChanged: (value) async {
                  await isarInstance.writeTxn(() async {
                    var settings = await isarInstance.settings.get(0);
                    await isarInstance.settings
                        .put(settings!.copyWith(newTheme: value));
                  });
                }),
          );
        }),
      ),
    );
  }
}
