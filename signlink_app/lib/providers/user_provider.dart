import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  final _api = ApiService.instance;

  List<UserModel> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get studentCount => _users.where((u) => u.role == 'student').length;
  int get interpreterCount => _users.where((u) => u.role == 'interpreter').length;

  Future<void> loadUsers({String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (role != null && role.isNotEmpty) params['role'] = role;
      final data = await _api.get('/users/list.php', params: params.isEmpty ? null : params);
      final list = data['users'] as List<dynamic>;
      _users = list
          .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = 'Failed to load users.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> suspendUser(String userId, {required bool suspend}) async {
    try {
      await _api.put(
        '/users/update.php',
        {'is_suspended': suspend},
        params: {'id': userId},
      );
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users = List.from(_users)
          ..[idx] = _users[idx].copyWith(isSuspended: suspend);
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _api.delete('/users/delete.php', params: {'id': userId});
      _users = _users.where((u) => u.id != userId).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
