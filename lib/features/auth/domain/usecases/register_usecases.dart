import 'package:cine_stream/core/error/failures.dart';
import 'package:cine_stream/core/usecases/app_usecases.dart';
import 'package:cine_stream/features/auth/data/repositories/auth_repository.dart';
import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';
import 'package:cine_stream/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterUsecasesParam extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterUsecasesParam({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
  @override
  List<Object?> get props => [fullName, email, password, confirmPassword];
}


// Provider for register usecase
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecasesParam> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecasesParam params) {
    final entity= AuthEntity(
      fullName: params.fullName,
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );

    return _authRepository.registerUser(entity);
  }


}