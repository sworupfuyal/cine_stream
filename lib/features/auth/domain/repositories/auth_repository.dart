import 'package:cine_stream/core/error/failures.dart';
import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> registerUser(AuthEntity user);
  Future<Either<Failure, AuthEntity>> loginUser(String userName, String password);
}