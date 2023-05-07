// ignore_for_file:

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Widgets/Settings/SectionHeader.dart';
import 'package:isar/isar.dart';
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
        final archive = Archive();
        var mangaRawJson;
        var settingsRawJson;

        // TODO(SupremeDeity): Try minimizing the exported fields to only the
        // required fields of [Manga]

        await isarDB.mangas
            .where()
            .inLibraryEqualTo(true)
            .exportJsonRaw(((rawJson) {
          mangaRawJson = Uint8List.fromList(rawJson);
        }));
        await isarDB.settings.where().idEqualTo(0).exportJsonRaw((rawJson) {
          settingsRawJson = Uint8List.fromList(rawJson);
        });

        final mangaArchiveFile =
            ArchiveFile(isarDB.mangas.name, mangaRawJson.length, mangaRawJson);
        archive.addFile(mangaArchiveFile);
        final settingsArchiveFile = ArchiveFile(
            isarDB.settings.name, settingsRawJson.length, settingsRawJson);
        archive.addFile(settingsArchiveFile);
        List<int>? encodedZip = ZipEncoder().encode(archive);

        if (encodedZip == null) return;

        DateTime now = DateTime.now();
        String backupLocation =
            "$backupExportLocation/himotokuBackup-${now.day}-${now.month}-${now.year}-${now.millisecond}.zip";

        File file = await File(backupLocation).create(recursive: true);

        await file.writeAsBytes(encodedZip);

        var snackbar = SnackBar(content: Text("Saved to $backupLocation"));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } catch (e) {
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

          var archive = ZipDecoder().decodeBytes(backupContentBytes);

          for (var file in archive) {
            if (file.isFile && file.name == isarDB.mangas.name) {
              await isarDB
                  .writeTxn(() => isarDB.mangas.importJsonRaw(file.content));
            }
            if (file.isFile && file.name == isarDB.settings.name) {
              await isarDB
                  .writeTxn(() => isarDB.settings.importJsonRaw(file.content));
            }
          }

          var snackbar = const SnackBar(content: Text("Imported backup."));
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      }
    } catch (e) {
      var snackbar = const SnackBar(content: Text("Failed to save backup."));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
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
                            "Please set \"Backup Location\" prior to this.")
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
      appBar: AppBar(title: const Text("Backup & Restore")),
      body: ListView(children: [
        SectionHeader("Export"),
        ListTile(
          title: const Text("Backup Location",
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: Icon(
            Icons.folder_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          subtitle: Text(
            backupExportLocation.isNotEmpty ? backupExportLocation : "Not set",
          ),
          onTap: () {
            pickDirectoryLocation();
          },
        ),
        ListTile(
          title: const Text("Create Backup",
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: Icon(
            Icons.phone_android_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          subtitle: const Text(
            "Export backup to local storage.",
          ),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            _showMyDialog();
          },
        ),
        SectionHeader("Import"),
        ListTile(
          title: const Text("Restore Backup",
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: Icon(
            Icons.settings_backup_restore,
            color: Theme.of(context).colorScheme.primary,
          ),
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
