import 'package:auto_route/auto_route.dart';
import 'package:yomu/Pages/explore.dart';
import 'package:yomu/Pages/library.dart';
import 'package:yomu/Pages/settings.dart';
import 'package:yomu/Pages/source_explore.dart';

@CustomAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(
      page: Library,
      initial: true,
      maintainState: true,
    ),
    AutoRoute(
      page: Explore,
      maintainState: true,
    ),
    AutoRoute(
      page: Settings,
      maintainState: true,
    ),
    AutoRoute(
      page: SourceExplore,
      maintainState: true,
    ),
  ],
  replaceInRouteName: 'Page,Route',
)
class $YomuRouter {}
