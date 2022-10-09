import 'package:isar/isar.dart';
import 'package:yomu/Data/Theme.dart';

part 'Setting.g.dart';

@Collection()
class Setting {
  // Required by IsarDB
  Id? id;

  // Theme Settings
  /// Theme String must match with the keys from [themeMap]
  String theme = themeMap.keys.elementAt(0);

  // Reader Settings
  /// Reader UI Fullscreen
  bool fullscreen = false;

  // Backup Settings
  String backupExportLocation = "";

  @Ignore()
  Setting copyWith({
    String? newTheme,
    bool? newFullscreen,
    String? newBackupExportLocation,
  }) {
    return Setting()
      ..id = 0
      ..theme = newTheme ?? theme
      ..fullscreen = newFullscreen ?? fullscreen
      ..backupExportLocation = newBackupExportLocation ?? backupExportLocation;
  }

  Setting();
}
