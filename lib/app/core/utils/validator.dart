class DValidator {
  DValidator._();

  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return 'Email is required';
    }

    // TLD of 2+ letters (so .in, .com, .online, .shop all work); '+' allowed in name
    final emailRegExp = RegExp(r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,}$');

    if (!emailRegExp.hasMatch(v)) {
      return 'Invalid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegExp = RegExp(r'^\d{10}$');

    if (!phoneRegExp.hasMatch(v)) {
      return 'Invalid phone number format (10 digits required)';
    }

    return null;
  }

  /// Person / place names: letters, spaces and . ' -  (no digits).
  /// e.g. validateName('First name', value)
  static String? validateName(String? fieldName, String? value,
      {int minLength = 2}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName is required';
    if (v.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    if (!RegExp(r"^[A-Za-z][A-Za-z .'\-]*$").hasMatch(v)) {
      return '$fieldName can contain only letters';
    }
    return null;
  }

  /// Street address: required, at least [minLength] characters.
  static String? validateAddress(String? value, {int minLength = 5}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Address is required';
    if (v.length < minLength) return 'Enter a complete address';
    return null;
  }

  /// Indian PIN code: 6 digits, first digit 1-9.
  static String? validatePinCode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'PIN code is required';
    if (!RegExp(r'^[1-9]\d{5}$').hasMatch(v)) {
      return 'Enter a valid 6-digit PIN code';
    }
    return null;
  }
}