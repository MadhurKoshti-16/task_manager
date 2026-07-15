abstract final class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9.!#$%&'
    '*+/=?^_`{|}~-]+'
    r'@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$',
  );

  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email address is required.';
    }

    if (!_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required.';
    }

    if (password.length < 8) {
      return 'Password must contain at least 8 characters.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Add at least one lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Add at least one number.';
    }

    return null;
  }

  static String? confirmPassword({
    required String? value,
    required String password,
  }) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Confirm your password.';
    }

    if (confirmPassword != password) {
      return 'Passwords do not match.';
    }

    return null;
  }
}
