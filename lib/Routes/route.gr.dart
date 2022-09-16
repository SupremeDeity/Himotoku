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
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;

import '../Data/Manga.dart' as _i9;
import '../Extensions/extension.dart' as _i8;
import '../Pages/explore.dart' as _i2;
import '../Pages/library.dart' as _i1;
import '../Pages/manga_view.dart' as _i5;
import '../Pages/settings.dart' as _i3;
import '../Pages/source_explore.dart' as _i4;

class YomuRouter extends _i6.RootStackRouter {
  YomuRouter([_i7.GlobalKey<_i7.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i6.PageFactory> pagesMap = {
    Library.name: (routeData) {
      return _i6.CustomPage<dynamic>(
          routeData: routeData,
          child: const _i1.Library(),
          opaque: true,
          barrierDismissible: false);
    },
    Explore.name: (routeData) {
      return _i6.CustomPage<dynamic>(
          routeData: routeData,
          child: const _i2.Explore(),
          opaque: true,
          barrierDismissible: false);
    },
    Settings.name: (routeData) {
      return _i6.CustomPage<dynamic>(
          routeData: routeData,
          child: const _i3.Settings(),
          opaque: true,
          barrierDismissible: false);
    },
    SourceExplore.name: (routeData) {
      final args = routeData.argsAs<SourceExploreArgs>();
      return _i6.CustomPage<dynamic>(
          routeData: routeData,
          child: _i4.SourceExplore(args.extension, key: args.key),
          opaque: true,
          barrierDismissible: false);
    },
    MangaView.name: (routeData) {
      final args = routeData.argsAs<MangaViewArgs>();
      return _i6.CustomPage<dynamic>(
          routeData: routeData,
          child: _i5.MangaView(args.mangaInstance, key: args.key),
          opaque: true,
          barrierDismissible: false);
    }
  };

  @override
  List<_i6.RouteConfig> get routes => [
        _i6.RouteConfig(Library.name, path: '/'),
        _i6.RouteConfig(Explore.name, path: '/Explore'),
        _i6.RouteConfig(Settings.name, path: '/Settings'),
        _i6.RouteConfig(SourceExplore.name, path: '/source-explore'),
        _i6.RouteConfig(MangaView.name, path: '/manga-view')
      ];
}

/// generated route for
/// [_i1.Library]
class Library extends _i6.PageRouteInfo<void> {
  const Library() : super(Library.name, path: '/');

  static const String name = 'Library';
}

/// generated route for
/// [_i2.Explore]
class Explore extends _i6.PageRouteInfo<void> {
  const Explore() : super(Explore.name, path: '/Explore');

  static const String name = 'Explore';
}

/// generated route for
/// [_i3.Settings]
class Settings extends _i6.PageRouteInfo<void> {
  const Settings() : super(Settings.name, path: '/Settings');

  static const String name = 'Settings';
}

/// generated route for
/// [_i4.SourceExplore]
class SourceExplore extends _i6.PageRouteInfo<SourceExploreArgs> {
  SourceExplore({required _i8.Extension extension, _i7.Key? key})
      : super(SourceExplore.name,
            path: '/source-explore',
            args: SourceExploreArgs(extension: extension, key: key));

  static const String name = 'SourceExplore';
}

class SourceExploreArgs {
  const SourceExploreArgs({required this.extension, this.key});

  final _i8.Extension extension;

  final _i7.Key? key;

  @override
  String toString() {
    return 'SourceExploreArgs{extension: $extension, key: $key}';
  }
}

/// generated route for
/// [_i5.MangaView]
class MangaView extends _i6.PageRouteInfo<MangaViewArgs> {
  MangaView({required _i9.Manga mangaInstance, _i7.Key? key})
      : super(MangaView.name,
            path: '/manga-view',
            args: MangaViewArgs(mangaInstance: mangaInstance, key: key));

  static const String name = 'MangaView';
}

class MangaViewArgs {
  const MangaViewArgs({required this.mangaInstance, this.key});

  final _i9.Manga mangaInstance;

  final _i7.Key? key;

  @override
  String toString() {
    return 'MangaViewArgs{mangaInstance: $mangaInstance, key: $key}';
  }
}
