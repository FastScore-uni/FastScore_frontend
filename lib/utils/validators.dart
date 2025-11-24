class Validators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) return 'To pole jest wymagane';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Podaj email';
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value)) return 'Błędny format emaila';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hasło jest wymagane';
    }
    const int minLength = 8;
    if (value.length < minLength) {
      return 'Hasło musi mieć co najmniej 8 znaków';
    }
    final RegExp digitRegex = RegExp(r'[0-9]');
    final RegExp lowerCaseRegex = RegExp(r'[a-z]');
    final RegExp upperCaseRegex = RegExp(r'[A-Z]');
    final RegExp specialCharRegex = RegExp(r'''[!@#\$%^&*()_+=\{\}\[\]\|:;<>.,?/~`'"-]''');

    if (!digitRegex.hasMatch(value)){
      return 'Hasło musi zawierać przynajmniej 1 cyfrę';
    }
    if (!lowerCaseRegex.hasMatch(value)){
      return 'Hasło musi zawierać przynajmniej 1 małą literę';
    }
    if (!upperCaseRegex.hasMatch(value)){
      return 'Hasło musi zawierać przynajmniej 1 wielką literę';
    }
    if (!specialCharRegex.hasMatch(value)){
      return 'Hasło musi zawierać przynajmniej 1 znak specjalny';
    }

    return null;

  }

  static String? confirmPassword(String? value, String passwordToMatch) {
    if (value == null || value.isEmpty) {
      return 'To pole jest wymagane.';
    }
    if (value != passwordToMatch) {
      return 'Hasła nie są identyczne!';
    }
    return null;
  }
}