import 'dart:io';

import 'package:cine_stream/core/error/failures.dart';
import 'package:cine_stream/core/usecases/app_usecases.dart';
import 'package:cine_stream/features/dashboard/userprofile/data/repositories/user_profile_repository.dart';
import 'package:cine_stream/features/dashboard/userprofile/domain/entities/profile_entity.dart';
import 'package:cine_stream/features/dashboard/userprofile/domain/repositories/profile_repositories.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateUserProfileUsecaseParams {
  final String? fullName;
  final String? email;
  final String? location;
  final String? phoneNumber;
  final String? profileImageUrl;
  final File? profileImage;

  UpdateUserProfileUsecaseParams({
    this.fullName,
    this.email,
    this.location,
    this.phoneNumber,
    this.profileImageUrl,
    this.profileImage,
  });
}

final updateUserProfileUsecaseProvider =
    Provider<UpdateUserProfileUsecase>((ref) {
      return UpdateUserProfileUsecase(
        profileRepository: ref.read(userProfileRepositoryProvider),
      );
    });

class UpdateUserProfileUsecase
    implements
        UsecaseWithParams<ProfileEntity, UpdateUserProfileUsecaseParams> {
  final IProfileRepository _profileRepository;

  UpdateUserProfileUsecase({
    required IProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  @override
  Future<Either<Failure, ProfileEntity>> call(
    UpdateUserProfileUsecaseParams params,
  ) {
    final entity = ProfileEntity(
      fullName: params.fullName,
      email: params.email,
      location: params.location,
      phoneNumber: params.phoneNumber,
      profileImage: params.profileImageUrl,
    );

    return _profileRepository.updateUser(
      entity,
      params.profileImage,
    );
  }
}
