import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:workmanager/workmanager.dart';

class NotificationController {
  static final List<NotificationChannel> notificationChannels = [
    // Library Updates channel
    NotificationChannel(
      channelGroupKey: 'library_update_group',
      channelKey: 'library_update',
      channelName: 'Library Updates',
      channelDescription: 'Notification channel for library updates.',
      // defaultColor: Colors.red,
      // ledColor: Colors.white,
    )
  ];

  static final List<NotificationChannelGroup> notificationChannelGroups = [
    NotificationChannelGroup(
        channelGroupKey: 'library_update_group',
        channelGroupName: 'Library updates group')
  ];

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint(
        "Notification [ID ${receivedAction.id}]: Action = ID: ${receivedAction.buttonKeyPressed}");
    if (receivedAction.id == 1 && receivedAction.buttonKeyPressed == "CANCEL") {
      await Workmanager().cancelByUniqueName("library_update");
    }
  }
}
