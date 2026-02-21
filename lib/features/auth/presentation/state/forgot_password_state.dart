enum ForgotPasswordStatus { initial, loading, emailSent, resetting, success, error }

class ForgotPasswordState {
  final ForgotPasswordStatus status;
  final String? error;
  final String? email; // keep email to pass to reset screen

  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.error,
    this.email,
  });

  bool get isLoading =>
      status == ForgotPasswordStatus.loading ||
      status == ForgotPasswordStatus.resetting;

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? error,
    String? email,
  }) =>
      ForgotPasswordState(
        status: status ?? this.status,
        error: error ?? this.error,
        email: email ?? this.email,
      );
}