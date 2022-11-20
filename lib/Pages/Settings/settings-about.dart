// ignore_for_file:

import 'package:flutter/material.dart' hide showLicensePage;
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Pages/Settings/settings-about-licenses.dart';

class SettingsAbout extends StatefulWidget {
  const SettingsAbout({Key? key}) : super(key: key);

  @override
  _SettingsAboutState createState() => _SettingsAboutState();
}

class _SettingsAboutState extends State<SettingsAbout> {
  PackageInfo? pkgInfo;

  void getPkgInfo() async {
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        pkgInfo = value;
      });
    });
  }

  @override
  void initState() {
    getPkgInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("About"),
        ),
        body: pkgInfo != null
            ? ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: APP_ICON,
                  ),
                  Center(
                      child: Text(
                    pkgInfo!.appName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  )),
                  Center(
                      child: Text(
                    pkgInfo!.version,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  )),
                  Center(
                    child: Text(
                      "Licensed under GNU GPLv3",
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
                              "https://github.com/SupremeDeity08/himotoku/releases"),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ],
              )
            : Container());
  }
}
