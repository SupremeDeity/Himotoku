import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:himotoku/Data/database/database.dart';

import 'package:himotoku/Data/models/Setting.dart';
import 'package:himotoku/Data/Theme.dart';
import 'package:himotoku/Views/main_view.dart';

// import 'package:himotoku/test.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await getIsar();

  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    'resource://drawable/splash',
    [
      NotificationChannel(
        channelKey: 'library_update',
        channelName: 'Library update notification',
        channelDescription: 'Notification channel for library updates.',
        defaultColor: Colors.blue,
        channelShowBadge: false,
        importance: NotificationImportance.Low,
      )
    ],
    debug: kDebugMode ? true : false,
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
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (bc) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            shape: Border.all(),
            titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground),
            title: Text(
              "Allow notifications?",
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    AwesomeNotifications()
                        .requestPermissionToSendNotifications();
                  },
                  child: Text("Allow")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(bc);
                  },
                  child: Text("Don't allow")),
            ],
          ),
        );
      }
    });
    super.initState();
  }

  getTheme() async {
    var settings = await isarDB.settings.get(0);
    setState(() {
      currentTheme = ThemesMap[settings!.theme];
    });
  }

  initPrefs() async {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var defaultTheme =
        isDarkMode ? ThemesMap.keys.elementAt(1) : ThemesMap.keys.elementAt(0);
    var currentSettings = await isarDB.settings.get(0);

    if (currentSettings == null) {
      isarDB.writeTxnSync(() {
        isarDB.settings.putSync(Setting().copyWith(newTheme: defaultTheme));
      });
    }
    Stream<void> instanceChanged =
        isarDB.settings.watchLazy(fireImmediately: true);
    instanceChanged.listen(
      (event) async {
        getTheme();
      },
    );
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: const Library(),
      home: const MainView(),
      themeMode: ThemeMode.system,
      theme: currentTheme,
    );
  }
}
