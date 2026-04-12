import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SecurityService — OWASP hardening for SignLink.
///
/// Covers:
///  • A02 / M9  – Cryptographic Failures / Insecure Data Storage
///               Session tokens stored in Android EncryptedSharedPreferences
///               (or localStorage on web where SubtleCrypto requires HTTPS).
///  • A07 / M3  – Identification & Authentication Failures
///               Enforces account lockout after [_maxAttempts] failed logins.
///  • A09       – Security Logging & Monitoring
///               Structured log of all authentication events.
class SecurityService {
  SecurityService._();

  static final _log = Logger('SecurityService');

  // ── Encrypted storage (native only) ──────────────────────────────────────
  static const _secureStorage = FlutterSecureStorage(
    // Android: use EncryptedSharedPreferences (AES-256)
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    // iOS: store in Keychain
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Unified read/write (uses SharedPreferences on web) ───────────────────
  static Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  static Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      return _secureStorage.read(key: key);
    }
  }

  static Future<void> _delete(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  // ── Storage keys ─────────────────────────────────────────────────────────
  static const _keyUserId = 'sl_user_id';
  static const _keyUserRole = 'sl_user_role';
  static const _keyLoginAttempts = 'sl_login_attempts';
  static const _keyLockoutUntil = 'sl_lockout_until';

  // ── Rate-limiting config ──────────────────────────────────────────────────
  /// Maximum failed logins before lockout (OWASP A07).
  static const int _maxAttempts = 5;

  /// Lockout duration in minutes after exceeding [_maxAttempts].
  static const int _lockoutMinutes = 15;

  // ── Session management ────────────────────────────────────────────────────

  /// Persist a successful session securely.
  static Future<void> saveSession({
    required String userId,
    required String role,
  }) async {
    await _write(_keyUserId, userId);
    await _write(_keyUserRole, role);
    _log.info('Session saved for userId=$userId role=$role');
  }

  /// Read the stored session. Returns null values if no session exists.
  static Future<Map<String, String?>> readSession() async {
    return {
      'userId': await _read(_keyUserId),
      'role': await _read(_keyUserRole),
    };
  }

  /// Wipe all session data on logout.
  static Future<void> clearSession() async {
    await _delete(_keyUserId);
    await _delete(_keyUserRole);
    _log.info('Session cleared');
  }

  // ── Rate limiting / account lockout ───────────────────────────────────────

  /// Returns `true` when the account is currently locked out (OWASP A07).
  static Future<bool> isLockedOut() async {
    final lockoutStr = await _read(_keyLockoutUntil);
    if (lockoutStr == null) return false;
    final lockoutUntil = DateTime.tryParse(lockoutStr);
    if (lockoutUntil == null) return false;
    final locked = DateTime.now().isBefore(lockoutUntil);
    if (!locked) {
      // lockout expired — clean up
      await _delete(_keyLockoutUntil);
    }
    return locked;
  }

  /// Returns the remaining lockout [Duration], or `null` if not locked out.
  static Future<Duration?> getLockoutRemaining() async {
    final lockoutStr = await _read(_keyLockoutUntil);
    if (lockoutStr == null) return null;
    final lockoutUntil = DateTime.tryParse(lockoutStr);
    if (lockoutUntil == null) return null;
    final remaining = lockoutUntil.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Records one failed login attempt.
  /// Triggers a [_lockoutMinutes]-minute lockout after [_maxAttempts] failures.
  static Future<void> recordFailedLogin(String email) async {
    final attemptsStr = await _read(_keyLoginAttempts);
    int attempts = int.tryParse(attemptsStr ?? '0') ?? 0;
    attempts++;
    _log.warning('Failed login attempt $attempts/$_maxAttempts for $email');

    if (attempts >= _maxAttempts) {
      final lockoutUntil =
          DateTime.now().add(Duration(minutes: _lockoutMinutes));
      await _write(_keyLockoutUntil, lockoutUntil.toIso8601String());
      await _write(_keyLoginAttempts, '0');
      _log.warning(
          'Account locked out until $lockoutUntil after $_maxAttempts failed attempts');
    } else {
      await _write(_keyLoginAttempts, attempts.toString());
    }
  }

  /// Clears the failed-attempt counter on a successful login.
  static Future<void> clearLoginAttempts(String email) async {
    await _delete(_keyLoginAttempts);
    await _delete(_keyLockoutUntil);
    _log.info('Login successful – attempts cleared for $email');
  }
}
