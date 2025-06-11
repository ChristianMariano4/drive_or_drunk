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

String formatChatTimestamp(DateTime dateTime) {
  final now = DateTime.now();

  // Se è oggi, mostra solo l'orario
  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // Se è nello stesso anno, ma non oggi, mostra giorno e mese
  if (dateTime.year == now.year) {
    return DateFormat('d MMM HH:mm').format(dateTime); // es: 18 mag 14:30
  }

  // Se è di un anno diverso, mostra anche l'anno
  return DateFormat('d MMM yyyy HH:mm').format(dateTime); // es: 18 mag 2023
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
