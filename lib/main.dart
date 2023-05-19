import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:himotoku/Data/database/database.dart';

import 'package:himotoku/Data/models/Setting.dart';
import 'package:himotoku/Data/Theme.dart';
import 'package:himotoku/Data/worker.dart';
import 'package:himotoku/Views/main_view.dart';
import 'package:himotoku/rustlib/rustlib.dart';
import 'package:workmanager/workmanager.dart';

import 'Data/notification_controller.dart';

// import 'package:himotoku/test.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await FlutterDownloader.initialize(
    debug: kDebugMode,
  );
  await getIsar();
  Workmanager().initialize(workManagerDispatch, isInDebugMode: kDebugMode);

  AwesomeNotifications().initialize(
    null, // TODO: fix this
    NotificationController.notificationChannels,
    channelGroups: NotificationController.notificationChannelGroups,
    debug: kDebugMode,
  );

  runApp(
    const himotokuMain(),
  );
}

class himotokuMain extends StatefulWidget {
  const himotokuMain({super.key});

  @override
  State<himotokuMain> createState() => _himotokuMainState();
}

class _himotokuMainState extends State<himotokuMain> {
  ThemeData? currentTheme;

  @override
  void initState() {
    initPrefs();
    initMisc();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getTheme() async {
    var settings = await isarDB.settings.get(0);
    setState(() {
      currentTheme = ThemesMap[settings!.theme];
    });
  }

  initPrefs() async {
    var brightness = PlatformDispatcher.instance.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var defaultTheme =
        isDarkMode ? ThemesMap.keys.elementAt(1) : ThemesMap.keys.elementAt(0);
    var currentSettings = await isarDB.settings.get(0);

    if (currentSettings == null) {
      isarDB.writeTxnSync(() {
        isarDB.settings.putSync(Setting().copyWith(nTheme: defaultTheme));
      });
    }
    Stream<void> instanceChanged =
        isarDB.settings.watchLazy(fireImmediately: true);
    instanceChanged.listen(
      (event) async {
        getTheme();
      },
    );
  }

  void initMisc() async {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);

    // TODO: Add better handling for this.
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    await FlutterDownloader.registerCallback(downloaderCallback);
    await api.initAndroidLogger();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainView(),
      themeMode: ThemeMode.system,
      theme: currentTheme,
    );
  }
}

@pragma('vm:entry-point')
void downloaderCallback(String id, int status, int progress) {}
