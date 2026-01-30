import 'package:cine_stream/core/error/failures.dart';
import 'package:cine_stream/core/usecases/app_usecases.dart';
import 'package:cine_stream/features/dashboard/userprofile/data/repositories/user_profile_repository.dart';
import 'package:cine_stream/features/dashboard/userprofile/domain/entities/profile_entity.dart';
import 'package:cine_stream/features/dashboard/userprofile/domain/repositories/profile_repositories.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final getUserProfileUsecaseProvider = Provider<GetUserProfileUsecase>(
  (ref) {
    return GetUserProfileUsecase(
      profileRepository: ref.read(userProfileRepositoryProvider),
    );
  },
);

class GetUserProfileUsecase implements UseecaseWithoutParams {
  final IProfileRepository _profileRepository;

  const GetUserProfileUsecase({
    required IProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  @override
  Future<Either<Failure, ProfileEntity>> call() async {
    return await _profileRepository.getUserDetails();
  }
}
