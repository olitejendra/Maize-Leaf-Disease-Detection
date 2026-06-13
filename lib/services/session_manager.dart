import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Call after successful login
  static Future<void> saveSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', user['id']);
    await prefs.setString('userName', user['name']);
    await prefs.setString('userEmail', user['email']);
  }

  // Check on app start
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Call on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
