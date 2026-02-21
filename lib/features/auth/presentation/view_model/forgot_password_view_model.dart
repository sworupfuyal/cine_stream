import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:cine_stream/core/api/app_client.dart';
import 'package:cine_stream/features/auth/presentation/state/forgot_password_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';


final forgotPasswordViewModelProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordViewModel, ForgotPasswordState>(
  (ref) => ForgotPasswordViewModel(ref.read(apiClientProvider)),
);

class ForgotPasswordViewModel extends StateNotifier<ForgotPasswordState> {
  final ApiClient _apiClient;

  ForgotPasswordViewModel(this._apiClient)
      : super(const ForgotPasswordState());

  /// POST /api/auth/request-password-reset  { email }
  Future<void> sendResetEmail(String email) async {
    state = state.copyWith(
      status: ForgotPasswordStatus.loading,
      email: email.trim(),
    );

    try {
      final response = await _apiClient.post(
        ApiEndpoints.requestPasswordReset,
        data: {'email': email.trim()},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = state.copyWith(status: ForgotPasswordStatus.emailSent);
      } else {
        state = state.copyWith(
          status: ForgotPasswordStatus.error,
          error: data['message'] ?? 'Failed to send reset email',
        );
      }
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message']
          ?? 'Failed to send reset email';
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        error: msg,
      );
    }
  }

  /// POST /api/auth/reset-password/:token  { newPassword }
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(status: ForgotPasswordStatus.resetting);

    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.resetPassword}/${token.trim()}',
        data: {'newPassword': newPassword},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        state = state.copyWith(status: ForgotPasswordStatus.success);
      } else {
        state = state.copyWith(
          status: ForgotPasswordStatus.error,
          error: data['message'] ?? 'Failed to reset password',
        );
      }
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message']
          ?? 'Failed to reset password';
      state = state.copyWith(
        status: ForgotPasswordStatus.error,
        error: msg,
      );
    }
  }

  void resetState() => state = const ForgotPasswordState();
}