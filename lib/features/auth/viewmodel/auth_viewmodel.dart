import 'package:bytelogik/core/model/user_model.dart';
import 'package:bytelogik/core/provider/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  bool _checked = false;
  @override
  AsyncValue<UserModel?> build() {
    if (!_checked) {
      _checked = true;
      Future.microtask(() async {
        await _checkLocalUser();
      });
    }
    return const AsyncValue.data(null);
  }

  Future<void> _checkLocalUser() async {
    state = const AsyncValue.loading();
    await ref.read(userNotifierProvider.notifier).loadAnyUser();
    final userModel = ref.read(userNotifierProvider).user;
    if (userModel == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = AsyncValue.data(userModel);
  }

  Future<bool> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final notifier = ref.read(userNotifierProvider.notifier);
    await notifier.addUser(email: email, password: password, name: name);

    final userModel = ref.read(userNotifierProvider).user;
    if (userModel == null) {
      state = AsyncValue.error('Failed to create user', StackTrace.current);
      return false;
    }


    final user = name.isNotEmpty
        ? UserModel(
            id: userModel.id,
            name: name,
            email: userModel.email,
            password: userModel.password,
          )
        : userModel;

    state = AsyncValue.data(user);
    return true;
  }

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final notifier = ref.read(userNotifierProvider.notifier);
    final ok = await notifier.login(email: email, password: password);
    if (!ok) {
      state = AsyncValue.error('Invalid email or password', StackTrace.current);
      return false;
    }

    final userModel = ref.read(userNotifierProvider).user;
    if (userModel == null) {
      state = AsyncValue.error('Failed to load user', StackTrace.current);
      return false;
    }

    state = AsyncValue.data(userModel);
    return true;
  }
}
