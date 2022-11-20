// temp solution

// ignore_for_file: , non_constant_identifier_names

import 'package:himotoku/Sources/asura.dart';
import 'package:himotoku/Sources/Source.dart';
import 'package:himotoku/Sources/manganato.dart';
import 'package:himotoku/Sources/reaperscans.dart';

Map<String, Source> SourcesMap = {
  Asura().name: Asura(),
  ReaperScans().name: ReaperScans(),
  Manganato().name: Manganato()
};
