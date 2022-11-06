import 'package:isar/isar.dart';
import 'package:yomu/Data/Theme.dart';

part 'Setting.g.dart';

enum LibrarySort {
  az,
  za,
  status,
  statusDesc,
  // added,
  // addedDesc,
}

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
  bool splitTallImages = false;

  // Backup Settings
  String backupExportLocation = "";

  // Library Settings
  FilterOptions filterOptions = FilterOptions();

  @enumerated
  LibrarySort sortSettings = LibrarySort.az;

  @Ignore()
  Setting copyWith({
    String? newTheme,
    bool? newFullscreen,
    bool? newSplitTallImages,
    String? newBackupExportLocation,
    FilterOptions? newFilterOptions,
    LibrarySort? newSortSettings,
  }) {
    return Setting()
      ..id = 0
      ..theme = newTheme ?? theme
      ..fullscreen = newFullscreen ?? fullscreen
      ..splitTallImages = newSplitTallImages ?? splitTallImages
      ..backupExportLocation = newBackupExportLocation ?? backupExportLocation
      ..filterOptions = newFilterOptions ?? filterOptions
      ..sortSettings = newSortSettings ?? sortSettings;
  }

  Setting();
}

@embedded
class FilterOptions {
  FilterOptions();

  @Ignore()
  FilterOptions copyWith({
    bool? newStarted,
  }) {
    return FilterOptions()..started = newStarted ?? started;
  }

  bool started = false;
}
