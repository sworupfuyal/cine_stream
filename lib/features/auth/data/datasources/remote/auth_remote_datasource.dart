import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:cine_stream/core/api/app_client.dart';
import 'package:cine_stream/core/services/storage/token_service.dart';
import 'package:cine_stream/core/services/storage/user_session_service.dart';
import 'package:cine_stream/features/auth/data/datasources/auth_datasource.dart';
import 'package:cine_stream/features/auth/data/models/auth_api_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(apiClient: ref.read(apiClientProvider),userSessionService: ref.read(userSessionServiceProvider),tokenService: ref.read(tokenServiceProvider));
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({required ApiClient apiClient,required UserSessionService userSessionService,required TokenService tokenService}) : _apiClient = apiClient, _userSessionService = userSessionService, _tokenService = tokenService;

  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {"email": email, "password": password},
    );

if (response.data["success"] == true) {
      final userData = response.data["data"] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(userData);

      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        role: user.role!,
      );
      // save token
      final token = response.data["token"];
      await _tokenService.saveToken(token);

      return user;
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