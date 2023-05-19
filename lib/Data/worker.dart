import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:himotoku/Data/Theme.dart';
import 'package:himotoku/Data/database/database.dart';
import 'package:himotoku/Data/models/Manga.dart';
import 'package:himotoku/Sources/SourceHelper.dart';
import 'package:isar/isar.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void workManagerDispatch() {
  Workmanager().executeTask((task, inputData) {
    try {
      if (task == "library_update") {
        return refreshLibrary();
      }
    } catch (e) {
      debugPrint("workmanager error: $e");
    }
    return Future.value(false);
  });
}

@pragma('vm:entry-point')
Future<bool> refreshLibrary() async {
  int notifID = 1;

  await getIsar();

  var mangaInLibrary =
      isarDB.mangas.where().inLibraryEqualTo(true).findAllSync();

  var updates = {};

  for (int mangaIndex = 0; mangaIndex < mangaInLibrary.length; mangaIndex++) {
    final int progress =
        min(((mangaIndex + 1) / mangaInLibrary.length * 100).round(), 100);

    Manga manga = mangaInLibrary[mangaIndex];

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notifID,
        channelKey: 'library_update',
        groupKey: "library_update_group",
        title: 'Updating library (${mangaIndex + 1}/${mangaInLibrary.length})',
        body: '${manga.mangaName}',
        actionType: ActionType.Default,
        autoDismissible: false,
        category: NotificationCategory.Progress,
        locked: true,
        progress: progress,
        color: Themes.crimsonPrimary,
        notificationLayout: NotificationLayout.ProgressBar,
      ),
      actionButtons: [NotificationActionButton(key: "CANCEL", label: "Cancel")],
    );

    try {
      var newManga = await SourcesMap[manga.source]?.getMangaDetails(manga);
      var diff = newManga?.chapters
          .where((element) =>
              !mangaInLibrary[mangaIndex].chapters.contains(element))
          .toList();
      if (diff?.isNotEmpty ?? false) {
        updates[newManga?.mangaName] = diff?.map((e) => e.name).toList();
      }
    } catch (e) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: notifID + 1,
            channelKey: "library_update",
            groupKey: "library_update_group",
            title: "${manga.mangaName}",
            body: "Error while fetching update."),
      );
    }
  }

  await AwesomeNotifications().cancel(notifID);

  // Update notification
  for (var updateIndex = 0; updateIndex < updates.length; updateIndex++) {
    var chapters = updates.values.elementAt(updateIndex).toString();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: updateIndex,
        channelKey: "library_update",
        groupKey: "library_update_group",
        title: updates.keys.elementAt(updateIndex),
        body: chapters.substring(1, chapters.length - 1),
      ),
    );
  }
  return Future.value(true);
}
