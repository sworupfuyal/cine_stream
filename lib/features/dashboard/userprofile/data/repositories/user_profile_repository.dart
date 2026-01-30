import 'dart:io';

import 'package:cine_stream/core/error/failures.dart';
import 'package:cine_stream/features/dashboard/userprofile/data/datasources/user_profile_datasource.dart';
import 'package:cine_stream/features/dashboard/userprofile/data/datasources/remote/user_profile_remotedatasource.dart';
import 'package:cine_stream/features/dashboard/userprofile/data/models/profile_api_model.dart';
import 'package:cine_stream/features/dashboard/userprofile/domain/entities/profile_entity.dart';
import 'package:cine_stream/features/dashboard/userprofile/domain/repositories/profile_repositories.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileRepositoryProvider =
    Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(
    userProfileRemoteDatasource: ref.read(
      userProfileRemoteDatasourceProvider,
    ),
  );
});

class UserProfileRepository implements IProfileRepository {
  final IUserProfileRemoteDatasource _userProfileRemoteDatasource;

  UserProfileRepository({
    required IUserProfileRemoteDatasource userProfileRemoteDatasource,
  }) : _userProfileRemoteDatasource = userProfileRemoteDatasource;

  @override
  Future<Either<Failure, ProfileEntity>> getUserDetails() async {
    try {
      final response =
          await _userProfileRemoteDatasource.getUserProfile();
      return Right(response.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateUser(
    ProfileEntity updatedUser,
    File? image,
  ) async {
    try {
      final newData = ProfileApiModel.fromEntity(updatedUser);
      final response = await _userProfileRemoteDatasource.updateProfile(
        newData,
        image,
      );
      return Right(response.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
