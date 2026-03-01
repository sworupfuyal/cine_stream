import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // ─────────────────────────────────────────────────────────────
  // Configuration
  // ─────────────────────────────────────────────────────────────
  static const bool isPhysicalDevice = true; // set true for real device
  static const String _ipAddress = '192.168.1.93'; // your local machine IP
  static const int _port = 6050;

  // Host Resolution
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;

    if (kIsWeb || Platform.isIOS) return 'localhost';

    if (Platform.isAndroid) return '10.0.2.2'; // Android emulator

    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => serverUrl;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ─────────────────────────────────────────────────────────────
  // Auth Endpoints
  // ─────────────────────────────────────────────────────────────
  static String get register => "$baseUrl/api/auth/register";
  static String get login => "$baseUrl/api/auth/login";

  // ─────────────────────────────────────────────────────────────
  // User Profile Endpoints
  // ─────────────────────────────────────────────────────────────
  static String get getProfile => "$baseUrl/api/user/getProfile";
  static String get updateProfile => "$baseUrl/api/user/updateProfile";

  // ─────────────────────────────────────────────────────────────
  // Movies (Public)
  // ─────────────────────────────────────────────────────────────
  static String get getMovies => "$baseUrl/api/movies";
  static String get getGenres => "$baseUrl/api/movies/genres/list";

  // ─────────────────────────────────────────────────────────────
  // User Lists
  // ─────────────────────────────────────────────────────────────
  static String get userLists => "$baseUrl/api/user/lists";
  static String get userListCounts => "$baseUrl/api/user/lists/counts";
  static String get userListStatus => "$baseUrl/api/user/lists/status";

  static String movieReviews(String movieId) => '/api/reviews/$movieId';


   // ── Password Reset ───────────────────────────────────────────────────────────
  // POST /api/auth/request-password-reset  → { email }
  // POST /api/auth/reset-password/:token   → { newPassword }
  static const String requestPasswordReset = "/api/auth/request-password-reset";
  static const String resetPassword = "/api/auth/reset-password";
  // usage: '${ApiEndpoints.resetPassword}/$token'
}