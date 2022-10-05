import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:yomu/Data/SettingDefaults.dart';
import 'package:yomu/Data/Theme.dart';

class ReaderSettings extends StatefulWidget {
  const ReaderSettings({Key? key}) : super(key: key);

  @override
  _ReaderSettingsState createState() => _ReaderSettingsState();
}

class _ReaderSettingsState extends State<ReaderSettings> {
  String prefKey = "settings-reader";
  StreamingSharedPreferences? preferences;

  @override
  void initState() {
    getSharedPrefs();

    super.initState();
  }

  getSharedPrefs() async {
    await StreamingSharedPreferences.instance.then((value) {
      setState(() {
        preferences = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return preferences != null
        ? PreferenceBuilder(
            preference: preferences!.getString(prefKey,
                defaultValue: json.encode(ReaderSettingsMap)),
            builder: (context, readerSettings) => Scaffold(
              appBar: AppBar(title: const Text("Reader")),
              body: ListView(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 12.0),
                  child: Row(
                    children: [
                      Text(
                        "View",
                        style: TextStyle(
                            color: context.theme.colorScheme.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text("Fullscreen"),
                  subtitle: Text("Go fullscreen mode while reading"),
                  trailing: Switch.adaptive(
                      value:
                          jsonDecode(readerSettings)['fullscreen'].toString() ==
                                  'true'
                              ? true
                              : false,
                      onChanged: (value) async {
                        ReaderSettingsMap.update("fullscreen", (v) => value);
                        var result = await preferences!
                            .setString(prefKey, jsonEncode(ReaderSettingsMap));
                      }),
                )
              ]),
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
