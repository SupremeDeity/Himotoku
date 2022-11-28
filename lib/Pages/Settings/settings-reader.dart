// ignore_for_file:

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:himotoku/Data/Constants.dart';
import 'package:himotoku/Data/Setting.dart';

class ReaderSettings extends StatefulWidget {
  const ReaderSettings({Key? key}) : super(key: key);

  @override
  _ReaderSettingsState createState() => _ReaderSettingsState();
}

class _ReaderSettingsState extends State<ReaderSettings> {
  var isarInstance = Isar.getInstance(ISAR_INSTANCE_NAME)!;
  bool? fullscreen;
  bool? splitTallImages;
  StreamSubscription<void>? cancelSubscription;

  @override
  void initState() {
    try {
      Stream<void> settingsChanged =
          isarInstance.settings.watchObjectLazy(0, fireImmediately: true);
      cancelSubscription = settingsChanged.listen((event) async {
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
      splitTallImages = settings!.splitTallImages;
      fullscreen = settings.fullscreen;
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
      appBar: AppBar(title: const Text("Reader")),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 12.0),
          child: Row(
            children: [
              Text(
                "View",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        ListTile(
            title: const Text("Fullscreen"),
            subtitle: const Text("Go fullscreen mode while reading."),
            trailing: Switch(
                value: fullscreen ?? false,
                onChanged: (value) async {
                  await isarInstance.writeTxn(() async {
                    var settings = await isarInstance.settings.get(0);
                    await isarInstance.settings
                        .put(settings!.copyWith(newFullscreen: value));
                  });
                })),
        // Padding(
        //   padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
        //   child: Row(
        //     children: [
        //       Text(
        //         "Quality & Performance",
        //         style: TextStyle(
        //             color: context.theme.colorScheme.primary,
        //             fontWeight: FontWeight.w500),
        //       ),
        //     ],
        //   ),
        // ),
        // ListTile(
        //     title: Text("Split tall images"),
        //     isThreeLine: true,
        //     subtitle: Text(
        //         "Splits tall images into smaller parts.\nImproves quality but impacts loading time."),
        //     trailing: Switch(
        //         value: splitTallImages ?? false,
        //         onChanged: (value) async {
        //           await isarInstance.writeTxn(() async {
        //             var settings = await isarInstance.settings.get(0);
        //             await isarInstance.settings
        //                 .put(settings!.copyWith(newSplitTallImages: value));
        //           });
        //         }))
      ]),
    );
  }
}
