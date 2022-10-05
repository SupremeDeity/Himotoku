import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:yomu/Data/Manga.dart';
import 'package:yomu/Data/SettingDefaults.dart';
import 'package:yomu/Data/Theme.dart';

class ImportExportSettings extends StatefulWidget {
  const ImportExportSettings({Key? key}) : super(key: key);

  @override
  _ImportExportSettingsState createState() => _ImportExportSettingsState();
}

class _ImportExportSettingsState extends State<ImportExportSettings> {
  String exportLocation = "";
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
        exportLocation = jsonDecode(value
                .getString("settings-backup",
                    defaultValue: jsonEncode(BackupSettingsMap))
                .getValue())['export_location']
            .toString();
      });
    });
  }

  void export(BuildContext context) async {
    try {
      if (await Permission.manageExternalStorage.request().isGranted) {
        var isarInstance = Isar.getInstance("mangaInstance");
        var jsonContent = await isarInstance!.mangas
            .filter()
            .inLibraryEqualTo(true)
            .exportJson();
        var content = jsonEncode(jsonContent);

        String? backupDirectory = await preferences
            ?.getString("settings-backup",
                defaultValue: jsonEncode(BackupSettingsMap))
            .getValue();

        DateTime now = DateTime.now();
        String backupLocation =
            jsonDecode(backupDirectory!)['export_location'] +
                "/YomuBackup" +
                "-" +
                now.day.toString() +
                "-" +
                now.month.toString() +
                "-" +
                now.year.toString() +
                "-" +
                now.millisecond.toString();

        File file = await File(backupLocation).create(recursive: true);

        await file.writeAsBytes(gzip.encode(utf8.encode(content)));
        var snackbar = SnackBar(content: Text("Saved to $backupLocation"));
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } catch (e) {
      Logger logger = Logger();
      logger.e(e);
      var snackbar = const SnackBar(content: Text("Failed to save backup."));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  void import(BuildContext context) async {
    try {
      if (await Permission.manageExternalStorage.request().isGranted) {
        var isarInstance = Isar.getInstance("mangaInstance");

        var backupFileLocation = await FilePicker.platform.pickFiles();

        if (backupFileLocation != null) {
          File file = File(backupFileLocation.files.single.path!);

          var backupContentBytes = await file.readAsBytes();
          List<dynamic> rawContent = json.decode(
            utf8.decode(gzip.decode(backupContentBytes)),
          );
          List<Map<String, dynamic>> content = rawContent.map((element) {
            return element as Map<String, dynamic>;
          }).toList();

          await isarInstance!
              .writeTxn(() => isarInstance.mangas.importJson(content));

          var snackbar = SnackBar(content: Text("Imported backup."));
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      }
    } catch (e) {
      Logger logger = Logger();
      logger.e(e);
      // var snackbar = const SnackBar(content: Text("Failed to save backup."));
      // ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  pickDirectoryLocation() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      if (selectedDirectory != "/") {
        BackupSettingsMap.update(
            "export_location", (value) => selectedDirectory.toString());
        await preferences?.setString(
            "settings-backup", jsonEncode(BackupSettingsMap));
        setState(() {
          exportLocation = selectedDirectory.toString();
        });
      }
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export locally'),
          content: SingleChildScrollView(
            child: ListBody(
                children: exportLocation.isNotEmpty
                    ? [Text('Exporting to:'), Text(exportLocation)]
                    : [Text("Please set \"Export Location\" prior to this.")]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Export'),
              onPressed: exportLocation.isNotEmpty
                  ? () {
                      export(context);
                      Navigator.of(context).pop();
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return preferences != null
        ? PreferenceBuilder(
            preference: preferences!.getString("settings-backup",
                defaultValue: jsonEncode(BackupSettingsMap)),
            builder: (ctx, value) => Scaffold(
              appBar: AppBar(title: const Text("Backup")),
              body: ListView(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 12.0),
                  child: Text(
                    "Export",
                    style: TextStyle(
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                ListTile(
                  title: Text("Export Location"),
                  leading: Icon(Icons.folder_outlined),
                  subtitle: Text(
                    jsonDecode(value)['export_location'].toString(),
                  ),
                  onTap: () {
                    pickDirectoryLocation();
                  },
                ),
                ListTile(
                  title: Text("Local Export"),
                  leading: Icon(Icons.phone_android_outlined),
                  subtitle: Text(
                    "Export to local storage.",
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    _showMyDialog();
                  },
                ),
                // TODO: ADD CLOUD EXPORT SUPPORT
                // ListTile(
                //   title: Text("Cloud Export"),
                //   leading: Icon(Icons.cloud_upload_outlined),
                //   subtitle: Text(
                //     "Export to Google Drive.",
                //   ),
                //   trailing: Icon(Icons.arrow_forward),
                //   onTap: () {},
                // ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 12.0),
                  child: Text(
                    "Import",
                    style: TextStyle(
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                ListTile(
                  title: Text("Local Import"),
                  leading: Icon(Icons.import_export_outlined),
                  subtitle: Text(
                    "Import backup from local storage.",
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    import(context);
                  },
                ),
              ]),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
