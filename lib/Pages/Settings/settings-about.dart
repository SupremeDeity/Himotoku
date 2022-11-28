// ignore_for_file:

import 'dart:convert';

import 'package:flutter/material.dart' hide showLicensePage;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart';
// import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Pages/Settings/settings-about-licenses.dart';
import 'package:version/version.dart';
import 'package:yaml/yaml.dart';

class SettingsAbout extends StatefulWidget {
  const SettingsAbout({Key? key}) : super(key: key);

  @override
  _SettingsAboutState createState() => _SettingsAboutState();
}

class _SettingsAboutState extends State<SettingsAbout> {
  Version currentVersion = Version.parse("0.0.0");
  String latestReleaseApiUrl =
      "https://api.github.com/repos/supremedeity/himotoku/releases";

  String name = "appName";
  String releaseUrl = "https://github.com/SupremeDeity08/himotoku/releases/";

  @override
  void initState() {
    getAppInfo();
    super.initState();
  }

  void getAppInfo() async {
    var pubspec =
        await DefaultAssetBundle.of(context).loadString("pubspec.yaml");
    var yaml = loadYaml(pubspec);
    setState(() {
      currentVersion = Version.parse(yaml['version']);
      name = yaml['name'];
    });
  }

  checkUpdate() {
    SnackBar checkUpdateSB =
        SnackBar(content: Text("Checking for new update..."));
    SnackBar noUpdateSB = SnackBar(content: Text("No new update."));
    SnackBar updateErrorSB =
        SnackBar(content: Text("Error occured while fetching update."));
    ScaffoldMessenger.of(context).showSnackBar(checkUpdateSB);
    get(Uri.parse(latestReleaseApiUrl),
        headers: {"Accept": "application/vnd.github+json"}).then((response) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).clearSnackBars();
        var body = jsonDecode(response.body);

        /// Latest version on remote.
        var newRelease;
        for (var release in body) {
          Version rVersion = Version.parse(release['tag_name']);
          bool isDevRelease =
              rVersion.isPreRelease && rVersion.preRelease[0] == "dev";
          bool isDevReleaseAllowed = currentVersion.isPreRelease &&
              currentVersion.preRelease[0] == "dev";

          if ((rVersion > currentVersion) &&
              (isDevRelease == isDevReleaseAllowed)) {
            newRelease = release;
            break;
          }
        }
        if (newRelease != null) {
          Version release = Version.parse(newRelease['tag_name']);
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (bc) => AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    shape: Border.all(),
                    titleTextStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground),
                    title: Text(
                      "$currentVersion -> $release",
                    ),
                    content: ListView(children: [
                      if (release.isPreRelease)
                        Chip(
                          label: Text("Pre-release"),
                          backgroundColor: Colors.red,
                        ),
                      MarkdownBody(
                        data: newRelease['body'],
                        onTapLink: (text, href, title) => launchUrl(
                            Uri.parse(href!),
                            mode: LaunchMode.externalApplication),
                      ),
                    ]),
                    actions: [
                      TextButton(
                          onPressed: () {
                            launchUrl(
                                Uri.parse(releaseUrl +
                                    "/tag/${newRelease['tag_name']}"),
                                mode: LaunchMode.externalApplication);
                          },
                          child: Text("Download")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(bc);
                          },
                          child: Text("Cancel")),
                    ],
                  ));
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(noUpdateSB);
        }
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(updateErrorSB);
      }
    });
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
            Center(
                child: Text(
              name.replaceRange(0, 1, name[0].toUpperCase()),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )),
            Center(
                child: Text(
              currentVersion.toString(),
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
                title: const Text("Check for update"),
                onTap: () => checkUpdate()),
            ListTile(
              title: const Text("What's New"),
              onTap: () {
                launchUrl(Uri.parse(releaseUrl + "/tag/$currentVersion"),
                    mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ));
  }
}
