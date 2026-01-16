import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:cine_stream/core/api/app_client.dart';
import 'package:cine_stream/features/auth/data/datasources/auth_datasource.dart';
import 'package:cine_stream/features/auth/data/models/auth_api_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );

    if (response.data["success"] == true) {
      final userData = response.data["data"] as Map<String, dynamic>;
      return AuthApiModel.fromJson(userData);
    }
    return null;
  }

  @override
  Future<AuthApiModel> registerUser(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data["success"] == true) {
      final userData = response.data["data"] as Map<String, dynamic>;
      return AuthApiModel.fromJson(userData);
    }
    return user;
  }
}