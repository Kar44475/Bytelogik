import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OfflineStorageHelper {
  static final OfflineStorageHelper _instance =
      OfflineStorageHelper._internal();
  static Database? _database;

  OfflineStorageHelper._internal();

  factory OfflineStorageHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_details.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
   //   onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        is_login INTEGER DEFAULT 0,
        created_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');
  }


  Future<void> insertUser({
    required String id,
    required String name,
    required String email,
    required String password,
    bool isLogin = false,
  }) async {
    final db = await database;
    await db.insert('users', {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'is_login': isLogin ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Set login flag for the given user id (1 = logged in, 0 = logged out)
  Future<void> setLoginStateById({
    required String id,
    required bool isLogin,
  }) async {
    final db = await database;
    await db.update(
      'users',
      {'is_login': isLogin ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear login flag for all users (useful to ensure single active login)
  Future<void> clearAllLoginFlags() async {
    final db = await database;
    await db.update('users', {'is_login': 0});
  }


  Future<Map<String, dynamic>?> getLoggedInUser() async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'is_login = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    final db = await database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<bool> userExists(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserByEmailAndPassword(
    String email,
    String password,
  ) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }


  Future<Map<String, dynamic>?> getAnyUser() async {
    final db = await database;
    final results = await db.query('users', limit: 1);
    if (results.isNotEmpty) return results.first;
    return null;
  }

}
