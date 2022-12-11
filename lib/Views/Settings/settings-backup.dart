// ignore_for_file:

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:himotoku/Data/database/database.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Data/models/Setting.dart';

class ImportExportSettings extends StatefulWidget {
  const ImportExportSettings({Key? key}) : super(key: key);

  @override
  _ImportExportSettingsState createState() => _ImportExportSettingsState();
}

class _ImportExportSettingsState extends State<ImportExportSettings> {
  String backupExportLocation = "";

  @override
  void initState() {
    updateSettings();
    super.initState();
  }

  updateSettings() async {
    var settings = await isarDB.settings.get(0);

    setState(() {
      backupExportLocation = settings!.backupExportLocation;
    });
  }

  void export(BuildContext context) async {
    try {
      if (await Permission.manageExternalStorage.request().isGranted) {
        var jsonContent =
            await isarDB.mangas.filter().inLibraryEqualTo(true).exportJson();
        var content = jsonEncode(jsonContent);

        DateTime now = DateTime.now();
        String backupLocation =
            "$backupExportLocation/himotokuBackup-${now.day}-${now.month}-${now.year}-${now.millisecond}";

        File file = await File(backupLocation).create(recursive: true);

        await file.writeAsBytes(gzip.encode(utf8.encode(content)));
        var snackbar = SnackBar(content: Text("Saved to $backupLocation"));
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

          await isarDB.writeTxn(() => isarDB.mangas.importJson(content));

          var snackbar = const SnackBar(content: Text("Imported backup."));
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
        await isarDB.writeTxn(() async {
          var settings = await isarDB.settings.get(0);
          await isarDB.settings.put(
              settings!.copyWith(newBackupExportLocation: selectedDirectory));
        });

        setState(() {
          backupExportLocation = selectedDirectory.toString();
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
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: Border.all(),
          titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground),
          title: const Text('Export locally'),
          content: SingleChildScrollView(
            child: ListBody(
                children: backupExportLocation.isNotEmpty
                    ? [
                        const Text('Exporting to:'),
                        Text(backupExportLocation,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary))
                      ]
                    : [
                        const Text(
                            "Please set \"Export Location\" prior to this.")
                      ]),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: backupExportLocation.isNotEmpty
                  ? () {
                      export(context);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Export'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backup")),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 12.0),
          child: Text(
            "Export",
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500),
          ),
        ),
        ListTile(
          title: const Text("Export Location"),
          leading: const Icon(Icons.folder_outlined),
          subtitle: Text(
            backupExportLocation.isNotEmpty ? backupExportLocation : "Not set",
          ),
          onTap: () {
            pickDirectoryLocation();
          },
        ),
        ListTile(
          title: const Text("Local Export"),
          leading: const Icon(Icons.phone_android_outlined),
          subtitle: const Text(
            "Export to local storage.",
          ),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            _showMyDialog();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 12.0),
          child: Text(
            "Import",
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500),
          ),
        ),
        ListTile(
          title: const Text("Local Import"),
          leading: const Icon(Icons.import_export_outlined),
          subtitle: const Text(
            "Import backup from local storage.",
          ),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            import(context);
          },
        ),
      ]),
    );
  }
}
