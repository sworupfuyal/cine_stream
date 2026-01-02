import 'package:cine_stream/core/error/failures.dart';
import 'package:cine_stream/core/usecases/app_usecases.dart';
import 'package:cine_stream/features/auth/data/repositories/auth_repository.dart';
import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';
import 'package:cine_stream/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterUsecasesParam extends Equatable {
  final String userName;
  final String password;

  const RegisterUsecasesParam({
    required this.userName,
    required this.password,
  });
  @override
  List<Object?> get props => [userName , password, ];
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
      userName: params.userName,
      password: params.password,
    );

    return _authRepository.registerUser(entity);
  }


}