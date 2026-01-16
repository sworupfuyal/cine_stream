
import 'package:cine_stream/core/services/hive/hive_service.dart';
import 'package:cine_stream/features/auth/data/datasources/auth_datasource.dart';
import 'package:cine_stream/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<AuthHiveModel> registerUser(AuthHiveModel user) async {
    try {
      await _hiveService.registerUser(user);
      return user;
    } catch (e) {
      rethrow;
    }
  }
}