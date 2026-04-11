class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'student' | 'interpreter' | 'admin'
  final String? profilePhoto;
  final String? phone;
  final bool isActive;
  final bool isSuspended;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.profilePhoto,
    this.phone,
    this.isActive = true,
    this.isSuspended = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String,
        fullName: map['full_name'] as String,
        email: map['email'] as String,
        role: map['role'] as String,
        profilePhoto: map['profile_photo'] as String?,
        phone: map['phone'] as String?,
        isActive: (map['is_active'] as bool?) ?? true,
      );

  /// Construct from the REST API JSON response.
  /// API fields: id, name, email, role, avatar_url, isActive, isSuspended, languages
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as String,
        fullName: j['name'] as String,
        email: j['email'] as String,
        role: j['role'] as String,
        profilePhoto: j['avatar_url'] as String?,
        phone: j['phone'] as String?,
        isActive: (j['isActive'] as bool?) ?? true,
        isSuspended: (j['isSuspended'] as bool?) ?? false,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'profile_photo': profilePhoto,
        'phone': phone,
        'is_active': isActive,
      };

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    String? profilePhoto,
    String? phone,
    bool? isActive,
    bool? isSuspended,
  }) =>
      UserModel(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        role: role ?? this.role,
        profilePhoto: profilePhoto ?? this.profilePhoto,
        phone: phone ?? this.phone,
        isActive: isActive ?? this.isActive,
        isSuspended: isSuspended ?? this.isSuspended,
      );
}
