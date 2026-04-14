import 'package:flutter_test/flutter_test.dart';
import 'package:signlink_app/models/user_model.dart';

void main() {
  const _apiJson = <String, dynamic>{
    'id': 'usr-1',
    'name': 'Alice Smith',
    'email': 'alice@example.com',
    'role': 'student',
    'avatar_url': 'https://example.com/pic.jpg',
    'phone': '+1234567890',
    'isActive': true,
    'isSuspended': false,
  };

  const _dbMap = <String, dynamic>{
    'id': 'usr-2',
    'full_name': 'Bob Jones',
    'email': 'bob@example.com',
    'role': 'interpreter',
    'profile_photo': 'https://example.com/bob.jpg',
    'phone': '+9876543210',
    'is_active': true,
  };

  group('UserModel.fromJson', () {
    test('parses all fields from API JSON', () {
      final u = UserModel.fromJson(_apiJson);
      expect(u.id, 'usr-1');
      expect(u.fullName, 'Alice Smith');
      expect(u.email, 'alice@example.com');
      expect(u.role, 'student');
      expect(u.profilePhoto, 'https://example.com/pic.jpg');
      expect(u.phone, '+1234567890');
      expect(u.isActive, true);
      expect(u.isSuspended, false);
    });

    test('defaults isActive to true when absent', () {
      final j = Map<String, dynamic>.from(_apiJson)..remove('isActive');
      expect(UserModel.fromJson(j).isActive, true);
    });

    test('defaults isSuspended to false when absent', () {
      final j = Map<String, dynamic>.from(_apiJson)..remove('isSuspended');
      expect(UserModel.fromJson(j).isSuspended, false);
    });

    test('profilePhoto is null when absent', () {
      final j = Map<String, dynamic>.from(_apiJson)..remove('avatar_url');
      expect(UserModel.fromJson(j).profilePhoto, isNull);
    });

    test('phone is null when absent', () {
      final j = Map<String, dynamic>.from(_apiJson)..remove('phone');
      expect(UserModel.fromJson(j).phone, isNull);
    });

    test('parses interpreter role correctly', () {
      final j = Map<String, dynamic>.from(_apiJson)..['role'] = 'interpreter';
      expect(UserModel.fromJson(j).role, 'interpreter');
    });

    test('parses admin role correctly', () {
      final j = Map<String, dynamic>.from(_apiJson)..['role'] = 'admin';
      expect(UserModel.fromJson(j).role, 'admin');
    });

    test('suspended user has isSuspended true', () {
      final j = Map<String, dynamic>.from(_apiJson)..['isSuspended'] = true;
      expect(UserModel.fromJson(j).isSuspended, true);
    });
  });

  group('UserModel.fromMap', () {
    test('parses snake_case map fields', () {
      final u = UserModel.fromMap(_dbMap);
      expect(u.id, 'usr-2');
      expect(u.fullName, 'Bob Jones');
      expect(u.email, 'bob@example.com');
      expect(u.role, 'interpreter');
      expect(u.profilePhoto, 'https://example.com/bob.jpg');
      expect(u.phone, '+9876543210');
      expect(u.isActive, true);
      expect(u.isSuspended, false); // not in fromMap — defaults to false
    });

    test('isActive defaults to true when absent from map', () {
      final m = Map<String, dynamic>.from(_dbMap)..remove('is_active');
      expect(UserModel.fromMap(m).isActive, true);
    });
  });

  group('UserModel.toMap', () {
    test('encodes using snake_case keys', () {
      final u = UserModel.fromJson(_apiJson);
      final m = u.toMap();
      expect(m['id'], 'usr-1');
      expect(m['full_name'], 'Alice Smith');
      expect(m['email'], 'alice@example.com');
      expect(m['role'], 'student');
      expect(m['profile_photo'], 'https://example.com/pic.jpg');
    });
  });

  group('UserModel.copyWith', () {
    test('replaces only the specified fields', () {
      final u = UserModel.fromJson(_apiJson);
      final updated = u.copyWith(fullName: 'New Name', isSuspended: true);
      expect(updated.fullName, 'New Name');
      expect(updated.isSuspended, true);
      expect(updated.id, u.id);
      expect(updated.email, u.email);
    });

    test('keeps original values when no fields specified', () {
      final u = UserModel.fromJson(_apiJson);
      final copy = u.copyWith();
      expect(copy.id, u.id);
      expect(copy.fullName, u.fullName);
      expect(copy.role, u.role);
    });
  });
}
