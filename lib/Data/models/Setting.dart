// ignore_for_file: , invalid_annotation_target

import 'package:isar/isar.dart';
import 'package:himotoku/Data/Theme.dart';

part 'Setting.g.dart';

enum LibrarySort {
  az,
  za,
  status,
  statusDesc,
}

@Collection()
class Setting {
  // Required by IsarDB
  Id? id;

  // Theme Settings
  /// Theme String must match with the keys from [ThemesMap]
  String theme = ThemesMap.keys.elementAt(0);

  // Reader Settings
  /// Reader UI Fullscreen
  bool fullscreen = true;
  bool splitTallImages = false;

  // Backup Settings
  String backupExportLocation = "";

  /// Library filter options
  FilterOptions filterOptions = FilterOptions();

  /// Library sort options
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
    bool? newUnread,
  }) {
    return FilterOptions()
      ..started = newStarted ?? started
      ..unread = newUnread ?? unread;
  }

  bool started = false;
  bool unread = false;
}
