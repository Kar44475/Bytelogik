import 'package:bytelogik/core/model/user_model.dart';
import 'package:bytelogik/core/provider/database_provider.dart';
import 'package:bytelogik/core/storage/offline_storage_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user_provider.g.dart';

class UserState {
  final UserModel? user;
  final bool loading;
  final String? error;

  UserState({this.user, this.loading = false, this.error});

  UserState copyWith({UserModel? user, bool? loading, String? error}) {
    return UserState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

@Riverpod(keepAlive: true)
class UserNotifier extends _$UserNotifier {
  @override
  UserState build() {
    return UserState(user: null, loading: false, error: null);
  }

  OfflineStorageHelper get _db => ref.read(databaseProvider);

  Future<void> addUser({
    required String email,
    required String password,
    String name = '',
  }) async {
    state = state.copyWith(loading: true, error: null);
    final exists = await _db.userExists(email);
    if (exists) {
      state = state.copyWith(loading: false, error: 'User already exists');
      return;
    }
    final id = const Uuid().v4();
    await _db.clearAllLoginFlags();
    await _db.insertUser(
      id: id,
      name: name,
      email: email,
      password: password,
      isLogin: true,
    );
    final data = await _db.getUser(id);
    if (data == null) {
      state = state.copyWith(loading: false, user: null);
      return;
    }
    state = state.copyWith(loading: false, user: UserModel.fromMap(data));
  }

  Future<void> loadAnyUser() async {
    state = state.copyWith(loading: true, error: null);
    final data = await _db.getLoggedInUser() ?? await _db.getAnyUser();
    if (data == null) {
      state = state.copyWith(loading: false, user: null);
      return;
    }
    state = state.copyWith(loading: false, user: UserModel.fromMap(data));
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(loading: true, error: null);
    final data = await _db.getUserByEmailAndPassword(email, password);
    if (data == null) {
      state = state.copyWith(
        loading: false,
        error: 'Invalid email or password',
      );
      return false;
    }
    await _db.clearAllLoginFlags();
    await _db.setLoginStateById(id: data['id'], isLogin: true);
    final updated = await _db.getUser(data['id']);
    if (updated == null) {
      state = state.copyWith(loading: false, user: null);
      return false;
    }
    state = state.copyWith(loading: false, user: UserModel.fromMap(updated));
    return true;
  }

  Future<void> logout() async {
    await _db.clearAllLoginFlags();
    state = UserState(user: null, loading: false, error: null);
  }
}
