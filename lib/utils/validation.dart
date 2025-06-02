class Validation {
  // Empty Text Validation

  static String? validateEmptyText(String? fieldname, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldname is required.';
    }
    return null;
  }

  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  // Date
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your date of birth';
    }

    // Verifica formato: DD/MM/YYYY
    final regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    if (!regex.hasMatch(value)) {
      return 'Invalid date format';
    }

    final match = regex.firstMatch(value);
    final day = int.tryParse(match!.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);

    try {
      final date = DateTime(year!, month!, day!);

      // Controllo validità effettiva del giorno/mese/anno
      if (date.day != day || date.month != month || date.year != year) {
        return 'Invalid calendar date';
      }

      // Controllo età minima (13 anni)
      final today = DateTime.now();
      final minDate = DateTime(today.year - 13, today.month, today.day);
      if (date.isAfter(minDate)) {
        return 'You must be at least 13 years old';
      }

      return null; // valido
    } catch (_) {
      return 'Invalid date';
    }
  }
}
