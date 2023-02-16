// ignore_for_file:

import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide showLicensePage;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Views/Settings/settings-about-licenses.dart';
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
  String releaseUrl = "https://github.com/SupremeDeity/himotoku/releases/";

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
          // * We always allow pre-releases like beta and alpha.
          // * Dev pre-releases are only allowed if current version is also a
          // * dev pre-release.
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
                      "New release: $release",
                    ),
                    content: ListView(shrinkWrap: true, children: [
                      if (release.isPreRelease)
                        Chip(
                          label: Text("Pre-release"),
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
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
                            installApk(newRelease);
                            Navigator.of(context).pop();
                          },
                          child: Text("Install")),
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

  void installApk(var releaseMetadata) async {
    String? apkAssetABI;
    var currentAsset;

    switch (Abi.current()) {
      case Abi.androidArm:
        apkAssetABI = "armeabi-v7a";
        break;
      case Abi.androidArm64:
        apkAssetABI = "arm64-v8a";
        break;
      case Abi.androidX64:
        apkAssetABI = "x86_64";
        break;
    }

    for (var asset in releaseMetadata['assets']) {
      if (asset['name'].toString().contains(apkAssetABI ?? "$name-release")) {
        currentAsset = asset;
        break;
      }
    }

    if (await Permission.manageExternalStorage.request().isGranted &&
        await Permission.storage.request().isGranted) {
      var downloadDirectory = (await getExternalCacheDirectories())?[0];
      if (downloadDirectory != null && currentAsset != null) {
        if (!(await downloadDirectory.exists())) {
          await downloadDirectory.create();
        }
        ReceivePort _port = ReceivePort();
        await Isolate.spawn<List<dynamic>>(
            downloadApk, [currentAsset, downloadDirectory.path, _port.sendPort],
            errorsAreFatal: false);
        _port.listen((message) async {
          int count = message[0];
          int total = message[1];
          AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails('downloader', 'Downloader',
                  channelDescription:
                      'A channel for displaying download progress and events.',
                  icon: "splash",
                  importance: Importance.defaultImportance,
                  priority: Priority.defaultPriority,
                  showProgress: true,
                  maxProgress: 100,
                  autoCancel: false,
                  category: AndroidNotificationCategory.progress,
                  channelShowBadge: false,
                  ongoing: true,
                  onlyAlertOnce: true,
                  progress: ((count / total * 100)).toInt(),
                  actions: [AndroidNotificationAction("CANCEL_APK", "Cancel")]);
          NotificationDetails notificationDetails =
              NotificationDetails(android: androidNotificationDetails);

          if (count < total) {
            await FlutterLocalNotificationsPlugin().show(
              currentAsset['id'],
              'Downloading new version...',
              currentAsset['name'],
              notificationDetails,
            );
          } else {
            FlutterLocalNotificationsPlugin().cancel(currentAsset['id']);

            OpenResult result = await OpenFilex.open(
                "${downloadDirectory.path}/${currentAsset['name']}",
                type: "application/vnd.android.package-archive");
            print(result.message);
          }
        });
      }
    }
  }
}

void downloadApk(var data) async {
  try {
    final dio = Dio();

    await dio.download(
      data[0]['browser_download_url'],
      "${data[1]}/${data[0]['name']}",
      onReceiveProgress: (count, total) async {
        // print("$count/$total");
        data[2].send([count, total]);
      },
    );
    // print(response.statusCode);
  } catch (e) {
    print(e);
  }
}
