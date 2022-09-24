// temp solution

import 'package:yomu/Extensions/asura.dart';
import 'package:yomu/Extensions/extension.dart';
import 'package:yomu/Extensions/manganato.dart';
import 'package:yomu/Extensions/reaperscans.dart';

Map<String, Extension> ExtensionsMap = {
  Asura().name: Asura(),
  ReaperScans().name: ReaperScans(),
  Manganato().name: Manganato()
};
