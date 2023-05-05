// ignore_for_file: constant_identifier_names, non_constant_identifier_names,

import 'package:flutter/cupertino.dart';
import 'package:himotoku/Data/models/Setting.dart';

enum APP_ERROR {
  SOURCE_SEARCH_NOT_SUPPORTED,
  SOURCE_HOST_ERROR,
  CHAPTER_NO_PAGES,
}

var APP_ICON = Image.asset(
  "assets/splash.png",
  height: 64,
  width: 64,
);

var APP_ICON_LIGHT = Image.asset(
  "assets/splash-light.png",
  height: 64,
  width: 64,
);

var APP_REPO_RELEASE = "https://github.com/SupremeDeity08/himotoku/releases";

const ISAR_INSTANCE_NAME = "himotokuDBInstance";
const DEFAULT_LIBRARY_SORT = LibrarySort.az;
