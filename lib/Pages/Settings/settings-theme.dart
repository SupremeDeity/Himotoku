import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsTheme extends StatefulWidget {
  const SettingsTheme({Key? key}) : super(key: key);

  @override
  _SettingsThemeState createState() => _SettingsThemeState();
}

class _SettingsThemeState extends State<SettingsTheme> {
  SharedPreferences? prefs;

  getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    getSharedPrefs();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Theme")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Strawberry Dark"),
            leading: Radio(
                value: "strawberryDark",
                groupValue: prefs?.getString("theme"),
                onChanged: (value) async {
                  await prefs?.setString("theme", value!);
                }),
          ),
          ListTile(
            title: Text("Strawberry Light"),
            leading: Radio(
                value: "strawberryLight",
                groupValue: "strawberryDark",
                onChanged: (value) async {
                  await prefs?.setString("theme", value!);
                }),
          )
        ],
      ),
    );
  }
}
