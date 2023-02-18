/// Normalizes all dates to a single uniform format.
import 'package:jiffy/jiffy.dart';
import 'package:rechron/rechron.dart' as rechron;

String DateNormalize(String date, [String? format]) {
  final String pattern = "dd/MM/yyyy";
  // Try relative date parsing first
  DateTime? relativeDate = rechron.tryParse<DateTime>(date);

  // try parsing with normal date format with loose checking.
  if (relativeDate == null) {
    try {
      return Jiffy(date, format).format(pattern);
    } catch (e) {
      return "";
    }
  }
  return Jiffy(relativeDate).format(pattern);
}
