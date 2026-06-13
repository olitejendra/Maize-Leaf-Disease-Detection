import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': createdAt,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        phone: map['phone'] ?? '',
        createdAt: map['createdAt'],
      );
}

class AuthResult {
  final bool success;
  final String? error;
  final UserModel? user;

  const AuthResult({required this.success, this.error, this.user});
}

class AuthService {
  static const _keyLoggedIn = 'is_logged_in';
  static const _keyUser = 'current_user';
  static const _keyUsers = 'registered_users';

  // ── Check if user is already logged in ─────────────────────────────────────
  static Future<UserModel?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    if (!isLoggedIn) return null;
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return null;
    return UserModel.fromMap(jsonDecode(userJson));
  }

  // ── Register new user ───────────────────────────────────────────────────────
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing users
    final usersJson = prefs.getString(_keyUsers);
    final List<Map<String, dynamic>> users = usersJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(usersJson))
        : [];

    // Check if email already exists
    final exists = users.any(
        (u) => (u['email'] as String).toLowerCase() == email.toLowerCase());
    if (exists) {
      return const AuthResult(
          success: false, error: 'An account with this email already exists.');
    }

    // Create new user
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    // Save password alongside user (simple local storage — replace with backend in prod)
    final userRecord = user.toMap();
    userRecord['password'] = password; // hashed in production!
    users.add(userRecord);

    await prefs.setString(_keyUsers, jsonEncode(users));

    // Auto login after register
    await _saveSession(prefs, user);

    return AuthResult(success: true, user: user);
  }

  // ── Login ───────────────────────────────────────────────────────────────────
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString(_keyUsers);
    if (usersJson == null) {
      return const AuthResult(
          success: false, error: 'No account found. Please register first.');
    }

    final List<Map<String, dynamic>> users =
        List<Map<String, dynamic>>.from(jsonDecode(usersJson));

    final match = users.where((u) =>
        (u['email'] as String).toLowerCase() == email.trim().toLowerCase() &&
        u['password'] == password);

    if (match.isEmpty) {
      return const AuthResult(
          success: false, error: 'Incorrect email or password.');
    }

    final user = UserModel.fromMap(match.first);
    await _saveSession(prefs, user);

    return AuthResult(success: true, user: user);
  }

  // ── Logout ──────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyUser);
  }

  // ── Save session ────────────────────────────────────────────────────────────
  static Future<void> _saveSession(
      SharedPreferences prefs, UserModel user) async {
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUser, jsonEncode(user.toMap()));
  }
}
