// import 'dart:math';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:himotoku/Data/database/database.dart';
// import 'package:himotoku/Data/models/Manga.dart';
// import 'package:himotoku/Sources/SourceHelper.dart';
// import 'package:isar/isar.dart';
// import 'package:workmanager/workmanager.dart';

// const refreshLibraryKey = "com.supremedeity.himotoku.service.refreshLibrary";

// initializeWorkManager() async {
//   print("initializing work manager");
//   await Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: true,
//   );
// }

// // This actually dispatches a service
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   print("callbackDispatcher called");
//   Workmanager().executeTask((taskName, inputData) async {
//     print("Executing task");
//     try {
//       switch (taskName) {
//         case refreshLibraryKey:
//           print("calling refreshLibraryTask");
//           await refreshLibraryTask();
//           print("Completed refershLibraryTask completed");
//           return true;
//         default:
//           return Future.error("Unknown Task");
//       }
//     } catch (e) {
//       print(e);
//     }
//     return Future.value(true);
//   });
// }

// Future<void> refreshLibraryTask() async {
//   await getIsar();
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
// // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('splash');
//   final InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );

//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: notificationTapBackground,
//       onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

//   int notifID = 1;
//   List<Manga> mangaInLibrary =
//       await isarDB.mangas.where().inLibraryEqualTo(true).findAll();

//   for (int mangaIndex = 0; mangaIndex < mangaInLibrary.length; mangaIndex++) {
//     Manga manga = mangaInLibrary[mangaIndex];
//     final int progress =
//         min(((mangaIndex + 1) / mangaInLibrary.length * 100).round(), 100);
//     AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails('library_update', 'Library updates',
//             channelDescription:
//                 'A channel for displaying library update notifications.',
//             importance: Importance.high,
//             priority: Priority.defaultPriority,
//             showProgress: true,
//             maxProgress: 100,
//             autoCancel: false,
//             category: AndroidNotificationCategory.progress,
//             channelShowBadge: false,
//             ongoing: true,
//             enableVibration: false,
//             progress: progress,
//             actions: [AndroidNotificationAction("CANCEL", "Cancel")]);
//     NotificationDetails notificationDetails =
//         NotificationDetails(android: androidNotificationDetails);

//     await FlutterLocalNotificationsPlugin().show(
//       notifID,
//       'Updating library (${mangaIndex + 1}/${mangaInLibrary.length})',
//       manga.mangaName,
//       notificationDetails,
//     );
//     await SourcesMap[manga.source]?.getMangaDetails(manga);
//   }
//   FlutterLocalNotificationsPlugin().cancel(notifID); // Close the notif
// }

// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse notificationResponse) {
//   // handle action
//   if (notificationResponse.actionId == "CANCEL") {
//     Workmanager().cancelByUniqueName(refreshLibraryKey);
//     FlutterLocalNotificationsPlugin().cancel(1); // TODO: use payload
//   }
// }
