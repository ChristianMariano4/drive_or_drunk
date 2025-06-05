import 'package:intl/intl.dart';

String getLocalizedMonth(DateTime date, {String locale = 'en'}) {
  return DateFormat.MMM(locale).format(date); // Jan, Feb, ...
  // Use 'MMMM' for full month names like January, February, etc.
}

String getLocalizedDate(DateTime date, {String locale = 'en'}) {
  return DateFormat.MMMMEEEEd(locale).format(date); // January 2023
}

String getLocalizedDateInNumberFormat(DateTime date, {String locale = 'en'}) {
  return DateFormat('dd/MM/yyyy', locale).format(date); // 01/01/2023
}

String getMonthString(int month) {
  const months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];
  return months[month - 1]; // Adjust for 0-based index
}

String getDayString(int day) {
  const days = ['01', '02', '03', '04', '05', '06', '07', '08', '09'];

  if (day < 10) {
    return days[day - 1];
  } else {
    return day.toString();
  }
}
