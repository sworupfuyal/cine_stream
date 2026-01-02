import 'package:cine_stream/core/constants/hive_table_constant.dart';
import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String userName;



  @HiveField(2)
  final String? password;



  AuthHiveModel({
    String? userId,
    required this.userName,
    this.password,
  }) : userId = userId ?? Uuid().v4();

  // From entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      userName: entity.userName,
      password: entity.password,
    );
  }

  // To entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      userName: userName,
      password: password,
    );
  }

  //  list of models to list of entities
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}