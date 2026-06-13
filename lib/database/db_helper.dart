import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'users.db');
    return openDatabase(path, version: 1, onCreate: (db, _) {
      db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT UNIQUE,
          password TEXT
        )
      ''');
    });
  }

  // Register
  static Future<bool> registerUser(
      String name, String email, String password) async {
    final db = await database;
    try {
      await db.insert('users', {
        'name': name,
        'email': email,
        'password': password, // hash this in production
      });
      return true;
    } catch (e) {
      return false; // email already exists
    }
  }

  // Login
  static Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
