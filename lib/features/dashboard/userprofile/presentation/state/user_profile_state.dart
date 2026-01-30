import 'package:cine_stream/features/dashboard/userprofile/domain/entities/profile_entity.dart';
import 'package:equatable/equatable.dart';

enum UserProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  updated,
  error,
}

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
