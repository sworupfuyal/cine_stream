class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = "http://10.0.2.2:6050";

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String register = "/api/auth/register";
  static const String login = "/api/auth/login";

  // User profile endpoints
  static const String getProfile = "/api/user/getProfile";
  static const String updateProfile = "/api/user/updateProfile";  // PATCH
}

