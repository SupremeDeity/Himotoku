import 'package:jiffy/jiffy.dart';
import 'package:rechron/rechron.dart' as rechron;

const String pattern = "dd/MM/yyyy";

/// Normalizes all dates to a single uniform format.
DateTime? DateNormalize(String date, [String? format]) {
  // Try relative date parsing first
  DateTime? relativeDate = rechron.tryParse<DateTime>(date);

  // try parsing with normal date format with loose checking.
  if (relativeDate == null) {
    try {
      return Jiffy.parse(date, pattern: format).dateTime;
    } catch (e) {
      return null;
    }
  }
  return Jiffy.parseFromDateTime(relativeDate).dateTime;
}

String DateTimeToString(DateTime? dt) {
  try {
    return Jiffy.parseFromDateTime(dt!).format(pattern: pattern);
  } catch (e) {
    return "";
  }
}
