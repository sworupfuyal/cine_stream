import 'dart:io';

import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:cine_stream/core/api/app_client.dart';
import 'package:cine_stream/core/services/storage/token_service.dart';
import 'package:cine_stream/features/dashboard/userprofile/data/datasources/user_profile_datasource.dart';
import 'package:cine_stream/features/dashboard/userprofile/data/models/profile_api_model.dart';
import 'package:dio/dio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileRemoteDatasourceProvider =
    Provider<UserProfileRemoteDatasource>((ref) {
      return UserProfileRemoteDatasource(
        apiClient: ref.read(apiClientProvider),
        tokenService: ref.read(tokenServiceProvider),
      );
    });

class UserProfileRemoteDatasource
    implements IUserProfileRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  UserProfileRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  @override
  Future<ProfileApiModel> updateProfile(
    ProfileApiModel data,
    File? image,
  ) async {
    final fileName = image?.path.split("/").last;
    final token = await _tokenService.getToken();

    final formData = FormData.fromMap({
      if (data.fullName != null) "fullName": data.fullName,
      if (data.email != null) "email": data.email,
      if (data.phoneNumber != null) "phoneNumber": data.phoneNumber,
      if (data.location != null) "userLocation": data.location,
      if (image != null)
        "profile_image": await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
    });

    final response = await _apiClient.updateFile(
      ApiEndpoints.updateProfile,
      formData: formData,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );

    return ProfileApiModel.fromJson(response.data);
  }

  @override
  Future<ProfileApiModel> getUserProfile() async {
    final token = await _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.getProfile,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );

    final data = response.data['data'];
    return ProfileApiModel.fromJson(data);
  }
}
