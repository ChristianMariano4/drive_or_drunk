import 'package:intl/intl.dart';

String getLocalizedMonth(DateTime date, {String locale = 'en'}) {
  return DateFormat.MMM(locale).format(date); // Jan, Feb, ...
  // Use 'MMMM' for full month names like January, February, etc.
}

String getLocalizedDate(DateTime date, {String locale = 'en'}) {
  return DateFormat.yMMMMEEEEd(locale).format(date); // January 2023
}

String getLocalizedDateInNumberFormat(DateTime date, {String locale = 'en'}) {
  return DateFormat.yMd(locale).format(date); // 1/1/2023
}
