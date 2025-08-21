import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

part 'offline_storage_helper.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get password => text()();
  BoolColumn get isLoggedIn => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      try {
        await m.createAll();
      } catch (e) {
        debugPrint('Error creating database: $e');
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'bytelogik_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (result) {
          if (result.missingFeatures.isNotEmpty) {
            debugPrint(
              'Using ${result.chosenImplementation} due to unsupported '
              'browser features: ${result.missingFeatures}',
            );
          }
        },
      ),
    );
  }
}

class OfflineStorageHelper {
  static final OfflineStorageHelper _instance =
      OfflineStorageHelper._internal();
  factory OfflineStorageHelper() => _instance;
  OfflineStorageHelper._internal();

  static OfflineStorageHelper get instance => _instance;

  final AppDatabase _db = AppDatabase();


  Future<void> insertUser({
    required String id,
    required String name,
    required String email,
    required String password,
    bool isLogin = false,
  }) async {
    await _db
        .into(_db.users)
        .insertOnConflictUpdate(
          UsersCompanion.insert(
            id: id,
            name: name,
            email: email,
            password: password,
            isLoggedIn: Value(isLogin),
          ),
        );
  }

  Future<Map<String, dynamic>?> getLoggedInUser() async {
    final user = await (_db.select(
      _db.users,
    )..where((u) => u.isLoggedIn.equals(true))).getSingleOrNull();
    if (user == null) return null;

    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'isLogin': user.isLoggedIn,
    };
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    final user = await (_db.select(
      _db.users,
    )..where((u) => u.id.equals(id))).getSingleOrNull();
    if (user == null) return null;

    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'isLogin': user.isLoggedIn,
    };
  }

  Future<Map<String, dynamic>?> getUserByEmailAndPassword(
    String email,
    String password,
  ) async {
    final user =
        await (_db.select(_db.users)..where(
              (u) => u.email.equals(email) & u.password.equals(password),
            ))
            .getSingleOrNull();
    if (user == null) return null;

    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'isLogin': user.isLoggedIn,
    };
  }

  Future<bool> userExists(String email) async {
    final user = await (_db.select(
      _db.users,
    )..where((u) => u.email.equals(email))).getSingleOrNull();
    return user != null;
  }

  Future<void> setLoginStateById({
    required String id,
    required bool isLogin,
  }) async {
    await (_db.update(_db.users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(isLoggedIn: Value(isLogin)),
    );
  }

  Future<void> clearAllLoginFlags() async {
    await _db
        .update(_db.users)
        .write(const UsersCompanion(isLoggedIn: Value(false)));
  }

  Future<Map<String, dynamic>?> getAnyUser() async {
    final user = await (_db.select(_db.users)..limit(1)).getSingleOrNull();
    if (user == null) return null;

    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'isLogin': user.isLoggedIn,
    };
  }

  void close() {
    _db.close();
  }
}
