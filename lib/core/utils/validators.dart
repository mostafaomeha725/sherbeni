class Validators {
  static String? requiredField(String? value, {required String fieldLabel}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldLabel';
    }
    return null;
  }

  static String? email(
    String? value, {
    bool required = true,
    String emptyMessage = 'Please enter your email',
    String invalidMessage = 'Please enter a valid email',
  }) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return required ? emptyMessage : null;
    }

    if (!isValidEmail(email)) {
      return invalidMessage;
    }

    return null;
  }

  static String? password(
    String? value, {
    bool required = true,
    int minLength = 1,
    String emptyMessage = 'Please enter your password',
    String? minLengthMessage,
  }) {
    final password = value?.trim() ?? '';

    if (password.isEmpty) {
      return required ? emptyMessage : null;
    }

    if (password.length < minLength) {
      return minLengthMessage ??
          'Password must be at least $minLength characters';
    }

    return null;
  }

  static String? confirmPassword(
    String? value, {
    required String originalPassword,
    String emptyMessage = 'Please confirm your password',
    String mismatchMessage = 'Passwords do not match',
  }) {
    final confirmPassword = value?.trim() ?? '';

    if (confirmPassword.isEmpty) {
      return emptyMessage;
    }

    if (confirmPassword != originalPassword.trim()) {
      return mismatchMessage;
    }

    return null;
  }

  static bool isValidSimpleEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  static bool isValidInternationalPhoneNumber(String value) {
    return RegExp(r'^\+[1-9]\d{8,14}$').hasMatch(value);
  }

  /// Validates Egyptian phone number (without country code)
  /// Must be 11 digits starting with 010, 011, 012, or 015
  static bool isValidEgyptianPhoneNumber(String value) {
    return RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(value);
  }

  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z]\w*([_.-]\w*)?@[a-zA-Z\d]+([.-][a-zA-Z\d]+)*\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  static bool isNotValidEmail(String email) => !isValidEmail(email);

  static bool isValidPassword(String password) {
    return RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9].*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
    ).hasMatch(password);
  }

  static bool isNotValidPassword(String password) => !isValidPassword(password);

  // static bool isNotValidPhone(String phone) {
  //   // if (phone.length < 8 || phone.length > 12) {
  //   //   return true;
  //   // }

  //   return RegExp("(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9].*[0-9])(?=.*[^a-zA-Z0-9]).{8,}")
  //       .hasMatch(phone);
  // }

  static bool isPhoneNumberValid(String phoneNumber, String countryCode) {
    switch (countryCode) {
      case '+966' || '966': // Saudi (Done)
        return RegExp(
          r'^(50|53|54|55|56|57|58|59)[0-9]{7}$',
        ).hasMatch(phoneNumber);
      case '+971' || '971': // Emirates (Done)
        return RegExp(
          r'^((?:[1-9]|0(?=[1-9]))[0-9]{8})$',
        ).hasMatch(phoneNumber);
      case '+965' || '965': // Kuwait (Done)
        return RegExp(r'^(5|6|9)[0-9]{7}$').hasMatch(phoneNumber);
      case '+974' || '974': // Qatar (Done)
        return RegExp(
          r'^(33|44|55|66|77|88|99)[0-9]{6}$',
        ).hasMatch(phoneNumber);
      case '+973' || '973': // Bahrain (Done)
        return RegExp(r'^(3|4|6|8|9)[0-9]{7}$').hasMatch(phoneNumber);
      case '+962' || '962': // Jordan
        // 789434343
        // 795454545
        return RegExp(r'^(7[789]\d{7})$').hasMatch(phoneNumber);
      case '+20' || '20': // Egypt
        return RegExp(r'^(10|11|12|15)[0-9]{8}$').hasMatch(phoneNumber);
      default:
        return false;
    }
  }

  static List<String> getPasswordValidationErrors(String password) {
    List<String> errors = [];

    if (password.length < 8) {
      errors.add(PasswordConditions.minLength);
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add(PasswordConditions.upperCase);
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add(PasswordConditions.lowerCase);
    }

    if (!RegExp(r'[0-9!@#\$&*~]').hasMatch(password)) {
      errors.add(PasswordConditions.numberOrSymbol);
    }

    return errors;
  }
}

class PasswordConditions {
  static const String minLength =
      'Password must be at least 8 characters long.';
  static const String upperCase =
      'Password must contain at least one uppercase letter.';
  static const String lowerCase =
      'Password must contain at least one lowercase letter.';
  static const String numberOrSymbol =
      'Password must contain at least two numbers or symbols.';
}
