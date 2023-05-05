// temp solution

// ignore_for_file: , non_constant_identifier_names

import 'package:himotoku/Sources/Source.dart';
import 'package:himotoku/Sources/multisource/asura.dart';
import 'package:himotoku/Sources/manganato.dart';
import 'package:himotoku/Sources/reaperscans.dart';

List<Source> sourcesList = [Asura(), ReaperScans(), Manganato(), FlameScans()];

Map<String, Source> SourcesMap = Map.fromIterable(
  sourcesList,
  key: (element) => element.name,
  value: (element) => element,
);
