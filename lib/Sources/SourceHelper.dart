// temp solution

// ignore_for_file: , non_constant_identifier_names

import 'package:yomu/Sources/asura.dart';
import 'package:yomu/Sources/Source.dart';
import 'package:yomu/Sources/manganato.dart';
import 'package:yomu/Sources/reaperscans.dart';

Map<String, Source> SourcesMap = {
  Asura().name: Asura(),
  ReaperScans().name: ReaperScans(),
  Manganato().name: Manganato()
};
