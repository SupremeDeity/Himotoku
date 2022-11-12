// ignore_for_file: file_names

import 'package:flutter/material.dart' hide showLicensePage;
// import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yomu/Data/Constants.dart';
import 'package:yomu/Pages/Settings/settings-about-licenses.dart';

class SettingsAbout extends StatefulWidget {
  const SettingsAbout({Key? key}) : super(key: key);

  @override
  _SettingsAboutState createState() => _SettingsAboutState();
}

class _SettingsAboutState extends State<SettingsAbout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("About"),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: APP_ICON,
            ),
            const Center(
                child: Text(
              APP_NAME,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )),
            Center(
                child: Text(
              APP_VERSION,
              style: TextStyle(color: Theme.of(context).hintColor),
            )),
            Center(
              child: Text(
                "Licensed under GNU GPLv2",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
            const Padding(padding: EdgeInsets.all(20)),
            ListTile(
              onTap: () {
                showLicensePage(context: context);
              },
              title: const Text("Open-Source Licenses"),
            ),
            ListTile(
              title: const Text("What's New"),
              onTap: () {
                launchUrl(
                    Uri.parse(
                        "https://github.com/SupremeDeity08/Yomu/releases"),
                    mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ));
  }
}
