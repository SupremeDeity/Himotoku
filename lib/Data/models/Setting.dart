// ignore_for_file: , invalid_annotation_target

import 'package:isar/isar.dart';
import 'package:himotoku/Data/Theme.dart';

part 'Setting.g.dart';

enum LibrarySort {
  az,
  za,
  status,
  statusDesc,
  chapterCount,
  chapterCountDesc,
  unreadCount,
  unreadCountDesc,
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
  bool splitTallImages = true;

  // Backup Settings
  String backupExportLocation = "";

  /// Library filter options
  FilterOptions filterOptions = FilterOptions();

  /// Library sort options
  @enumerated
  LibrarySort sortSettings;

  @Ignore()
  Setting copyWith({
    String? nTheme,
    bool? newFullscreen,
    bool? newSplitTallImages,
    String? newBackupExportLocation,
    FilterOptions? nFilterOptions,
    LibrarySort? newSortSettings,
  }) {
    return Setting(
      id: 0,
      newTheme: nTheme ?? theme,
      fullscreen: newFullscreen ?? fullscreen,
      splitTallImages: newSplitTallImages ?? splitTallImages,
      backupExportLocation: newBackupExportLocation ?? backupExportLocation,
      newFilterOptions: nFilterOptions ?? filterOptions,
      sortSettings: newSortSettings ?? sortSettings,
    );
  }

  Setting({
    this.id = 0,
    String? newTheme,
    this.fullscreen = true,
    this.splitTallImages = true,
    this.backupExportLocation = "",
    FilterOptions? newFilterOptions,
    this.sortSettings = LibrarySort.az,
  }) {
    this.theme = newTheme ?? ThemesMap.keys.elementAt(0);
    this.filterOptions = newFilterOptions ?? FilterOptions();
  }
}

@embedded
class FilterOptions {
  FilterOptions({
    this.started = false,
    this.unread = false,
  });

  @Ignore()
  FilterOptions copyWith({
    bool? newStarted,
    bool? newUnread,
  }) {
    return FilterOptions(
        started: newStarted ?? started, unread: newUnread ?? unread);
  }

  bool started;
  bool unread;
}
