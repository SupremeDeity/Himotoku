import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:yomu/Data/Theme.dart';

class SettingsTheme extends StatefulWidget {
  const SettingsTheme({Key? key}) : super(key: key);

  @override
  _SettingsThemeState createState() => _SettingsThemeState();
}

class _SettingsThemeState extends State<SettingsTheme> {
  StreamingSharedPreferences? preferences;

  @override
  void initState() {
    getSharedPrefs();

    super.initState();
  }

  getSharedPrefs() async {
    StreamingSharedPreferences.instance.then((value) {
      setState(() {
        preferences = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return preferences != null
        ? PreferenceBuilder(
            preference: preferences!.getString("theme",
                defaultValue: context.theme.brightness == Brightness.dark
                    ? "Default Dark"
                    : "Default Light"),
            builder: (context, theme) => Scaffold(
              appBar: AppBar(title: const Text("Theme")),
              body: ListView(
                children: List.generate(themeMap.length, (index) {
                  return ListTile(
                    title: Text(themeMap.keys.elementAt(index)),
                    leading: Radio(
                        value: themeMap.keys.elementAt(index),
                        groupValue: theme,
                        onChanged: (value) async {
                          preferences!.setString('theme', value!);
                          Get.changeTheme(themeMap[value]!);
                        }),
                  );
                }),
              ),
            ),
          )
        : Center(
            child: CircularProgressIndicator(
            color: context.theme.colorScheme.secondary,
          ));
  }
}
