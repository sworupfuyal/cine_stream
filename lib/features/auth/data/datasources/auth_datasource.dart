import 'package:cine_stream/features/auth/data/models/auth_api_model.dart';
import 'package:cine_stream/features/auth/data/models/auth_hive_model.dart';


abstract interface class IAuthLocalDatasource {
  Future<AuthHiveModel> registerUser(AuthHiveModel user);
  Future<AuthHiveModel?> loginUser(String email, String password);
}

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel> registerUser(AuthApiModel user);
  Future<AuthApiModel?> loginUser(String email,String password);
}