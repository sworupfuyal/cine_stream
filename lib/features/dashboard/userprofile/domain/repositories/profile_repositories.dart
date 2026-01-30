import 'dart:io';

import 'package:cine_stream/core/error/failures.dart';
import 'package:cine_stream/features/dashboard/userprofile/domain/entities/profile_entity.dart';
import 'package:dartz/dartz.dart';


abstract interface class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getUserDetails();
  Future<Either<Failure, ProfileEntity>> updateUser(ProfileEntity updatedUser,File? image);
}