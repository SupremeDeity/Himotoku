// temp solution

// ignore_for_file: file_names, non_constant_identifier_names

import 'package:yomu/Extensions/asura.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:yomu/Extensions/manganato.dart';
import 'package:yomu/Extensions/reaperscans.dart';

Map<String, Extension> ExtensionsMap = {
  Asura().name: Asura(),
  ReaperScans().name: ReaperScans(),
  Manganato().name: Manganato()
};
