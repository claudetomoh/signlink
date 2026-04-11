import '../models/user_model.dart';
import 'api_service.dart';

/// AuthService — backed by the real REST API.
class AuthService {
  final _api = ApiService.instance;

  // POST /api/auth/login.php
  Future<UserModel?> login(String email, String password) async {
    final data = await _api.post('/auth/login.php', {
      'email': email,
      'password': password,
    });
    final token = data['token'] as String;
    await _api.setToken(token);
    final userJson = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  // POST /api/auth/register.php
  Future<UserModel?> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final data = await _api.post('/auth/register.php', {
      'name': fullName,
      'email': email,
      'password': password,
      'role': role,
    });
    final token = data['token'] as String;
    await _api.setToken(token);
    final userJson = data['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  // POST /api/auth/logout.php
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout.php', {});
    } finally {
      await _api.clearToken();
    }
  }

  // POST /api/auth/forgot-password  (endpoint placeholder — returns true if accepted)
  Future<bool> forgotPassword(String email) async {
    try {
      await _api.post('/auth/forgot_password.php', {'email': email});
      return true;
    } on ApiException {
      return false;
    }
  }
}
