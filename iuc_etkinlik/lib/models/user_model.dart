/// Kullanıcı modeli
/// Uygulamadaki kullanıcı verilerini temsil eder
library;

/// Kullanıcı rolleri enum'u
enum UserRole {
  student('Student'),
  clubAdmin('Club Admin');

  final String displayName;
  const UserRole(this.displayName);

  /// String'den UserRole'e dönüştürme
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value || role.displayName == value,
      orElse: () => UserRole.student,
    );
  }
}

/// Kullanıcı modeli
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<String> joinedEventIds; // Katıldığı etkinlik ID'leri

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
    this.joinedEventIds = const [],
  });

  /// JSON'dan UserModel oluşturma (API response için)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      joinedEventIds: (json['joinedEventIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// UserModel'i JSON'a dönüştürme (API request için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'joinedEventIds': joinedEventIds,
    };
  }

  /// Kullanıcı bilgilerini güncelleme için copyWith
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    UserRole? role,
    String? avatarUrl,
    DateTime? createdAt,
    List<String>? joinedEventIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      joinedEventIds: joinedEventIds ?? this.joinedEventIds,
    );
  }

  /// Kullanıcının Club Admin olup olmadığını kontrol et
  bool get isClubAdmin => role == UserRole.clubAdmin;

  /// Kullanıcının Student olup olmadığını kontrol et
  bool get isStudent => role == UserRole.student;
}
