import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});

class TokenService {
  static const String _tokenKey = 'auth_token';
  final _storage = const FlutterSecureStorage(); // ✅ same as interceptor

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }
}