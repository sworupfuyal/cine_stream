import 'dart:io';

import 'package:cine_stream/features/dashboard/userprofile/data/models/profile_api_model.dart';

abstract interface class IUserProfileRemoteDatasource {
  Future<ProfileApiModel> getUserProfile();
  Future<ProfileApiModel> updateProfile(ProfileApiModel data,File? image);
}