import 'package:cine_stream/core/error/failures.dart';
import 'package:cine_stream/core/services/connectivity/network_info.dart';
import 'package:cine_stream/features/auth/data/datasources/auth_datasource.dart';
import 'package:cine_stream/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:cine_stream/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:cine_stream/features/auth/data/models/auth_api_model.dart';
import 'package:cine_stream/features/auth/data/models/auth_hive_model.dart';
import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';
import 'package:cine_stream/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authDatasource: ref.read(authLocalDatasourceProvider),
    authRemoteDatasource: ref.read(authRemoteProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authDatasource = authDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> loginUser(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _authRemoteDatasource.loginUser(email, password);
        if (user != null) {
          return right(user.toEntity());
        }
        return left(ServerFailure(message: "loginfailed"));
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data["message"] ?? "Login failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authDatasource.loginUser(email, password);
        if (user != null) {
          final entity = user.toEntity();
          return Right(entity);
        }
        return Left(
          LocalDatabaseFailure(message: "Email or password is incorrect"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  // @override
  // Future<Either<Failure, bool>> registerUser(AuthEntity user) async {
  //   try{
  //     final model = AuthHiveModel.fromEntity(user);
  //     final result = await _authDatasource.registerUser(model);
  //     if(result.success){
  //       return Right(true);
  //     }
  //     return Left(LocalDatabaseFailure(message: "Failed to register user"));
  //   }catch(e){
  //     return Left(LocalDatabaseFailure(message: e.toString()));
  //   }
  // }

  @override
  Future<Either<Failure, bool>> registerUser(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      // remote
      try {
        final apimodel = AuthApiModel.fromEntity(user);
        await _authRemoteDatasource.registerUser(apimodel);
        return Right(true);
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data["message"] ?? "Registration Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final model = AuthHiveModel.fromEntity(user);
        await _authDatasource.registerUser(model);
        return const Right(true);
      } on HiveError catch (e) {
        return Left(LocalDatabaseFailure(message: e.message));
      } catch (e) {
        return Left(
          LocalDatabaseFailure(message: "Unexpected error: ${e.toString()}"),
        );
      }
    }
  }
}