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
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;

import '../Data/Manga.dart' as _i10;
import '../Extensions/extension.dart' as _i9;
import '../Pages/explore.dart' as _i2;
import '../Pages/library.dart' as _i1;
import '../Pages/manga_view.dart' as _i5;
import '../Pages/settings.dart' as _i3;
import '../Pages/source_explore.dart' as _i4;
import '../Widgets/Library/ChapterListView.dart' as _i6;

class YomuRouter extends _i7.RootStackRouter {
  YomuRouter([_i8.GlobalKey<_i8.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i7.PageFactory> pagesMap = {
    Library.name: (routeData) {
      return _i7.CustomPage<dynamic>(
          routeData: routeData,
          child: const _i1.Library(),
          opaque: true,
          barrierDismissible: false);
    },
    Explore.name: (routeData) {
      return _i7.CustomPage<dynamic>(
          routeData: routeData,
          child: const _i2.Explore(),
          opaque: true,
          barrierDismissible: false);
    },
    Settings.name: (routeData) {
      return _i7.CustomPage<dynamic>(
          routeData: routeData,
          child: const _i3.Settings(),
          opaque: true,
          barrierDismissible: false);
    },
    SourceExplore.name: (routeData) {
      final args = routeData.argsAs<SourceExploreArgs>();
      return _i7.CustomPage<dynamic>(
          routeData: routeData,
          child: _i4.SourceExplore(args.extension, key: args.key),
          opaque: true,
          barrierDismissible: false);
    },
    MangaView.name: (routeData) {
      final args = routeData.argsAs<MangaViewArgs>();
      return _i7.CustomPage<dynamic>(
          routeData: routeData,
          child: _i5.MangaView(args.mangaInstance, key: args.key),
          opaque: true,
          barrierDismissible: false);
    },
    ChapterListView.name: (routeData) {
      final args = routeData.argsAs<ChapterListViewArgs>();
      return _i7.CustomPage<dynamic>(
          routeData: routeData,
          child:
              _i6.ChapterListView(args.manga, args.chapterIndex, key: args.key),
          opaque: true,
          barrierDismissible: false);
    }
  };

  @override
  List<_i7.RouteConfig> get routes => [
        _i7.RouteConfig(Library.name, path: '/'),
        _i7.RouteConfig(Explore.name, path: '/Explore'),
        _i7.RouteConfig(Settings.name, path: '/Settings'),
        _i7.RouteConfig(SourceExplore.name, path: '/source-explore'),
        _i7.RouteConfig(MangaView.name, path: '/manga-view'),
        _i7.RouteConfig(ChapterListView.name, path: '/chapter-list-view')
      ];
}

/// generated route for
/// [_i1.Library]
class Library extends _i7.PageRouteInfo<void> {
  const Library() : super(Library.name, path: '/');

  static const String name = 'Library';
}

/// generated route for
/// [_i2.Explore]
class Explore extends _i7.PageRouteInfo<void> {
  const Explore() : super(Explore.name, path: '/Explore');

  static const String name = 'Explore';
}

/// generated route for
/// [_i3.Settings]
class Settings extends _i7.PageRouteInfo<void> {
  const Settings() : super(Settings.name, path: '/Settings');

  static const String name = 'Settings';
}

/// generated route for
/// [_i4.SourceExplore]
class SourceExplore extends _i7.PageRouteInfo<SourceExploreArgs> {
  SourceExplore({required _i9.Extension extension, _i8.Key? key})
      : super(SourceExplore.name,
            path: '/source-explore',
            args: SourceExploreArgs(extension: extension, key: key));

  static const String name = 'SourceExplore';
}

class SourceExploreArgs {
  const SourceExploreArgs({required this.extension, this.key});

  final _i9.Extension extension;

  final _i8.Key? key;

  @override
  String toString() {
    return 'SourceExploreArgs{extension: $extension, key: $key}';
  }
}

/// generated route for
/// [_i5.MangaView]
class MangaView extends _i7.PageRouteInfo<MangaViewArgs> {
  MangaView({required _i10.Manga mangaInstance, _i8.Key? key})
      : super(MangaView.name,
            path: '/manga-view',
            args: MangaViewArgs(mangaInstance: mangaInstance, key: key));

  static const String name = 'MangaView';
}

class MangaViewArgs {
  const MangaViewArgs({required this.mangaInstance, this.key});

  final _i10.Manga mangaInstance;

  final _i8.Key? key;

  @override
  String toString() {
    return 'MangaViewArgs{mangaInstance: $mangaInstance, key: $key}';
  }
}

/// generated route for
/// [_i6.ChapterListView]
class ChapterListView extends _i7.PageRouteInfo<ChapterListViewArgs> {
  ChapterListView(
      {required _i10.Manga manga, required int chapterIndex, _i8.Key? key})
      : super(ChapterListView.name,
            path: '/chapter-list-view',
            args: ChapterListViewArgs(
                manga: manga, chapterIndex: chapterIndex, key: key));

  static const String name = 'ChapterListView';
}

class ChapterListViewArgs {
  const ChapterListViewArgs(
      {required this.manga, required this.chapterIndex, this.key});

  final _i10.Manga manga;

  final int chapterIndex;

  final _i8.Key? key;

  @override
  String toString() {
    return 'ChapterListViewArgs{manga: $manga, chapterIndex: $chapterIndex, key: $key}';
  }
}
