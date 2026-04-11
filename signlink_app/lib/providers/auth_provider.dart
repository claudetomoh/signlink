import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isLockedOut = false;
  Duration? _lockoutRemaining;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  String get role => _currentUser?.role ?? '';
  bool get isLockedOut => _isLockedOut;
  Duration? get lockoutRemaining => _lockoutRemaining;

  final _authService = AuthService();

  Future<bool> login(String email, String password) async {
    // OWASP A07 — check lockout before attempting authentication
    final locked = await SecurityService.isLockedOut();
    if (locked) {
      _lockoutRemaining = await SecurityService.getLockoutRemaining();
      _isLockedOut = true;
      final mins = (_lockoutRemaining?.inMinutes ?? 0) + 1;
      _error = 'Too many failed attempts. Try again in $mins minute(s).';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _isLockedOut = false;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        // OWASP A02 / M9 — persist session in encrypted storage
        await SecurityService.saveSession(userId: user.id, role: user.role);
        await SecurityService.clearLoginAttempts(email);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // OWASP A07 — record failure and enforce lockout
        await SecurityService.recordFailedLogin(email);
        final nowLocked = await SecurityService.isLockedOut();
        if (nowLocked) {
          _lockoutRemaining = await SecurityService.getLockoutRemaining();
          _isLockedOut = true;
          final mins = (_lockoutRemaining?.inMinutes ?? 0) + 1;
          _error = 'Too many failed attempts. Account locked for $mins minute(s).';
        } else {
          _error = 'Invalid email or password. Please try again.';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    // OWASP A02 / M9 — wipe encrypted session on logout
    await SecurityService.clearSession();
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.forgotPassword(email);
    _isLoading = false;
    notifyListeners();
    return result;
  }

  /// Update the current user's profile photo with a local [filePath] from
  /// the camera or image gallery.
  void updateProfilePhoto(String filePath) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(profilePhoto: filePath);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
