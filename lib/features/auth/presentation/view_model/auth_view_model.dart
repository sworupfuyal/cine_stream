import 'package:cine_stream/features/auth/domain/usecases/login_usecases.dart';
import 'package:cine_stream/features/auth/domain/usecases/register_usecases.dart';
import 'package:cine_stream/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecases;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecases = ref.read(loginUsecasesProvider);
    return AuthState();
  }

  // Register
  Future<void> register({
    required String userName,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = RegisterUsecasesParam(
      userName: userName,
      password: password,
    );
    final result = await _registerUsecase.call(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Registration Failed',
        );
      },
      (success) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

  // Login
  Future<void> login({required String userName, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecasesParams(userName: userName, password: password);
    final result = await _loginUsecases.call(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Login Failed',
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }
}