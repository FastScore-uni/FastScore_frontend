class Validators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) return 'To pole jest wymagane';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Podaj email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Błędny format emaila';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) return 'Hasło musi mieć min. 6 znaków';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.length < 9) return 'Podaj poprawny numer';
    return null;
  }
}