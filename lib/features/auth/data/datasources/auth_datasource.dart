import 'package:cine_stream/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDatasource{
  Future<bool> registerUser(AuthHiveModel user);
  Future<AuthHiveModel?> loginUser(String userName, String password);
}