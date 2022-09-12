// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;

import '../Extensions/extension.dart' as _i7;
import '../Pages/explore.dart' as _i2;
import '../Pages/library.dart' as _i1;
import '../Pages/settings.dart' as _i3;
import '../Pages/source_explore.dart' as _i4;

class YomuRouter extends _i5.RootStackRouter {
  YomuRouter([_i6.GlobalKey<_i6.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i5.PageFactory> pagesMap = {
    Library.name: (routeData) {
      return _i5.CustomPage<dynamic>(
          routeData: routeData,
          child: const _i1.Library(),
          opaque: true,
          barrierDismissible: false);
    },
    Explore.name: (routeData) {
      return _i5.CustomPage<dynamic>(
          routeData: routeData,
          child: const _i2.Explore(),
          opaque: true,
          barrierDismissible: false);
    },
    Settings.name: (routeData) {
      return _i5.CustomPage<dynamic>(
          routeData: routeData,
          child: const _i3.Settings(),
          opaque: true,
          barrierDismissible: false);
    },
    SourceExplore.name: (routeData) {
      final args = routeData.argsAs<SourceExploreArgs>();
      return _i5.CustomPage<dynamic>(
          routeData: routeData,
          child: _i4.SourceExplore(args.extension, key: args.key),
          opaque: true,
          barrierDismissible: false);
    }
  };

  @override
  List<_i5.RouteConfig> get routes => [
        _i5.RouteConfig(Library.name, path: '/'),
        _i5.RouteConfig(Explore.name, path: '/Explore'),
        _i5.RouteConfig(Settings.name, path: '/Settings'),
        _i5.RouteConfig(SourceExplore.name, path: '/source-explore')
      ];
}

/// generated route for
/// [_i1.Library]
class Library extends _i5.PageRouteInfo<void> {
  const Library() : super(Library.name, path: '/');

  static const String name = 'Library';
}

/// generated route for
/// [_i2.Explore]
class Explore extends _i5.PageRouteInfo<void> {
  const Explore() : super(Explore.name, path: '/Explore');

  static const String name = 'Explore';
}

/// generated route for
/// [_i3.Settings]
class Settings extends _i5.PageRouteInfo<void> {
  const Settings() : super(Settings.name, path: '/Settings');

  static const String name = 'Settings';
}

/// generated route for
/// [_i4.SourceExplore]
class SourceExplore extends _i5.PageRouteInfo<SourceExploreArgs> {
  SourceExplore({required _i7.Extension extension, _i6.Key? key})
      : super(SourceExplore.name,
            path: '/source-explore',
            args: SourceExploreArgs(extension: extension, key: key));

  static const String name = 'SourceExplore';
}

class SourceExploreArgs {
  const SourceExploreArgs({required this.extension, this.key});

  final _i7.Extension extension;

  final _i6.Key? key;

  @override
  String toString() {
    return 'SourceExploreArgs{extension: $extension, key: $key}';
  }
}
