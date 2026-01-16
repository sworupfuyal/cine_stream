
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
  required String fullName,
  required String email,
  required String password,
  required String confirmPassword,
}) async {
  state = state.copyWith(status: AuthStatus.loading);
  final params = RegisterUsecasesParam(
    fullName: fullName,
    email: email,
    password: password,
    confirmPassword: confirmPassword,
  );
  final result = await _registerUsecase.call(params);
  
  print('Result type: ${result.runtimeType}'); // Add this
  
  result.fold(
    (failure) {
      print('FAILURE BRANCH: ${failure.toString()}'); // Add this
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Registration Failed',
      );
    },
    (success) {
      print('SUCCESS BRANCH'); // Add this
      state = state.copyWith(status: AuthStatus.registered);
    },
  );
}

  // Login
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecasesParams(email: email, password: password);
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