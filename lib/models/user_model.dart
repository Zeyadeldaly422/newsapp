import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? passwordHash;
  final String? salt;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? avatarUrl;
  final List<String>? favoriteCategories;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.passwordHash,
    this.salt,
    required this.createdAt,
    this.lastLoginAt,
    this.avatarUrl,
    this.favoriteCategories,
  });

  @override
  List<Object?> get props => [id, email];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'passwordHash': passwordHash,
      'salt': salt,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'favoriteCategories': favoriteCategories,
    };
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      passwordHash: map['passwordHash'],
      salt: map['salt'],
      createdAt: DateTime.parse(map['createdAt']),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'])
          : null,
      avatarUrl: map['avatarUrl'],
      favoriteCategories: map['favoriteCategories'] != null
          ? List<String>.from(map['favoriteCategories'])
          : null,
    );
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? passwordHash,
    String? salt,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? avatarUrl,
    List<String>? favoriteCategories,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
    );
  }
}