class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = "http://10.0.2.2:6050/api/auth";

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);


  // ==========Auth endpoints ======
  static const String register = "/register";
  static const String login = "/login";
}