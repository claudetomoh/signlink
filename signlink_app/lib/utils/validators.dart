/// Validators — OWASP A03 (Injection) & A07 (Authentication Failures).
///
/// All rules are enforced on the client side for immediate UX feedback.
/// Server-side validation must ALWAYS duplicate these checks.
class Validators {
  // ── Email ─────────────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    // Basic RFC-5322 subset; also rejects injection chars like < > ;
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ── Password (OWASP A07 / NIST 800-63B) ──────────────────────────────────
  /// Minimum requirements:
  ///  • 8 characters
  ///  • At least one digit
  ///  • At least one uppercase letter
  ///  • At least one special character
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must include a number';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must include an uppercase letter';
    }
    // Match any common special/punctuation character
    if (!value.contains(RegExp(r'[!@#%^&*()\-_=+\[\]{};:,.<>?/\\|]'))) {
      return 'Password must include a special character (e.g. !@#%)';
    }
    return null;
  }

  // ── Confirm password ──────────────────────────────────────────────────────
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  // ── Generic ───────────────────────────────────────────────────────────────
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? minLength(
      String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  // ── Input sanitisation (OWASP A03 – Injection) ───────────────────────────
  /// Strips characters used in HTML/SQL injection from free-text user input.
  /// Use before persisting any user-supplied text.
  static String sanitize(String input) {
    // Remove HTML angle brackets and common SQL delimiters
    return input
        .replaceAll(RegExp(r'[<>]'), '')
        .replaceAll(RegExp('[;"\\\\/]'), '')
        .trim();
  }

  /// Returns `true` when [input] contains no dangerous injection characters.
  static bool isSafe(String? input) {
    if (input == null) return true;
    return !RegExp(r'[<>;"\\/]').hasMatch(input);
  }
}
