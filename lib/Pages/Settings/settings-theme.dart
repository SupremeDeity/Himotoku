import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:yomu/Data/Setting.dart';
import 'package:yomu/Data/Theme.dart';

class SettingsTheme extends StatefulWidget {
  const SettingsTheme({Key? key}) : super(key: key);

  @override
  _SettingsThemeState createState() => _SettingsThemeState();
}

class _SettingsThemeState extends State<SettingsTheme> {
  var isarInstance = Isar.getInstance('isarInstance')!;
  var cancelSubscription;
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
      Logger logger = Logger();
      logger.e(e);
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
    cancelSubscription.cancel();
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
                value: themeMap.keys.elementAt(index),
                groupValue: theme,
                onChanged: (value) async {
                  await isarInstance.writeTxn(() async {
                    var settings = await isarInstance.settings.get(0);
                    await isarInstance.settings
                        .put(settings!.copyWith(newTheme: value));
                  });
                  Get.changeTheme(themeMap[value]!);
                }),
          );
        }),
      ),
    );
  }
}
