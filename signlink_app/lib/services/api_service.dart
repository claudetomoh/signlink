import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Central HTTP client for the SignLink REST API.
///
/// Usage:
///   final data = await ApiService.instance.post('/auth/login.php', {...});
///   await ApiService.instance.setToken(data['token']);
class ApiService {
  static const String baseUrl =
      'http://169.239.251.102:280/~tomoh.ikfingeh/uploads/api';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _tokenKey = 'sl_api_token';

  String? _token;

  static final ApiService instance = ApiService._();
  ApiService._();

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // ── Token management ──────────────────────────────────────────────────────

  /// Load persisted token from secure storage. Call once on app start.
  Future<void> init() async {
    _token = await _storage.read(key: _tokenKey);
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
  }

  // ── HTTP helpers ──────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? params,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }
    final resp = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));
    return _handle(resp);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final resp = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _handle(resp);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? params,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }
    final resp = await http
        .put(uri, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _handle(resp);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? params,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }
    final resp = await http
        .delete(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));
    return _handle(resp);
  }

  // ── Response handler ─────────────────────────────────────────────────────

  Map<String, dynamic> _handle(http.Response resp) {
    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      // Non-JSON response
    }
    if (resp.statusCode >= 200 && resp.statusCode < 300) return data;
    final msg = data['error'] as String? ?? 'Request failed (${resp.statusCode})';
    throw ApiException(msg, resp.statusCode);
  }
}

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;
  @override
  String toString() => 'ApiException($statusCode): $message';
}
