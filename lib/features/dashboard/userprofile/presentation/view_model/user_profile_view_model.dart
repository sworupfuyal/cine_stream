import 'package:cine_stream/features/dashboard/userprofile/domain/usecases/get_user_profile_usecase.dart';
import 'package:cine_stream/features/dashboard/userprofile/domain/usecases/update_user_profile_usecase.dart';
import 'package:cine_stream/features/dashboard/userprofile/presentation/state/user_profile_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileViewModelProvider =
    NotifierProvider<UserProfileViewModel, UserProfileState>(
      () => UserProfileViewModel(),
    );

class UserProfileViewModel extends Notifier<UserProfileState> {
  late final GetUserProfileUsecase _getUserProfileUsecase;
  late final UpdateUserProfileUsecase _updateUserProfileUsecase;

  @override
  UserProfileState build() {
    _getUserProfileUsecase = ref.read(getUserProfileUsecaseProvider);
    _updateUserProfileUsecase =
        ref.read(updateUserProfileUsecaseProvider);

    return UserProfileState();
  }

  Future<void> getUserProfile() async {
    state = state.copyWith(status: UserProfileStatus.loading);

    final result = await _getUserProfileUsecase.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (profileData) {
        state = state.copyWith(
          status: UserProfileStatus.loaded,
          profile: profileData,
        );
      },
    );
  }

  Future<void> updateProfile(
    UpdateUserProfileUsecaseParams data,
  ) async {
    state = state.copyWith(status: UserProfileStatus.loading);

    final result = await _updateUserProfileUsecase.call(data);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (updatedProfile) async {
        state = state.copyWith(
          status: UserProfileStatus.updated,
          profile: updatedProfile,
        );

        // Refresh profile after update
        await getUserProfile();
      },
    );
  }
}
