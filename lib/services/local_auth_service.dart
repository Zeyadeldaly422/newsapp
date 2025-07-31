import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:news_app/models/user_model.dart';

class LocalAuthService {
  static const _usersListKey = 'users_list';
  static const _currentUserKey = 'current_user_id';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  String _generateSalt() {
    return const Uuid().v4();
  }

  String _hashPassword(String password, String salt) {
    var key = utf8.encode(password + salt);
    var bytes = sha256.convert(key);
    return bytes.toString();
  }

  Future<List<User>> _getUsers() async {
    final prefs = await _prefs;
    final usersJson = prefs.getStringList(_usersListKey) ?? [];
    return usersJson
        .map((userStr) => User.fromJson(jsonDecode(userStr)))
        .toList();
  }

  Future<void> _saveUsers(List<User> users) async {
    final prefs = await _prefs;
    final usersJson =
        users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList(_usersListKey, usersJson);
  }

  Future<bool> isUserExists(String email) async {
    final users = await _getUsers();
    return users.any((user) => user.email == email);
  }

  Future<User?> register(Map<String, dynamic> userData) async {
    final users = await _getUsers();
    if (await isUserExists(userData['email'])) {
      throw Exception('Email already exists');
    }

    final salt = _generateSalt();
    final passwordHash = _hashPassword(userData['password'], salt);
    
    final newUser = User(
      id: const Uuid().v4(),
      firstName: userData['firstName'],
      lastName: userData['lastName'],
      email: userData['email'],
      passwordHash: passwordHash,
      salt: salt,
      createdAt: DateTime.now(),
    );

    users.add(newUser);
    await _saveUsers(users);
    await _prefs.setString(_currentUserKey, newUser.id);
    return newUser;
  }

  Future<User?> login(String email, String password) async {
    final users = await _getUsers();
    final user = users.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );

    final passwordHash = _hashPassword(password, user.salt!);
    if (passwordHash == user.passwordHash) {
      final prefs = await _prefs;
      await prefs.setString(_currentUserKey, user.id);
      return user;
    } else {
      throw Exception('Invalid password');
    }
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_currentUserKey);
  }
  
  Future<User?> getCurrentUser() async {
    final prefs = await _prefs;
    final userId = prefs.getString(_currentUserKey);
    if (userId == null) return null;

    final users = await _getUsers();
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  Future<User?> updateUserProfile(Map<String, dynamic> userData) async {
    final users = await _getUsers();
    final userId = (await _prefs).getString(_currentUserKey);
    if (userId == null) throw Exception('No user logged in');

    final index = users.indexWhere((user) => user.id == userId);
    if (index == -1) throw Exception('User not found');

    final currentUser = users[index];
    final updatedUser = currentUser.copyWith(
      firstName: userData['firstName'] ?? currentUser.firstName,
      lastName: userData['lastName'] ?? currentUser.lastName,
      email: userData['email'] ?? currentUser.email,
    );

    users[index] = updatedUser;
    await _saveUsers(users);
    return updatedUser;
  }

  Future<User?> changePassword(String currentPassword, String newPassword) async {
    final users = await _getUsers();
    final userId = (await _prefs).getString(_currentUserKey);
    if (userId == null) throw Exception('No user logged in');

    final index = users.indexWhere((user) => user.id == userId);
    if (index == -1) throw Exception('User not found');

    final currentUser = users[index];
    final currentPasswordHash = _hashPassword(currentPassword, currentUser.salt!);
    if (currentPasswordHash != currentUser.passwordHash) {
      throw Exception('Current password is incorrect');
    }

    final newSalt = _generateSalt();
    final newPasswordHash = _hashPassword(newPassword, newSalt);
    final updatedUser = currentUser.copyWith(
      passwordHash: newPasswordHash,
      salt: newSalt,
    );

    users[index] = updatedUser;
    await _saveUsers(users);
    return updatedUser;
  }

  Future<void> resetPassword(String email) async {
    final users = await _getUsers();
    final user = users.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );
    // Simulate sending reset link (requires backend for real implementation)
    print('Password reset link sent to ${user.email}');
  }
}

extension on Future<SharedPreferences> {
  Future<void> setString(String currentUserKey, String id) async {}
}