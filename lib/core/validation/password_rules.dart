/// Shared password policy used by registration and password reset flows.
///
/// The current PCJ API requires at least eight characters and at least one
/// numeric character. Keeping the rule here prevents the forms from drifting
/// apart when the backend policy changes.
abstract final class PasswordRules {
  static const int minimumLength = 8;

  static bool hasMinimumLength(String value) =>
      value.length >= minimumLength;

  static bool hasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);

  static bool isValid(String value) =>
      hasMinimumLength(value) && hasNumber(value);

  static String? validationMessage(String value) {
    if (!hasMinimumLength(value)) {
      return 'Password must contain at least $minimumLength characters.';
    }
    if (!hasNumber(value)) {
      return 'Password must contain at least one number.';
    }
    return null;
  }
}
